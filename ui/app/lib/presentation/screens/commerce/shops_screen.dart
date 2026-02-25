import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/storage_service.dart';

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({super.key});

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen> {
  final _pincodeController = TextEditingController();
  late ApiService _apiService;
  List<ShopModel> _shops = [];
  bool _isLoading = false;
  bool _searched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.nearbyShops)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: AppStrings.enterPincode,
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    maxLength: 6,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(80, 52)),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('खोजें'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: !_searched
                  ? const _EmptySearch()
                  : _shops.isEmpty
                      ? const Center(child: Text('इस क्षेत्र में कोई दुकान नहीं मिली'))
                      : ListView.separated(
                          itemCount: _shops.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _ShopCard(
                            shop: _shops[i],
                            onTap: () => context.push(
                              '${AppRoutes.order}?shopId=${_shops[i].shopId}',
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _search() async {
    final pincode = _pincodeController.text.trim();
    if (pincode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('6 अंकों का पिनकोड डालें')),
      );
      return;
    }
    setState(() { _isLoading = true; _searched = false; });
    try {
      final results = await _apiService.getNearbyShops(pincode: pincode);
      setState(() { _shops = results; _searched = true; });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.networkError)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class _ShopCard extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback onTap;
  const _ShopCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.storefront, color: AppColors.accent, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shop.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(shop.ownerName,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      if (shop.address != null)
                        Text(shop.address!,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '${shop.inventory.length} items available',
                        style: const TextStyle(color: AppColors.primary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textHint),
              ],
            ),
          ),
        ),
      );
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: AppColors.textHint),
            SizedBox(height: 12),
            Text('अपना पिनकोड डालें',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            SizedBox(height: 4),
            Text('नजदीकी दुकानें दिखेंगी',
                style: TextStyle(color: AppColors.textHint, fontSize: 13)),
          ],
        ),
      );
}
