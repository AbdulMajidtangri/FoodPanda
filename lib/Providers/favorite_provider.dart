import 'package:flutter/material.dart';
import 'package:foodpanda_app/Models/restaurant_model.dart';

class FavoriteProvider with ChangeNotifier {
  final List<Restaurant> _favorites = [];

  List<Restaurant> get favorites => [..._favorites];

  bool isFavorite(String id) {
    return _favorites.any((r) => r.id == id);
  }

  void toggleFavorite(Restaurant restaurant) {
    if (isFavorite(restaurant.id)) {
      _favorites.removeWhere((r) => r.id == restaurant.id);
    } else {
      _favorites.add(restaurant);
    }
    notifyListeners();
  }
}
