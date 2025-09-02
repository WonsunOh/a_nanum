class DatabaseConstants {
  // 테이블 이름
  static const String productsTable = 'products';
  static const String categoriesTable = 'categories';
  static const String usersTable = 'profiles';
  static const String ordersTable = 'orders';
  static const String cartItemsTable = 'cart_items';
  static const String groupBuysTable = 'group_buys';
  static const String wishlistTable = 'wishlist_items';
  
  // 뷰 이름
  static const String productsWithCategoryView = 'products_with_category_path';
  static const String groupBuysWithProductsView = 'group_buys_with_products';
  
  // Storage 버킷
  static const String productImagesBucket = 'product-images';
  static const String profileImagesBucket = 'profile-images';
}