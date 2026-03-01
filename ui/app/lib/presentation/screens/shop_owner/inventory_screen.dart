import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/storage_service.dart';

class InventoryScreen extends StatefulWidget {
  final String shopId;
  const InventoryScreen({super.key, required this.shopId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late ApiService _apiService;
  final List<Map<String, dynamic>> _newItems = [];
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _nameHindiController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _qtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiService = context.read<ApiService>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameHindiController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final strings = AppStrings.forLanguage(storage.language);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.inventory),
        actions: [
          if (_newItems.isNotEmpty)
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: Text(
                '${strings.saveButton} (${_newItems.length})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Add item form
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.addItem,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(hintText: strings.itemNameHint),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _nameHindiController,
                        decoration: InputDecoration(hintText: strings.itemNameHindiHint),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: strings.priceHint,
                          prefixText: '${AppConstants.currencySymbol} ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _unitController,
                        decoration: InputDecoration(hintText: strings.unitHint),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: strings.stockHint),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: Text(strings.addToListButton),
                  ),
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: _newItems.isEmpty
                ? Center(
                    child: Text(strings.addItemsAbove,
                        style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _newItems.length,
                    itemBuilder: (_, i) => _ItemRow(
                      strings: strings,
                      item: _newItems[i],
                      onDelete: () => setState(() => _newItems.removeAt(i)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final strings = AppStrings.forLanguage(context.read<StorageService>().language);

    if (name.isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.nameAndPriceRequired)),
      );
      return;
    }

    setState(() {
      _newItems.add({
        'name': name,
        'nameHindi': _nameHindiController.text.trim().isNotEmpty
            ? _nameHindiController.text.trim()
            : null,
        'price': price,
        'unit': _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : AppConstants.defaultInventoryUnit,
        'stockQty': int.tryParse(_qtyController.text.trim()) ?? 0,
      });
    });

    _nameController.clear();
    _nameHindiController.clear();
    _priceController.clear();
    _unitController.clear();
    _qtyController.clear();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await _apiService.updateInventory(
        shopId: widget.shopId,
        items: _newItems,
        replace: false,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.forLanguage(context.read<StorageService>().language).inventorySaved)),
        );
        setState(() => _newItems.clear());
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.forLanguage(context.read<StorageService>().language).networkError)),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
}

class _ItemRow extends StatelessWidget {
  final LocalizedStrings strings;
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  const _ItemRow({required this.strings, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
          title: Text(item['nameHindi'] ?? item['name']),
          subtitle: Text('₹${item['price']} / ${item['unit']} • ${strings.stockLabel}: ${item['stockQty']}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: onDelete,
          ),
        ),
      );
}
