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
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(strings.nearbyShops)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: strings.enterPincode,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      counterText: '',
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
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(strings.searchButton),
                ),
              ],
            ),

            // ── Results count ────────────────────────────────────
            if (_searched && _shops.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                strings.shopsFoundText != null
                    ? strings.shopsFoundText!(_shops.length)
                    : '${_shops.length} ${AppStrings.shopsFoundSuffix}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            // ── Searching loading text ───────────────────────────
            if (_isLoading && strings.searchingShops.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                strings.searchingShops,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ── Results ──────────────────────────────────────────
            Expanded(
              child: !_searched
                  ? _EmptySearch(strings: strings)
                  : _shops.isEmpty
                      ? _NoShopsFound(strings: strings)
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: _shops.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
    setState(() {
      _isLoading = true;
      _searched = false;
    });
    try {
      final results = await _apiService.getNearbyShops(pincode: pincode);
      await _storage.setLastSearchedPincode(pincode);
      setState(() {
        _shops = results;
        _searched = true;
      });
    } catch (e) {
      final msg = ApiService.extractErrorMessage(e, strings.networkError);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

// ── Shop card ─────────────────────────────────────────────────────────────────

class _ShopCard extends StatelessWidget {
  final LocalizedStrings strings;
  final ShopModel shop;
  final VoidCallback onTap;

  const _ShopCard({required this.strings, required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final previewItems = shop.inventory.take(3).toList();
    final extraCount = shop.inventory.length - previewItems.length;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black12,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: icon + name + item count badge ──────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9A3C), Color(0xFFFF6B00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.storefront, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.person_outline,
                                size: 13, color: AppColors.textSecondary),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                shop.ownerName,
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (shop.address != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  shop.address!,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Item count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${shop.inventory.length}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          strings.itemsCount,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Inventory preview chips ──────────────────────────
              if (previewItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...previewItems.map(
                      (item) => _ItemChip(name: item.displayName),
                    ),
                    if (extraCount > 0)
                      _ItemChip(
                        name: '+$extraCount ${AppStrings.moreItemsSuffix}',
                        isPrimary: true,
                      ),
                  ],
                ),
              ],

              // ── Browse CTA ────────────────────────────────────────
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accent.withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          strings.orderFromShopLabel,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios,
                            size: 12, color: AppColors.accent),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemChip extends StatelessWidget {
  final String name;
  final bool isPrimary;

  const _ItemChip({required this.name, this.isPrimary = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 12,
            color: isPrimary ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      );
}

// ── Empty state ───────────────────────────────────────────────────────────────

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
            Text(
              strings.enterPincode,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              strings.nearbyShopsWillShow,
              style: const TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
          ],
        ),
      );
}

class _NoShopsFound extends StatelessWidget {
  final LocalizedStrings strings;
  const _NoShopsFound({required this.strings});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              strings.noShopsFound,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            if (strings.noShopsTryDiff.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                strings.noShopsTryDiff,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ],
        ),
      );
}
