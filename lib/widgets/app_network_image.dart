import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.fallbackWidget,
    this.loadingWidget,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? fallbackWidget;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallback = fallbackWidget ??
        ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Center(
            child: Icon(
              Icons.local_parking_rounded,
              color: theme.colorScheme.primary,
              size: 36,
            ),
          ),
        );

    final loading = loadingWidget ??
        ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Center(
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );

    if (imageUrl.trim().isEmpty) {
      return fallback;
    }

    Widget imageWidget;

    if (kIsWeb) {
      final objectFitStyle = switch (fit) {
        BoxFit.contain => 'contain',
        BoxFit.fill => 'fill',
        BoxFit.fitWidth => 'scale-down',
        BoxFit.fitHeight => 'scale-down',
        BoxFit.none => 'none',
        _ => 'cover',
      };

      imageWidget = HtmlElementView.fromTagName(
        tagName: 'img',
        onElementCreated: (element) {
          try {
            final dynamic img = element;
            img.src = imageUrl;
            img.style.width = '100%';
            img.style.height = '100%';
            img.style.objectFit = objectFitStyle;
            img.style.display = 'block';
            img.style.border = 'none';
            img.style.pointerEvents = 'none';
          } catch (_) {}
        },
      );
    } else {
      imageWidget = Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return loading;
        },
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    if (width != null || height != null) {
      imageWidget = SizedBox(
        width: width,
        height: height,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
