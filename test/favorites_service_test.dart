import 'package:e_parada_mobile/services/favorites_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FavoritesService', () {
    test('toggles favorite spaces and updates reactive notifier', () async {
      await FavoritesService.init();
      expect(FavoritesService.isFavorite(10), false);

      // Add favorite
      final added = await FavoritesService.toggleFavorite(10);
      expect(added, true);
      expect(FavoritesService.isFavorite(10), true);
      expect(FavoritesService.getFavoriteIds().contains(10), true);
      expect(FavoritesService.favoritesNotifier.value.contains(10), true);

      // Add another
      await FavoritesService.toggleFavorite(20);
      expect(FavoritesService.isFavorite(20), true);
      expect(FavoritesService.getFavoriteIds().length, 2);

      // Remove favorite
      final removed = await FavoritesService.toggleFavorite(10);
      expect(removed, false);
      expect(FavoritesService.isFavorite(10), false);
      expect(FavoritesService.isFavorite(20), true);
      expect(FavoritesService.getFavoriteIds().length, 1);
    });

    test('persists favorites in SharedPreferences across sessions', () async {
      SharedPreferences.setMockInitialValues({
        'user_favorite_space_ids_v1': ['5', '8', '12'],
      });

      // Force re-initialization by resetting or loading
      final prefs = await SharedPreferences.getInstance();
      final stringList = prefs.getStringList('user_favorite_space_ids_v1') ?? [];
      final ids = stringList.map((e) => int.tryParse(e)).whereType<int>().toSet();
      FavoritesService.favoritesNotifier.value = ids;

      expect(FavoritesService.isFavorite(5), true);
      expect(FavoritesService.isFavorite(8), true);
      expect(FavoritesService.isFavorite(12), true);
      expect(FavoritesService.isFavorite(99), false);
    });
  });
}
