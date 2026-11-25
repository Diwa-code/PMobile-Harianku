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
  static const _primaryColor = Color(0xFF1E3A8A);
  static const _expenseColor = Color(0xFFB91C1C);
  static const _incomeColor = Color(0xFF047857);
  static const _neutralPrimary = Color(0xFF171B29);
  static const _neutralSecondary = Color(0xFF8A90A0);
  static const _surfaceSoft = Color(0xFFEEF1FA);
  static const _borderColor = Color(0xFFECEEF3);

  String _selectedType = 'expense';
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

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

  void _addQuickAmount(int addValue) {
    final current = _parsedAmount.round();
    final next = current + addValue;
    final formatted = CurrencyFormatter.formatNumber(next);
    setState(() {
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
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

  void _resetForm() {
    setState(() {
      _amountController.clear();
      _titleController.clear();
      _noteController.clear();
      _selectedCategoryId = null;
      _selectedDate = DateTime.now();
    });
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

    final titleText = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : selectedCategory.name;

    final success = await provider.addTransaction(
      title: titleText,
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
          backgroundColor:
              _selectedType == 'expense' ? _expenseColor : _incomeColor,
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

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final formatted = DateFormat('dd MMM yyyy').format(date);
    return isToday ? 'Hari Ini, $formatted' : formatted;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final categories = provider.getCategoriesByType(_selectedType);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        surfaceTintColor: const Color(0xFFF8F9FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          color: _neutralPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Catat Transaksi',
          style: TextStyle(
            color: _neutralPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSubHeader(),
              const SizedBox(height: 12),
              _buildTypeSelector(),
              const SizedBox(height: 16),
              _buildAmountCard(),
              const SizedBox(height: 14),
              _buildDescriptionCard(),
              const SizedBox(height: 12),
              _buildDateCard(),
              const SizedBox(height: 20),
              _buildCategorySection(categories),
              const SizedBox(height: 16),
              _buildNoteCard(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _selectedType == 'expense'
                    ? _expenseColor
                    : _incomeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ENTRI BARU',
              style: TextStyle(
                color: _neutralSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: _resetForm,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _surfaceSoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, size: 15, color: _neutralPrimary),
                SizedBox(width: 4),
                Text(
                  'Reset',
                  style: TextStyle(
                    color: _neutralPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeSegmentButton(
              label: 'Pengeluaran',
              icon: Icons.arrow_downward_rounded,
              isSelected: _selectedType == 'expense',
              activeColor: _expenseColor,
              onTap: () => _onTypeChanged('expense'),
            ),
          ),
          Expanded(
            child: _TypeSegmentButton(
              label: 'Pemasukan',
              icon: Icons.arrow_upward_rounded,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          const Text(
            'NOMINAL TRANSAKSI',
            style: TextStyle(
              color: _neutralSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Rp ',
                style: TextStyle(
                  color: _neutralSecondary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  onChanged: (_) => setState(() {}),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _neutralPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: _neutralSecondary.withValues(alpha: 0.4),
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _QuickAmountChip(
                label: '+10rb',
                onTap: () => _addQuickAmount(10000),
              ),
              _QuickAmountChip(
                label: '+50rb',
                onTap: () => _addQuickAmount(50000),
              ),
              _QuickAmountChip(
                label: '+100rb',
                onTap: () => _addQuickAmount(100000),
              ),
              _QuickAmountChip(
                label: '+500rb',
                onTap: () => _addQuickAmount(500000),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: _primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deskripsi Transaksi',
                  style: TextStyle(
                    color: _neutralSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    color: _neutralPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Makan Siang',
                    hintStyle: TextStyle(
                      color: _neutralSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _surfaceSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: _primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tanggal Transaksi',
                    style: TextStyle(
                      color: _neutralSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDateLabel(_selectedDate),
                    style: const TextStyle(
                      color: _neutralPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _neutralSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(List<CategoryModel> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Kategori',
              style: TextStyle(
                color: _neutralPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _surfaceSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Wajib',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category.id == _selectedCategoryId;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    _selectedCategoryId = category.id;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _primaryColor : _borderColor,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.16)
                              : _surfaceSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          category.iconData,
                          color: isSelected ? Colors.white : category.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : _neutralPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildNoteCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: _neutralPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan Tambahan (Opsional)',
                  style: TextStyle(
                    color: _neutralSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  minLines: 1,
                  style: const TextStyle(
                    color: _neutralPrimary,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Tambahkan catatan singkat...',
                    hintStyle: TextStyle(
                      color: _neutralSecondary,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isFormValid ? _saveTransaction : null,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_outline_rounded),
        label: const Text(
          'Simpan Transaksi',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          disabledBackgroundColor: _borderColor,
          foregroundColor: Colors.white,
          disabledForegroundColor: _neutralSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _TypeSegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeSegmentButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : const Color(0xFF444651),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : const Color(0xFF444651),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF1FA),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
