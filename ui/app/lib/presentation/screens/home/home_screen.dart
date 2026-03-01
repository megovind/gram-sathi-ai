import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/app_icon_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final strings = AppStrings.forLanguage(storage.language);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: const AppIconWidget(size: 48, fit: BoxFit.fill),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.appName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        strings.tagline,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
                    tooltip: strings.settingsTooltip,
                    onPressed: () => context.push('${AppRoutes.languageSelection}?change=1'),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Greeting
              Text(
                strings.howCanIHelp,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              // Main action cards
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.health_and_safety,
                      iconColor: AppColors.secondary,
                      title: strings.healthCard,
                      subtitle: strings.healthAdviceLabel,
                      gradient: [const Color(0xFFE8F8F0), const Color(0xFFD4F0E3)],
                      onTap: () => context.push(AppRoutes.health),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.store_rounded,
                      iconColor: AppColors.accent,
                      title: strings.commerceCard,
                      subtitle: strings.orderFromShopLabel,
                      gradient: [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
                      onTap: () => context.push(AppRoutes.shops),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Voice chat CTA
              GestureDetector(
                onTap: () => context.push(AppRoutes.health),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.mic, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.voiceAsk,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.voiceAskSubtitle,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick links
              Text(strings.quickServices, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _QuickLink(
                icon: Icons.local_hospital_outlined,
                label: strings.nearbyClinicLink,
                sublabel: strings.nearbyClinicSublabel,
                onTap: () => context.push(AppRoutes.health),
              ),
              _QuickLink(
                icon: Icons.shopping_bag_outlined,
                label: strings.myOrdersLink,
                sublabel: strings.myOrdersSublabel,
                onTap: () => context.push(AppRoutes.shops),
              ),
              // Show shop dashboard if user is a shop owner
              if (storage.shopId != null)
                _QuickLink(
                  icon: Icons.storefront_outlined,
                  label: strings.myShopLink,
                  sublabel: strings.myShopSublabel,
                  onTap: () => context.push(AppRoutes.shopDashboard),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(subtitle,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      );
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _QuickLink({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          subtitle: Text(sublabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          trailing: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
          ),
          onTap: onTap,
        ),
      );
}
