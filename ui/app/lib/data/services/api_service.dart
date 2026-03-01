import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/shop_model.dart';
import '../models/order_model.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';

class ApiService {
  final Dio _dio;

  // Separate Dio for direct S3 uploads: no Authorization header, generous
  // receive timeout for slow rural connections (2G ~50 kbps for a 30s m4a ≈ 200 kB).
  final Dio _s3Dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: AppConstants.apiConnectTimeoutSeconds),
      receiveTimeout: const Duration(seconds: AppConstants.s3UploadReceiveTimeoutSeconds),
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('[S3 Upload] PUT ${options.path}');
            print('[S3 Upload] Headers: ${options.headers}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('[S3 Upload] Response ${response.statusCode}');
          }
          handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('[S3 Upload Error] ${e.type} → ${e.response?.statusCode}');
            print('[S3 Upload Error] Body: ${e.response?.data}');
            print('[S3 Upload Error] Message: ${e.message}');
          }
          handler.next(e);
        },
      ),
    );

  ApiService({String? token})
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: AppConstants.apiConnectTimeoutSeconds),
            receiveTimeout: const Duration(seconds: AppConstants.apiReceiveTimeoutSeconds),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    if (token != null) _setToken(token);

    // Interceptor: log errors clearly in debug
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          if (kDebugMode) {
            // ignore: avoid_print
            print('[API Error] ${e.requestOptions.method} ${e.requestOptions.path} → ${e.response?.statusCode}');
          }
          handler.next(e);
        },
      ),
    );
  }

  void _setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Call after login to attach the JWT to all subsequent requests.
  void updateToken(String token) => _setToken(token);

  // ── Auth / User ───────────────────────────────────────────

  /// Register a new user or update language preference.
  /// Returns { userId, language, name, token }.
  Future<Map<String, dynamic>> registerUser({
    required String phone,
    required String language,
    String? name,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.user,
      data: {
        'phone': phone,
        'language': language,
        if (name != null && name.isNotEmpty) 'name': name,
      },
    );
    final data = response.data as Map<String, dynamic>;
    // Attach the returned token immediately
    if (data['token'] != null) {
      updateToken(data['token'] as String);
    }
    return data;
  }

  Future<Map<String, dynamic>> getUser(String userId) async {
    final response = await _dio.get(ApiEndpoints.userById(userId));
    return response.data as Map<String, dynamic>;
  }

  // ── Chat ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendChat({
    String? text,
    String? audioS3Key,
    required String language,
    String? conversationId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.chat,
      data: {
        if (text != null) 'text': text,
        if (audioS3Key != null) 'audioS3Key': audioS3Key,
        'language': language,
        if (conversationId != null) 'conversationId': conversationId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAudioUploadUrl({
    required String fileName,
    String contentType = AppConstants.defaultAudioContentType,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.audioUploadUrl,
      data: {'fileName': fileName, 'contentType': contentType},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> uploadAudioToS3(String uploadUrl, List<int> audioBytes) async {
    await _s3Dio.put(
      uploadUrl,
      data: Stream.fromIterable([audioBytes]),
      options: Options(
        headers: {
          'Content-Type': AppConstants.defaultAudioContentType,
          'Content-Length': audioBytes.length,
        },
      ),
    );
  }

  // ── Health ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> queryHealth({
    String? text,
    String? audioS3Key,
    required String language,
    String? conversationId,
    bool generateSummary = false,
    String? pincode,
    double? latitude,
    double? longitude,
  }) async {
    assert(
      (text != null && text.isNotEmpty) || audioS3Key != null,
      'Either text or audioS3Key must be provided',
    );
    final response = await _dio.post(
      ApiEndpoints.healthQuery,
      data: {
        if (text != null && text.isNotEmpty) 'text': text,
        if (audioS3Key != null) 'audioS3Key': audioS3Key,
        'language': language,
        if (conversationId != null) 'conversationId': conversationId,
        'generateSummary': generateSummary,
        if (pincode != null && pincode.length == 6) 'pincode': pincode,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getNearbyFacilities(String pincode) async {
    final response = await _dio.post(
      ApiEndpoints.healthNearby,
      data: {'pincode': pincode},
    );
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['facilities'] as List? ?? []);
  }

  // ── Commerce ───────────────────────────────────────────────

  Future<List<ShopModel>> getNearbyShops({
    required String pincode,
    String? category,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.commerceShops,
      data: {
        'pincode': pincode,
        if (category != null) 'category': category,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return (data['shops'] as List? ?? [])
        .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ShopModel> getShop(String shopId) async {
    final response = await _dio.get(ApiEndpoints.shopById(shopId));
    return ShopModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OrderModel> placeOrder({
    required String shopId,
    required List<Map<String, dynamic>> items,
    String? deliveryAddress,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.commerceOrder,
      data: {
        'shopId': shopId,
        'items': items,
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      },
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Shop Owner ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getShopAnalytics(String shopId) async {
    final response = await _dio.get(ApiEndpoints.shopAnalytics(shopId));
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getShopOrders(String shopId) async {
    final response = await _dio.get(ApiEndpoints.shopOrders(shopId));
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['orders'] as List? ?? []);
  }

  Future<Map<String, dynamic>> updateInventory({
    required String shopId,
    required List<Map<String, dynamic>> items,
    bool replace = false,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.shopInventory(shopId),
      data: {'items': items, 'replace': replace},
    );
    return response.data as Map<String, dynamic>;
  }
}
