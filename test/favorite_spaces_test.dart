import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_parada_mobile/services/favorites_service.dart';
import 'package:e_parada_mobile/widgets/favorite_space_button.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await FavoritesService.init();
    FavoritesService.favoritesNotifier.value = <int>{};
  });

  testWidgets('FavoriteSpaceButton renders and toggles favorite state with SnackBar notification', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: FavoriteSpaceButton(
              parkingSpaceId: 42,
              parkingSpaceName: 'Crossing Parking Bay 42',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Initial state: not favorite
    expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    expect(FavoritesService.isFavorite(42), false);

    // Tap to save to favorites
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(find.text('⭐️ Crossing Parking Bay 42 saved to Favorites.'), findsOneWidget);
    expect(FavoritesService.isFavorite(42), true);

    // Tap again to remove
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    expect(find.text('Crossing Parking Bay 42 removed from Saved.'), findsOneWidget);
    expect(FavoritesService.isFavorite(42), false);
  });
}
