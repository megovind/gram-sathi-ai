import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/storage_service.dart';

class ShopDashboardScreen extends StatefulWidget {
  const ShopDashboardScreen({super.key});

  @override
  State<ShopDashboardScreen> createState() => _ShopDashboardScreenState();
}

class _ShopDashboardScreenState extends State<ShopDashboardScreen> {
  late ApiService _apiService;
  Map<String, dynamic>? _analytics;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = context.read<ApiService>();
    _load();
  }

  Future<void> _load() async {
    final storage = context.read<StorageService>();
    final shopId = storage.shopId;
    if (shopId == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      // Run both network calls in parallel — cuts wait time roughly in half
      final results = await Future.wait([
        _apiService.getShopAnalytics(shopId),
        _apiService.getShopOrders(shopId),
      ]);
      setState(() {
        _analytics = results[0] as Map<String, dynamic>;
        _orders = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final strings = AppStrings.forLanguage(storage.language);

    return Scaffold(
      appBar: AppBar(title: Text(strings.shopDashboard)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : storage.shopId == null
              ? _NoShopState(strings: strings)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Analytics cards
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: strings.todayRevenue,
                                value:
                                    '₹${(_analytics?['today']?['revenue'] ?? 0).toStringAsFixed(0)}',
                                icon: Icons.currency_rupee,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: strings.todayOrders,
                                value:
                                    '${_analytics?['today']?['orderCount'] ?? 0}',
                                icon: Icons.shopping_bag_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: strings.totalOrders,
                                value:
                                    '${_analytics?['allTime']?['orderCount'] ?? 0}',
                                icon: Icons.receipt_long_outlined,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: strings.pendingOrders,
                                value:
                                    '${_analytics?['allTime']?['pendingOrders'] ?? 0}',
                                icon: Icons.pending_outlined,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Inventory button
                        ElevatedButton.icon(
                          onPressed: () => context.push(
                            '${AppRoutes.inventory}?shopId=${storage.shopId}',
                          ),
                          icon: const Icon(Icons.inventory_2_outlined),
                          label: Text(strings.inventory),
                        ),
                        const SizedBox(height: 24),

                        // Recent orders
                        Text(strings.newOrders,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        if (_orders.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(strings.noOrders,
                                  style: const TextStyle(color: AppColors.textSecondary)),
                            ),
                          )
                        else
                          ..._orders.take(10).map((o) => _OrderTile(order: o)),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _NoShopState extends StatelessWidget {
  final LocalizedStrings strings;
  const _NoShopState({required this.strings});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront_outlined, size: 72, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text(strings.shopNotRegistered,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                strings.registerShopPrompt,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: Text(strings.registerShopButton),
              ),
            ],
          ),
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );
}

class _OrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String? ?? '';
    final statusColor = status == AppConstants.orderStatusPending
        ? AppColors.warning
        : status == AppConstants.orderStatusConfirmed
            ? AppColors.primary
            : AppColors.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${(order['orderId'] as String? ?? '').substring(0, AppConstants.orderIdDisplayLength)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '₹${order['totalAmount'] ?? 0}',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
