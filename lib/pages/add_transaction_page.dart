import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  static const _primaryColor = Color(0xFF253B80);
  static const _expenseColor = Color(0xFFE45B64); // Coral Red
  static const _incomeColor = Color(0xFF22A06B); // Emerald Green
  static const _neutralPrimary = Color(0xFF202432);
  static const _neutralSecondary = Color(0xFF8A90A0);
  static const _borderColor = Color(0xFFECEEF3);

  String _selectedType = 'expense'; // Default Pengeluaran
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Color get _activeAccentColor =>
      _selectedType == 'expense' ? _expenseColor : _incomeColor;

  double get _parsedAmount =>
      CurrencyFormatter.parseRupiah(_amountController.text);

  bool get _isFormValid =>
      _parsedAmount > 0 && _selectedCategoryId != null && !_isSaving;

  void _onTypeChanged(String newType) {
    if (_selectedType == newType) return;
    setState(() {
      _selectedType = newType;
      _selectedCategoryId = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_isFormValid) return;

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<FinanceProvider>();
    final categories = provider.getCategoriesByType(_selectedType);
    final selectedCategory = categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => categories.first,
    );

    final success = await provider.addTransaction(
      title: selectedCategory.name,
      amount: _parsedAmount,
      type: _selectedType,
      categoryId: selectedCategory.id,
      date: _selectedDate,
      note: _noteController.text,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedType == 'expense'
                ? 'Pengeluaran berhasil disimpan.'
                : 'Pemasukan berhasil disimpan.',
          ),
          backgroundColor: _activeAccentColor,
        ),
      );
      _resetForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Gagal menyimpan transaksi.',
          ),
          backgroundColor: _expenseColor,
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _amountController.clear();
      _noteController.clear();
      _selectedCategoryId = null;
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final categories = provider.getCategoriesByType(_selectedType);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Catat Transaksi',
          style: TextStyle(
            color: _neutralPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _borderColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTypeSelector(),
              const SizedBox(height: 20),
              _buildAmountCard(),
              const SizedBox(height: 20),
              _buildCategorySection(categories),
              const SizedBox(height: 20),
              _buildDateAndNoteCard(),
              const SizedBox(height: 28),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeSegmentButton(
              label: 'Pengeluaran',
              isSelected: _selectedType == 'expense',
              activeColor: _expenseColor,
              onTap: () => _onTypeChanged('expense'),
            ),
          ),
          Expanded(
            child: _TypeSegmentButton(
              label: 'Pemasukan',
              isSelected: _selectedType == 'income',
              activeColor: _incomeColor,
              onTap: () => _onTypeChanged('income'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nominal',
            style: TextStyle(
              color: _neutralSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              color: _activeAccentColor,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: TextStyle(
                color: _activeAccentColor,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
              hintText: '0',
              hintStyle: TextStyle(
                color: _neutralSecondary.withValues(alpha: 0.4),
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(List<CategoryModel> categories) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Kategori',
            style: TextStyle(
              color: _neutralPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Kategori belum tersedia.',
                  style: TextStyle(color: _neutralSecondary),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category.id == _selectedCategoryId;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category.id;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category.color.withValues(alpha: 0.12)
                          : const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? category.color : _borderColor,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category.iconData,
                          color: category.color,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? _neutralPrimary
                                : _neutralSecondary,
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDateAndNoteCard() {
    final formattedDate = DateFormat('dd MMM yyyy').format(_selectedDate);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: _primaryColor,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tanggal',
                    style: TextStyle(
                      color: _neutralSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: _neutralPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _neutralSecondary,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 20, color: _borderColor),
          TextField(
            controller: _noteController,
            maxLines: 2,
            minLines: 1,
            decoration: const InputDecoration(
              icon: Icon(
                Icons.notes_rounded,
                size: 20,
                color: _neutralSecondary,
              ),
              hintText: 'Catatan (opsional)',
              hintStyle: TextStyle(color: _neutralSecondary, fontSize: 14),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isFormValid ? _saveTransaction : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _activeAccentColor,
          disabledBackgroundColor: _borderColor,
          foregroundColor: Colors.white,
          disabledForegroundColor: _neutralSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Simpan Transaksi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _TypeSegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeSegmentButton({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? activeColor : const Color(0xFF8A90A0),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
