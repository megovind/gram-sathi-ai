import '../../core/constants/app_constants.dart';

class CartItem {
  final String itemId;
  final String name;
  final double price;
  int qty;

  CartItem({
    required this.itemId,
    required this.name,
    required this.price,
    this.qty = 1,
  });

  double get subtotal => price * qty;

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'name': name,
        'price': price,
        'qty': qty,
      };
}

class OrderModel {
  final String orderId;
  final String shopId;
  final String status;
  final double totalAmount;
  final String? message;

  const OrderModel({
    required this.orderId,
    required this.shopId,
    required this.status,
    required this.totalAmount,
    this.message,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        orderId: json['orderId'] as String,
        shopId: json['shopId'] as String? ?? '',
        status: json['status'] as String? ?? AppConstants.orderStatusPending,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        message: json['message'] as String?,
      );
}
