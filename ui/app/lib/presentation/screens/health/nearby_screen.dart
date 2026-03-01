import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
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
  late StorageService _storage;
  List<Map<String, dynamic>> _facilities = [];
  bool _isLoading = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _apiService = context.read<ApiService>();
    _storage = context.read<StorageService>();
    _initPincodeAndSearch();
  }

  /// Pre-fill pincode from storage or default (Kota 324008) and trigger search once on open.
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
      appBar: AppBar(title: Text(strings.nearbyClinics)),
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
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 52),
                  ),
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_hospital_outlined, size: 64, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          Text(strings.enterPincode,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        ],
                      ),
                    )
                  : _facilities.isEmpty
                      ? Center(child: Text(strings.noFacilitiesFound))
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
    final strings = AppStrings.forLanguage(context.read<StorageService>().language);
    if (pincode.length != AppConstants.pincodeLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.pincodeError)),
      );
      return;
    }
    setState(() { _isLoading = true; _searched = false; });
    try {
      final results = await _apiService.getNearbyFacilities(pincode);
      await _storage.setLastSearchedPincode(pincode);
      setState(() { _facilities = results; _searched = true; });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.networkError)),
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
