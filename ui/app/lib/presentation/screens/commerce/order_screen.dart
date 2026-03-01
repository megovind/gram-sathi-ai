import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/services/storage_service.dart';
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
        _errorMessage = AppStrings.forLanguage(context.read<StorageService>().language).shopInfoNotFound;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final strings = AppStrings.forLanguage(storage.language);
    final totalAmount = _cart.values.fold<double>(0, (s, i) => s + i.subtotal);

    return Scaffold(
      appBar: AppBar(
        title: Text(_shop?.name ?? strings.orderFromShopTitle),
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
              ? _ErrorState(strings: strings, message: _errorMessage!, onRetry: _loadShop)
              : _shop!.inventory.isEmpty
                  ? _buildNoItems(strings)
                  : Column(
                      children: [
                        Expanded(child: _buildInventory(strings)),
                        if (_cart.isNotEmpty) _buildCartBar(strings, totalAmount),
                      ],
                    ),
    );
  }

  Widget _buildNoItems(LocalizedStrings strings) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(strings.noItemsInShop),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.goBack),
            ),
          ],
        ),
      );

  Widget _buildInventory(LocalizedStrings strings) => ListView.separated(
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
                          '${strings.stockLabel}: ${item.stockQty}',
                          style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                if (qty == 0)
                  OutlinedButton(
                    onPressed: item.stockQty == 0 ? null : () => _addToCart(item),
                    child: Text(item.stockQty == 0 ? strings.notAvailable : strings.addButton),
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
                        // Disable once cart qty reaches available stock
                        onPressed: (item.stockQty > 0 && qty >= item.stockQty)
                            ? null
                            : () => _increaseQty(item.itemId, item.stockQty),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      );

  Widget _buildCartBar(LocalizedStrings strings, double total) => Container(
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
                Text('${_cart.length} ${strings.itemsCount}', style: const TextStyle(color: AppColors.textSecondary)),
                Text('${strings.totalAmount}: ₹${total.toStringAsFixed(0)}',
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
                  : Text('${strings.placeOrderButton} • ₹${total.toStringAsFixed(0)}'),
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

  void _increaseQty(String itemId, int maxQty) {
    setState(() {
      final cartItem = _cart[itemId];
      if (cartItem != null && (maxQty == 0 || cartItem.qty < maxQty)) {
        cartItem.qty++;
      }
    });
  }

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
        final strings = AppStrings.forLanguage(context.read<StorageService>().language);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _OrderSuccessDialog(strings: strings, order: order),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.forLanguage(context.read<StorageService>().language).networkError)),
      );
    } finally {
      setState(() => _isOrdering = false);
    }
  }
}

class _ErrorState extends StatelessWidget {
  final LocalizedStrings strings;
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.strings, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(strings.retryButton)),
          ],
        ),
      );
}

class _OrderSuccessDialog extends StatelessWidget {
  final LocalizedStrings strings;
  final OrderModel order;
  const _OrderSuccessDialog({required this.strings, required this.order});

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 64),
            const SizedBox(height: 12),
            Text(strings.orderPlaced,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Order ID: #${order.orderId.substring(0, AppConstants.orderIdDisplayLength)}',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('${strings.totalAmount}: ₹${order.totalAmount.toStringAsFixed(0)}',
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
            child: Text(strings.goHome),
          ),
        ],
      );
}
