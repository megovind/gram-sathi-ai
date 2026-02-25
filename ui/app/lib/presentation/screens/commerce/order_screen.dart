import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/services/api_service.dart';

class OrderScreen extends StatefulWidget {
  final String shopId;
  const OrderScreen({super.key, required this.shopId});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  ShopModel? _shop;
  final Map<String, CartItem> _cart = {};
  bool _isLoading = true;
  bool _isOrdering = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  Future<void> _loadShop() async {
    final api = context.read<ApiService>();
    try {
      final shop = await api.getShop(widget.shopId);
      setState(() {
        _shop = shop;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'दुकान की जानकारी नहीं मिली';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _cart.values.fold<double>(0, (s, i) => s + i.subtotal);

    return Scaffold(
      appBar: AppBar(
        title: Text(_shop?.name ?? 'दुकान से ऑर्डर करें'),
        actions: [
          if (_cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Text(
                  '₹${totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorState(message: _errorMessage!, onRetry: _loadShop)
              : _shop!.inventory.isEmpty
                  ? _buildNoItems()
                  : Column(
                      children: [
                        Expanded(child: _buildInventory()),
                        if (_cart.isNotEmpty) _buildCartBar(totalAmount),
                      ],
                    ),
    );
  }

  Widget _buildNoItems() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            const Text('इस दुकान में अभी कोई सामान नहीं है'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('वापस जाएँ'),
            ),
          ],
        ),
      );

  Widget _buildInventory() => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _shop!.inventory.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final item = _shop!.inventory[i];
          final qty = _cart[item.itemId]?.qty ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      Text(
                        '₹${item.price.toStringAsFixed(0)} / ${item.unit}',
                        style: const TextStyle(color: AppColors.primary, fontSize: 13),
                      ),
                      if (item.stockQty > 0)
                        Text(
                          'स्टॉक: ${item.stockQty}',
                          style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                if (qty == 0)
                  OutlinedButton(
                    onPressed: item.stockQty == 0 ? null : () => _addToCart(item),
                    child: Text(item.stockQty == 0 ? 'उपलब्ध नहीं' : 'जोड़ें'),
                  )
                else
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.primary,
                        onPressed: () => _decreaseQty(item.itemId),
                      ),
                      Text('$qty',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                        onPressed: () => _increaseQty(item.itemId),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      );

  Widget _buildCartBar(double total) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_cart.length} items', style: const TextStyle(color: AppColors.textSecondary)),
                Text('${AppStrings.totalAmount}: ₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isOrdering ? null : _placeOrder,
              child: _isOrdering
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('ऑर्डर करें • ₹${total.toStringAsFixed(0)}'),
            ),
          ],
        ),
      );

  void _addToCart(InventoryItemModel item) {
    setState(() {
      _cart[item.itemId] = CartItem(
        itemId: item.itemId,
        name: item.displayName,
        price: item.price,
      );
    });
  }

  void _increaseQty(String itemId) => setState(() => _cart[itemId]?.qty++);

  void _decreaseQty(String itemId) {
    setState(() {
      final item = _cart[itemId];
      if (item != null) {
        if (item.qty <= 1) {
          _cart.remove(itemId);
        } else {
          item.qty--;
        }
      }
    });
  }

  Future<void> _placeOrder() async {
    setState(() => _isOrdering = true);
    final api = context.read<ApiService>();

    try {
      final order = await api.placeOrder(
        shopId: widget.shopId,
        items: _cart.values.map((i) => i.toJson()).toList(),
      );
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _OrderSuccessDialog(order: order),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.networkError)),
      );
    } finally {
      setState(() => _isOrdering = false);
    }
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('दोबारा कोशिश करें')),
          ],
        ),
      );
}

class _OrderSuccessDialog extends StatelessWidget {
  final OrderModel order;
  const _OrderSuccessDialog({required this.order});

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 64),
            const SizedBox(height: 12),
            const Text(AppStrings.orderPlaced,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Order ID: #${order.orderId.substring(0, 8)}',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('${AppStrings.totalAmount}: ₹${order.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (order.message != null) ...[
              const SizedBox(height: 8),
              Text(order.message!, textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('घर जाएँ'),
          ),
        ],
      );
}
