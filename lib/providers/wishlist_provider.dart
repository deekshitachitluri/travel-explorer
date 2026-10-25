import 'package:flutter/foundation.dart';

import '../data/local/local_storage_service.dart';
import '../models/destination.dart';

class WishlistProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  Set<String> _wishlistIds = {};

  WishlistProvider(this._storage) {
    _loadWishlist();
  }

  void _loadWishlist() {
    _wishlistIds = _storage.getWishlistIds();
    notifyListeners();
  }

  Set<String> get wishlistIds => _wishlistIds;
  int get count => _wishlistIds.length;

  bool isWishlisted(String destinationId) {
    return _wishlistIds.contains(destinationId);
  }

  Future<void> toggleWishlist(String destinationId) async {
    if (_wishlistIds.contains(destinationId)) {
      _wishlistIds.remove(destinationId);
    } else {
      _wishlistIds.add(destinationId);
    }
    await _storage.saveWishlistIds(_wishlistIds);
    notifyListeners();
  }

  Future<void> addToWishlist(String destinationId) async {
    if (!_wishlistIds.contains(destinationId)) {
      _wishlistIds.add(destinationId);
      await _storage.saveWishlistIds(_wishlistIds);
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(String destinationId) async {
    if (_wishlistIds.contains(destinationId)) {
      _wishlistIds.remove(destinationId);
      await _storage.saveWishlistIds(_wishlistIds);
      notifyListeners();
    }
  }

  List<Destination> getWishlistedDestinations(
    List<Destination> allDestinations,
  ) {
    return allDestinations.where((d) => _wishlistIds.contains(d.id)).toList();
  }
}
