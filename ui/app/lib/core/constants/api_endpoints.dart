class ApiEndpoints {
  ApiEndpoints._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://erem1hc30b.execute-api.ap-south-1.amazonaws.com/dev',
  );

  // User / Auth
  static const user = '$baseUrl/user';
  static String userById(String id) => '$baseUrl/user/$id';

  // Chat
  static const chat = '$baseUrl/chat';
  static const audioUploadUrl = '$baseUrl/audio/upload-url';

  // Health
  static const healthQuery = '$baseUrl/health/query';
  static const healthNearby = '$baseUrl/health/nearby';

  // Commerce
  static const commerceShops = '$baseUrl/commerce/shops';
  static const commerceOrder = '$baseUrl/commerce/order';
  static String commerceOrderById(String id) => '$baseUrl/commerce/order/$id';

  // Shop owner
  static const shopRegister = '$baseUrl/shop';
  static String shopById(String id) => '$baseUrl/shop/$id';
  static String shopInventory(String id) => '$baseUrl/shop/$id/inventory';
  static String shopOrders(String id) => '$baseUrl/shop/$id/orders';
  static String shopAnalytics(String id) => '$baseUrl/shop/$id/analytics';
}
