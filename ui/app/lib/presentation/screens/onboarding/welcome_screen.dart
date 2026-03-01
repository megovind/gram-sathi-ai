import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/app_icon_widget.dart';
import '../../../data/services/storage_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final strings = AppStrings.forLanguage(storage.language);
    return Scaffold(
      body: Stack(
        children: [
          // Gradient header background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.42,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // App icon on gradient
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: const AppIconWidget(size: 110, fit: BoxFit.fill),
                  ),
                  const SizedBox(height: 20),
                  // Title on gradient
                  Text(
                    strings.welcomeTitle,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.welcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Feature tiles on white
                  _FeatureTile(
                    icon: Icons.health_and_safety_outlined,
                    color: AppColors.secondary,
                    title: strings.featureHealthTitle,
                    subtitle: strings.featureHealthSubtitle,
                  ),
                  const SizedBox(height: 12),
                  _FeatureTile(
                    icon: Icons.store_outlined,
                    color: AppColors.accent,
                    title: strings.featureOrderTitle,
                    subtitle: strings.featureOrderSubtitle,
                  ),
                  const SizedBox(height: 12),
                  _FeatureTile(
                    icon: Icons.mic_outlined,
                    color: AppColors.primary,
                    title: strings.featureVoiceTitle,
                    subtitle: strings.featureVoiceSubtitle,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _onGetStarted(context),
                    child: Text(strings.getStarted),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onGetStarted(BuildContext context) async {
    final storage = context.read<StorageService>();
    await storage.completeOnboarding();
    if (context.mounted) context.go(AppRoutes.home);
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color.withOpacity(0.5)),
          ],
        ),
      );
}
