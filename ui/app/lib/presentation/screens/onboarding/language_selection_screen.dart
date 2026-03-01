import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/app_icon_widget.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/storage_service.dart';


class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = AppConstants.defaultLanguage;
  bool _isLoading = false;
  bool _hasLoadedFromStorage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedFromStorage) {
      _hasLoadedFromStorage = true;
      final stored = context.read<StorageService>().language;
      if (stored != _selectedLanguage) {
        _selectedLanguage = stored;
        if (mounted) setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final lang = storage.language;
    final strings = AppStrings.forLanguage(lang);
    return Scaffold(
      body: Column(
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: const AppIconWidget(size: 80, fit: BoxFit.fill),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.selectLanguage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
          // Language grid + button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: AppConstants.supportedLanguages.length,
                      itemBuilder: (context, i) {
                        final lang = AppConstants.supportedLanguages[i];
                        final code = lang['code']!;
                        final isSelected = code == _selectedLanguage;
                        return GestureDetector(
                          onTap: () async {
                            setState(() => _selectedLanguage = code);
                            await context.read<StorageService>().setLanguage(code);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.divider,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  : [],
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
                        : Text(strings.continueText),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onContinue() async {
    setState(() => _isLoading = true);
    final storage = context.read<StorageService>();
    await storage.setLanguage(_selectedLanguage);
    if (storage.isLoggedIn && storage.phone != null) {
      try {
        final api = context.read<ApiService>();
        await api.registerUser(
          phone: storage.phone!,
          language: _selectedLanguage,
        );
      } catch (_) {
        // Keep local language even if backend update fails
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
      if (storage.isLoggedIn) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.phoneInput);
      }
    }
  }
}
