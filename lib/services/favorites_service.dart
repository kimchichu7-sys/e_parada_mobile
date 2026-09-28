import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _storageKey = 'user_favorite_space_ids_v1';
  static final ValueNotifier<Set<int>> favoritesNotifier = ValueNotifier<Set<int>>(<int>{});
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(_storageKey) ?? [];
    final ids = stringList.map((e) => int.tryParse(e)).whereType<int>().toSet();
    favoritesNotifier.value = ids;
    _initialized = true;
  }

  static bool isFavorite(int spaceId) {
    return favoritesNotifier.value.contains(spaceId);
  }

  static Future<bool> toggleFavorite(int spaceId) async {
    await init();
    final current = Set<int>.from(favoritesNotifier.value);
    final isAdded = !current.contains(spaceId);

    if (isAdded) {
      current.add(spaceId);
    } else {
      current.remove(spaceId);
    }

    favoritesNotifier.value = current;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, current.map((e) => e.toString()).toList());
    return isAdded;
  }

  static Set<int> getFavoriteIds() {
    return favoritesNotifier.value;
  }
}
