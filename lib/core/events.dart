class ProductFavoriteChanged {
  ProductFavoriteChanged(this.id, this.isFavorite);

  final int id;
  final bool isFavorite;
}

class CartChanged {}

class CartProductAdded extends CartChanged {}

class CartProductRemoved extends CartChanged {}

class CartProductQuantityChanged extends CartProductAdded {}
