import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class MarkerBitmapGenerator {
  static final Map<String, gmaps.BitmapDescriptor> _cache = {};

  /// Retrieves a pre-generated cached marker if available
  static gmaps.BitmapDescriptor? getCachedMarker({
    required double price,
    required bool isAvailable,
    required bool isSelected,
  }) {
    final key = _cacheKey(price, isAvailable, isSelected);
    return _cache[key];
  }

  /// Builds a unique cache key based on marker visual attributes
  static String _cacheKey(double price, bool isAvailable, bool isSelected) {
    final priceStr = price > 0
        ? (price % 1 == 0 ? price.toInt().toString() : price.toStringAsFixed(1))
        : '0';
    return '${priceStr}_${isAvailable}_$isSelected';
  }

  /// Creates or retrieves a custom price badge BitmapDescriptor
  static Future<gmaps.BitmapDescriptor> getPriceMarker({
    required double price,
    required bool isAvailable,
    required bool isSelected,
    double pixelRatio = 2.5,
  }) async {
    final key = _cacheKey(price, isAvailable, isSelected);
    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }

    try {
      final descriptor = await _drawPriceBadge(
        price: price,
        isAvailable: isAvailable,
        isSelected: isSelected,
        pixelRatio: pixelRatio,
      );
      _cache[key] = descriptor;
      return descriptor;
    } catch (e) {
      // Fallback in case of rendering error
      return isSelected
          ? gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueYellow)
          : (isAvailable
              ? gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueAzure)
              : gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed));
    }
  }

  static Future<gmaps.BitmapDescriptor> _drawPriceBadge({
    required double price,
    required bool isAvailable,
    required bool isSelected,
    required double pixelRatio,
  }) async {
    // 1. Color Palette
    const navyBg = Color(0xFF173B64);
    const goldBg = Color(0xFFFFDE70);
    const redBg = Color(0xFFDC2626);

    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final Color badgeBgColor;
    final Color badgeTextColor;

    if (isSelected) {
      bgColor = goldBg;
      borderColor = navyBg;
      textColor = navyBg;
      badgeBgColor = navyBg;
      badgeTextColor = goldBg;
    } else if (!isAvailable) {
      bgColor = redBg;
      borderColor = Colors.white;
      textColor = Colors.white;
      badgeBgColor = Colors.white;
      badgeTextColor = redBg;
    } else {
      bgColor = navyBg;
      borderColor = Colors.white;
      textColor = Colors.white;
      badgeBgColor = Colors.white;
      badgeTextColor = navyBg;
    }

    // 2. Format Price Text
    final String amountText;
    final String unitText;

    if (price <= 0) {
      amountText = 'Free';
      unitText = '';
    } else {
      amountText = '₱${price % 1 == 0 ? price.toInt() : price.toStringAsFixed(1)}';
      unitText = '/hr';
    }

    // 3. Measure Text
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        children: [
          TextSpan(
            text: amountText,
            style: TextStyle(
              color: textColor,
              fontSize: 13.0,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          if (unitText.isNotEmpty)
            TextSpan(
              text: unitText,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.9),
                fontSize: 10.0,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    )..layout();

    // 4. Dimensions & Layout
    const double emblemDiameter = 17.0;
    const double emblemSpacing = 5.0;
    const double padLeft = 7.0;
    const double padRight = 9.0;
    const double pillHeight = 32.0;
    const double pointerHeight = 6.0;
    const double pointerWidth = 10.0;
    const double shadowMargin = 4.0;

    final double contentWidth = emblemDiameter + emblemSpacing + textPainter.width;
    final double pillWidth = padLeft + contentWidth + padRight;

    final double totalWidth = pillWidth + (shadowMargin * 2);
    final double totalHeight = pillHeight + pointerHeight + (shadowMargin * 2);

    final int canvasWidth = (totalWidth * pixelRatio).ceil();
    final int canvasHeight = (totalHeight * pixelRatio).ceil();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pixelRatio, pixelRatio);

    // 5. Draw Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

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

    final shadowPath = Path()
      ..addRRect(pillRRect)
      ..moveTo(shadowMargin + (pillWidth / 2) - (pointerWidth / 2), shadowMargin + pillHeight)
      ..lineTo(shadowMargin + (pillWidth / 2), shadowMargin + pillHeight + pointerHeight)
      ..lineTo(shadowMargin + (pillWidth / 2) + (pointerWidth / 2), shadowMargin + pillHeight)
      ..close();

    canvas.save();
    canvas.translate(0, 1.5);
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.restore();

    // 6. Draw Unified Badge Path (Pill + Bottom Pointer)
    final badgePath = Path()
      ..addRRect(pillRRect)
      ..moveTo(shadowMargin + (pillWidth / 2) - (pointerWidth / 2), shadowMargin + pillHeight - 1)
      ..lineTo(shadowMargin + (pillWidth / 2), shadowMargin + pillHeight + pointerHeight)
      ..lineTo(shadowMargin + (pillWidth / 2) + (pointerWidth / 2), shadowMargin + pillHeight - 1)
      ..close();

    final fillPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(badgePath, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.0 : 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(badgePath, borderPaint);

    // 7. Draw Circular 'P' Emblem
    final emblemCenterX = shadowMargin + padLeft + (emblemDiameter / 2);
    final emblemCenterY = shadowMargin + (pillHeight / 2);

    final emblemBgPaint = Paint()
      ..color = badgeBgColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(emblemCenterX, emblemCenterY), emblemDiameter / 2, emblemBgPaint);

    final emblemTextPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: 'P',
        style: TextStyle(
          color: badgeTextColor,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    )..layout();

    emblemTextPainter.paint(
      canvas,
      Offset(
        emblemCenterX - (emblemTextPainter.width / 2),
        emblemCenterY - (emblemTextPainter.height / 2),
      ),
    );

    // 8. Draw Price Text
    final textX = shadowMargin + padLeft + emblemDiameter + emblemSpacing;
    final textY = shadowMargin + (pillHeight - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(textX, textY));

    // 9. Convert to BitmapDescriptor
    final picture = recorder.endRecording();
    final image = await picture.toImage(canvasWidth, canvasHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to generate marker image bytes');
    }

    final uint8List = byteData.buffer.asUint8List();
    return gmaps.BitmapDescriptor.bytes(uint8List);
  }

  /// Calculates anchor offset so pointer tip touches coordinate
  static Offset getMarkerAnchor() {
    // Total logical height = 32 + 6 + (4*2) = 46
    // Tip Y = 4 + 32 + 6 = 42
    // 42 / 46 ≈ 0.913
    return const Offset(0.5, 0.913);
  }
}
