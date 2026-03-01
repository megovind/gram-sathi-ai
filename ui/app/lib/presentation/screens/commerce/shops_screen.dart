import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
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
  late StorageService _storage;
  List<ShopModel> _shops = [];
  bool _isLoading = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _apiService = context.read<ApiService>();
    _storage = context.read<StorageService>();
    _initPincodeAndSearch();
  }

  void _initPincodeAndSearch() {
    final savedPincode = _storage.lastSearchedPincode;
    final pincode = savedPincode != null && savedPincode.length == 6
        ? savedPincode
        : AppConstants.defaultSeedPincode;
    _pincodeController.text = pincode;
    WidgetsBinding.instance.addPostFrameCallback((_) => _search());
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final strings = AppStrings.forLanguage(storage.language);
    return Scaffold(
      appBar: AppBar(title: Text(strings.nearbyShops)),
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
                    decoration: InputDecoration(
                      hintText: strings.enterPincode,
                      prefixIcon: const Icon(Icons.location_on_outlined),
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
                      : Text(strings.searchButton),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: !_searched
                  ? _EmptySearch(strings: strings)
                  : _shops.isEmpty
                      ? Center(child: Text(strings.noShopsFound))
                      : ListView.separated(
                          itemCount: _shops.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _ShopCard(
                            strings: strings,
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
    final strings = AppStrings.forLanguage(context.read<StorageService>().language);
    if (pincode.length != AppConstants.pincodeLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.pincodeError)),
      );
      return;
    }
    setState(() { _isLoading = true; _searched = false; });
    try {
      final results = await _apiService.getNearbyShops(pincode: pincode);
      await _storage.setLastSearchedPincode(pincode);
      setState(() { _shops = results; _searched = true; });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.networkError)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class _ShopCard extends StatelessWidget {
  final LocalizedStrings strings;
  final ShopModel shop;
  final VoidCallback onTap;
  const _ShopCard({required this.strings, required this.shop, required this.onTap});

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
                        '${shop.inventory.length} ${strings.itemsAvailable}',
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
  final LocalizedStrings strings;
  const _EmptySearch({required this.strings});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(strings.enterPincode,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 4),
            Text(strings.nearbyShopsWillShow,
                style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
          ],
        ),
      );
}
