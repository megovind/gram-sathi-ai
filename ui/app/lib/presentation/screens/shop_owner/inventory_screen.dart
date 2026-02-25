import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.inventory),
        actions: [
          if (_newItems.isNotEmpty)
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: Text(
                'सेव करें (${_newItems.length})',
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
                Text(AppStrings.addItem,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(hintText: 'Item name (English)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _nameHindiController,
                        decoration: const InputDecoration(hintText: 'नाम (हिंदी)'),
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
                        decoration: const InputDecoration(
                          hintText: 'कीमत (₹)',
                          prefixText: '₹ ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _unitController,
                        decoration: const InputDecoration(hintText: 'यूनिट (kg, piece...)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'स्टॉक'),
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
                    label: const Text('सूची में जोड़ें'),
                  ),
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: _newItems.isEmpty
                ? const Center(
                    child: Text('ऊपर सामान जोड़ें और सेव करें',
                        style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _newItems.length,
                    itemBuilder: (_, i) => _ItemRow(
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

    if (name.isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('नाम और कीमत जरूरी है')),
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
        'unit': _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : 'piece',
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
          const SnackBar(content: Text('इन्वेंटरी सेव हो गई! ✓')),
        );
        setState(() => _newItems.clear());
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.networkError)),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
}

class _ItemRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  const _ItemRow({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
          title: Text(item['nameHindi'] ?? item['name']),
          subtitle: Text('₹${item['price']} / ${item['unit']} • स्टॉक: ${item['stockQty']}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: onDelete,
          ),
        ),
      );
}
