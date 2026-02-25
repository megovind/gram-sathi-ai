import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/storage_service.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  final _pincodeController = TextEditingController();
  late ApiService _apiService;
  List<Map<String, dynamic>> _facilities = [];
  bool _isLoading = false;
  bool _searched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.nearbyClinics)),
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
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 52),
                  ),
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
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_hospital_outlined, size: 64, color: AppColors.textHint),
                          SizedBox(height: 12),
                          Text('अपना पिनकोड डालें',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        ],
                      ),
                    )
                  : _facilities.isEmpty
                      ? const Center(child: Text('इस पिनकोड में कोई सेवा नहीं मिली'))
                      : ListView.separated(
                          itemCount: _facilities.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _FacilityCard(facility: _facilities[i]),
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
      final results = await _apiService.getNearbyFacilities(pincode);
      setState(() { _facilities = results; _searched = true; });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.networkError)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class _FacilityCard extends StatelessWidget {
  final Map<String, dynamic> facility;
  const _FacilityCard({required this.facility});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  facility['category'] == 'pharmacy'
                      ? Icons.local_pharmacy_outlined
                      : Icons.local_hospital_outlined,
                  color: AppColors.secondary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility['name'] as String? ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    if (facility['address'] != null)
                      Text(
                        facility['address'] as String,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    Text(
                      facility['phone'] as String? ?? '',
                      style: const TextStyle(color: AppColors.primary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
