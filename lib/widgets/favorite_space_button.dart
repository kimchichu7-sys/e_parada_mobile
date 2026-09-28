import 'package:flutter/material.dart';

import '../services/favorites_service.dart';

class FavoriteSpaceButton extends StatelessWidget {
  const FavoriteSpaceButton({
    super.key,
    required this.parkingSpaceId,
    required this.parkingSpaceName,
    this.iconSize = 22,
    this.padding = const EdgeInsets.all(6),
    this.showBackground = false,
    this.backgroundColor,
  });

  final int parkingSpaceId;
  final String parkingSpaceName;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final bool showBackground;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: FavoritesService.favoritesNotifier,
      builder: (context, favIds, _) {
        final isFav = favIds.contains(parkingSpaceId);

        final button = IconButton(
          iconSize: iconSize,
          padding: padding,
          constraints: const BoxConstraints(),
          tooltip: isFav ? 'Remove from Saved' : 'Save to Favorites',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              isFav ? Icons.star_rounded : Icons.star_outline_rounded,
              key: ValueKey<bool>(isFav),
              color: isFav ? Colors.amber : (showBackground ? Colors.white : Colors.grey.shade600),
            ),
          ),
          onPressed: () async {
            final isAdded = await FavoritesService.toggleFavorite(parkingSpaceId);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isAdded
                      ? '⭐️ $parkingSpaceName saved to Favorites.'
                      : '$parkingSpaceName removed from Saved.',
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );

        if (showBackground) {
          return Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.black.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: button,
          );
        }

        return button;
      },
    );
  }
}
