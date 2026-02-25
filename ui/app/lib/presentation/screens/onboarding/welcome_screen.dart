import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/storage_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.record_voice_over, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 36),
              Text(
                AppStrings.welcomeTitle,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 36),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
              ),
              const SizedBox(height: 48),
              _FeatureTile(
                icon: Icons.health_and_safety_outlined,
                color: AppColors.secondary,
                title: 'स्वास्थ्य सलाह',
                subtitle: 'लक्षण बताएँ, घरेलू उपाय पाएँ',
              ),
              const SizedBox(height: 16),
              _FeatureTile(
                icon: Icons.store_outlined,
                color: AppColors.accent,
                title: 'दुकान से मँगाएँ',
                subtitle: 'नजदीकी दुकान से सामान ऑर्डर करें',
              ),
              const SizedBox(height: 16),
              _FeatureTile(
                icon: Icons.mic_outlined,
                color: AppColors.primary,
                title: 'आवाज़ से बात करें',
                subtitle: 'हिंदी में बोलें, तुरंत जवाब पाएँ',
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _onGetStarted(context),
                child: const Text(AppStrings.getStarted),
              ),
            ],
          ),
        ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
}
