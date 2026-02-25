import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/storage_service.dart';

const _languages = [
  {'code': 'hi', 'name': 'हिंदी', 'label': 'Hindi'},
  {'code': 'en', 'name': 'English', 'label': 'English'},
  {'code': 'mr', 'name': 'मराठी', 'label': 'Marathi'},
  {'code': 'ta', 'name': 'தமிழ்', 'label': 'Tamil'},
  {'code': 'te', 'name': 'తెలుగు', 'label': 'Telugu'},
  {'code': 'kn', 'name': 'ಕನ್ನಡ', 'label': 'Kannada'},
  {'code': 'bn', 'name': 'বাংলা', 'label': 'Bengali'},
  {'code': 'gu', 'name': 'ગુજરાતી', 'label': 'Gujarati'},
];

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'hi';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.record_voice_over, color: Colors.white, size: 44),
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Text(
                  AppStrings.selectLanguage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _languages.length,
                  itemBuilder: (context, i) {
                    final lang = _languages[i];
                    final isSelected = lang['code'] == _selectedLanguage;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedLanguage = lang['code']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lang['name']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              lang['label']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _onContinue,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(AppStrings.continueText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    setState(() => _isLoading = true);
    final storage = context.read<StorageService>();
    await storage.setLanguage(_selectedLanguage);
    if (mounted) {
      setState(() => _isLoading = false);
      context.go(AppRoutes.phoneInput);
    }
  }
}
