class RouteConstants {
  // 사용자 앱 라우트
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String shop = '/shop';
  static const String productDetail = '/shop/:productId';
  static const String cart = '/shop/cart';
  static const String checkout = '/shop/cart/checkout';
  static const String mypage = '/shop/mypage';
  static const String wishlist = '/shop/mypage/wishlist';
  static const String orders = '/shop/mypage/orders';
  static const String groupBuy = '/group-buy';
  static const String groupBuyDetail = '/group-buy/detail/:id';
  static const String propose = '/propose';
  
  // 관리자 앱 라우트
  static const String adminLogin = '/login';
  static const String dashboard = '/dashboard';
  static const String productManagement = '/shop/products';
  static const String addProduct = '/shop/products/new';
  static const String editProduct = '/shop/products/edit/:productId';
  static const String categoryManagement = '/shop/categories';
  static const String userManagement = '/users';
  static const String orderManagement = '/orders';
}
