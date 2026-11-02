import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class MarkerBitmapGenerator {
  static final Map<String, gmaps.BitmapDescriptor> _cache = {};

  /// Retrieves a pre-generated cached marker if available
  static gmaps.BitmapDescriptor? getCachedMarker({
    required double price,
    bool isAvailable = true,
    bool isClosed = false,
    bool isSoldOut = false,
    required bool isSelected,
  }) {
    final key = _cacheKey(price, isAvailable, isClosed, isSoldOut, isSelected);
    return _cache[key];
  }

  /// Builds a unique cache key based on marker visual attributes
  static String _cacheKey(
    double price,
    bool isAvailable,
    bool isClosed,
    bool isSoldOut,
    bool isSelected,
  ) {
    final priceStr = price > 0 ? price.toStringAsFixed(2) : '0.00';
    return 'v3_${priceStr}_${isAvailable}_${isClosed}_${isSoldOut}_$isSelected';
  }

  /// Creates or retrieves a custom price badge BitmapDescriptor matching the web pin style
  static Future<gmaps.BitmapDescriptor> getPriceMarker({
    required double price,
    bool isAvailable = true,
    bool isClosed = false,
    bool isSoldOut = false,
    required bool isSelected,
    double? pixelRatio,
  }) async {
    final effectiveRatio = pixelRatio ?? (kIsWeb ? 1.0 : 2.0);
    final key = _cacheKey(price, isAvailable, isClosed, isSoldOut, isSelected);
    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }

    try {
      final descriptor = await _drawPriceBadge(
        price: price,
        isAvailable: isAvailable,
        isClosed: isClosed,
        isSoldOut: isSoldOut,
        isSelected: isSelected,
        pixelRatio: effectiveRatio,
      );
      _cache[key] = descriptor;
      return descriptor;
    } catch (e) {
      // Fallback in case of rendering error
      return isSelected
          ? gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueYellow)
          : (isSoldOut
              ? gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed)
              : (isClosed
                  ? gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueViolet)
                  : gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueAzure)));
    }
  }

  static Future<gmaps.BitmapDescriptor> _drawPriceBadge({
    required double price,
    required bool isAvailable,
    required bool isClosed,
    required bool isSoldOut,
    required bool isSelected,
    required double pixelRatio,
  }) async {
    // 1. Color Palette matching e-parada web pin (.spot-pin)
    const navyBg = Color(0xFF235282);  // Web spot-pin background
    const goldBg = Color(0xFFFFDE70);  // Active gold
    const redBg = Color(0xFF881337);   // Sold out burgundy
    const slateBg = Color(0xFF334155); // Closed slate grey

    final Color bgColor;
    final Color borderColor;
    final double borderWidth;
    final Color textColor;

    if (isSelected) {
      bgColor = goldBg;
      borderColor = const Color(0xFF173B64);
      borderWidth = 2.0;
      textColor = const Color(0xFF173B64);
    } else if (isSoldOut) {
      bgColor = redBg;
      borderColor = const Color(0xFFFDA4AF);
      borderWidth = 1.5;
      textColor = const Color(0xFFFECDD3);
    } else if (isClosed) {
      bgColor = slateBg;
      borderColor = const Color(0xFF94A3B8);
      borderWidth = 1.5;
      textColor = const Color(0xFFF1F5F9);
    } else if (!isAvailable) {
      bgColor = redBg;
      borderColor = const Color(0xFFFDA4AF);
      borderWidth = 1.5;
      textColor = const Color(0xFFFECDD3);
    } else {
      bgColor = navyBg;
      borderColor = Colors.white;
      borderWidth = 1.5;
      textColor = Colors.white;
    }

    // 2. Format Price Text (e.g. "₱15", "Closed", or "Sold Out")
    final String amountText;
    if (isSoldOut) {
      amountText = 'Sold Out';
    } else if (isClosed) {
      amountText = 'Closed';
    } else if (!isAvailable) {
      amountText = 'Unavailable';
    } else if (price <= 0) {
      amountText = 'Free';
    } else {
      amountText = price % 1 == 0 ? '₱${price.toInt()}' : '₱${price.toStringAsFixed(2)}';
    }

    // 3. Measure Text
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: amountText,
        style: TextStyle(
          color: textColor,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
        ),
      ),
    )..layout();

    // 4. Compact Dimensions & Layout (Sleek Airbnb-style pin)
    const double padH = 8.0;
    const double pillHeight = 22.0;
    const double pointerHeight = 4.5;
    const double pointerWidth = 7.0;
    const double shadowMargin = 3.0;

    final double pillWidth = textPainter.width + (padH * 2);
    final double totalWidth = pillWidth + (shadowMargin * 2);
    final double totalHeight = pillHeight + pointerHeight + (shadowMargin * 2);

    final int canvasWidth = (totalWidth * pixelRatio).ceil();
    final int canvasHeight = (totalHeight * pixelRatio).ceil();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pixelRatio, pixelRatio);

    // 5. Draw Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    final pillRect = Rect.fromLTWH(
      shadowMargin,
      shadowMargin,
      pillWidth,
      pillHeight,
    );
    final pillRRect = RRect.fromRectAndRadius(
      pillRect,
      const Radius.circular(pillHeight / 2),
    );
    final centerX = shadowMargin + (pillWidth / 2);

    final shadowPath = Path()
      ..addRRect(pillRRect)
      ..moveTo(centerX - (pointerWidth / 2), shadowMargin + pillHeight)
      ..lineTo(centerX, shadowMargin + pillHeight + pointerHeight)
      ..lineTo(centerX + (pointerWidth / 2), shadowMargin + pillHeight)
      ..close();

    canvas.save();
    canvas.translate(0, 1.2);
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.restore();

    // 6. Draw Unified Speech-Bubble Badge Path (Pill + Bottom Tip)
    final badgePath = Path()
      ..addRRect(pillRRect)
      ..moveTo(centerX - (pointerWidth / 2), shadowMargin + pillHeight - 0.5)
      ..lineTo(centerX, shadowMargin + pillHeight + pointerHeight)
      ..lineTo(centerX + (pointerWidth / 2), shadowMargin + pillHeight - 0.5)
      ..close();

    final fillPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(badgePath, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(badgePath, borderPaint);

    // 7. Draw Price Text centered inside the pill
    final textX = shadowMargin + (pillWidth - textPainter.width) / 2;
    final textY = shadowMargin + (pillHeight - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(textX, textY));

    // 8. Convert to BitmapDescriptor
    final picture = recorder.endRecording();
    final image = await picture.toImage(canvasWidth, canvasHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to generate marker image bytes');
    }

    final uint8List = byteData.buffer.asUint8List();
    return gmaps.BitmapDescriptor.bytes(uint8List);
  }

  /// Calculates anchor offset so pointer tip touches coordinate precisely
  static Offset getMarkerAnchor() {
    // Pill height = 22.0, Pointer = 4.5, Shadow margin = 3.0
    // Tip Y = 3.0 + 22.0 + 4.5 = 29.5
    // Total height = 22.0 + 4.5 + (3.0 * 2) = 32.5
    // 29.5 / 32.5 ≈ 0.907
    return const Offset(0.5, 0.907);
  }
}
