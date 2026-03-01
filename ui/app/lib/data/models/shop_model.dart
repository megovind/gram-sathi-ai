import '../../core/constants/app_constants.dart';

class InventoryItemModel {
  final String itemId;
  final String name;
  final String? nameHindi;
  final double price;
  final String unit;
  final int stockQty;

  const InventoryItemModel({
    required this.itemId,
    required this.name,
    this.nameHindi,
    required this.price,
    required this.unit,
    required this.stockQty,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) => InventoryItemModel(
        itemId: json['itemId'] as String,
        name: json['name'] as String,
        nameHindi: json['nameHindi'] as String?,
        price: (json['price'] as num).toDouble(),
        unit: json['unit'] as String? ?? AppConstants.defaultInventoryUnit,
        stockQty: json['stockQty'] as int? ?? 0,
      );

  String get displayName => nameHindi ?? name;
}

class ShopModel {
  final String shopId;
  final String name;
  final String ownerName;
  // phone is stripped by the public /shop/{id} endpoint — always treat as optional
  final String? phone;
  final String pincode;
  final String? address;
  final String status;
  final List<InventoryItemModel> inventory;

  const ShopModel({
    required this.shopId,
    required this.name,
    required this.ownerName,
    this.phone,
    required this.pincode,
    this.address,
    required this.status,
    required this.inventory,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) => ShopModel(
        shopId: json['shopId'] as String,
        name: json['name'] as String,
        ownerName: json['ownerName'] as String? ?? '',
        phone: json['phone'] as String?,
        pincode: json['pincode'] as String? ?? '',
        address: json['address'] as String?,
        status: json['status'] as String? ?? AppConstants.shopStatusPending,
        inventory: (json['inventory'] as List<dynamic>? ?? [])
            .map((e) => InventoryItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
