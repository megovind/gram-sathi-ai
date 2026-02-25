import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/storage_service.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => context.go(AppRoutes.languageSelection),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.phone_android, color: AppColors.primary, size: 38),
                ),
                const SizedBox(height: 20),

                Text(
                  'अपना नंबर डालें',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your mobile number to get started',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Phone field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: 'मोबाइल नंबर',
                    hintText: '9876543210',
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: const Text('+91  ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          )),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.length != 10) {
                      return '10 अंकों का नंबर डालें';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Name field (optional)
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'आपका नाम (वैकल्पिक)',
                    hintText: 'जैसे: Ramesh Kumar',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('आगे बढ़ें / Continue'),
                ),
                const SizedBox(height: 16),

                // Privacy note
                const Center(
                  child: Text(
                    'आपका नंबर सुरक्षित है। कभी शेयर नहीं किया जाएगा।\nYour number is private and secure.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final storage = context.read<StorageService>();
    final api = context.read<ApiService>();
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();

    try {
      await storage.setPhone(phone);

      final result = await api.registerUser(
        phone: phone,
        language: storage.language,
        name: name.isNotEmpty ? name : null,
      );

      await storage.setUserId(result['userId'] as String);
      await storage.setToken(result['token'] as String);
      // Attach fresh token to api service
      api.updateToken(result['token'] as String);

      if (mounted) context.go(AppRoutes.welcome);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('नेटवर्क की समस्या है। बाद में कोशिश करें।'),
            action: SnackBarAction(
              label: 'Skip',
              onPressed: () => context.go(AppRoutes.welcome),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
