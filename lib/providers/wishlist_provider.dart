import 'package:flutter/foundation.dart';

class WishlistProvider extends ChangeNotifier {
  final Set<String> _wishlist = {};

  bool isLiked(String id) {
    return _wishlist.contains(id);
  }

  void toggle(String id) {
    if (_wishlist.contains(id)) {
      _wishlist.remove(id);
    } else {
      _wishlist.add(id);
    }

    notifyListeners();
  }

  int get count => _wishlist.length;
}
