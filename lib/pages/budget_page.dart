import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  static const _primaryColor = Color(0xFF253B80);
  static const _neutralPrimary = Color(0xFF202432);
  static const _neutralSecondary = Color(0xFF8A90A0);
  static const _borderColor = Color(0xFFECEEF3);

  static const _safeColor = Color(0xFF10B981); // Hijau < 75%
  static const _warningColor = Color(0xFFF59E0B); // Amber 75% - 95%
  static const _criticalColor = Color(0xFFEF4444); // Merah > 95%

  Color _statusColor(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.safe:
        return _safeColor;
      case BudgetStatus.warning:
        return _warningColor;
      case BudgetStatus.critical:
        return _criticalColor;
    }
  }

  String _statusLabel(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.safe:
        return 'Aman';
      case BudgetStatus.warning:
        return 'Waspada';
      case BudgetStatus.critical:
        return 'Kritis';
    }
  }

  void _changeMonth(FinanceProvider provider, int delta) {
    var month = provider.selectedMonth + delta;
    var year = provider.selectedYear;
    if (month < 1) {
      month = 12;
      year -= 1;
    } else if (month > 12) {
      month = 1;
      year += 1;
    }
    provider.setBudgetPeriod(month, year);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final periodDate = DateTime(provider.selectedYear, provider.selectedMonth);
    final periodLabel = DateFormat('MMMM yyyy').format(periodDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Manajemen Budget',
          style: TextStyle(
            color: _neutralPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddBudgetDialog(context, provider),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: _primaryColor,
            tooltip: 'Tambah Budget',
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _borderColor),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.fetchBudgets,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildPeriodSelector(provider, periodLabel),
                  const SizedBox(height: 16),
                  _buildOverviewCard(provider),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Budget per Kategori',
                        style: TextStyle(
                          color: _neutralPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _showAddBudgetDialog(context, provider),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Tambah'),
                        style: TextButton.styleFrom(
                          foregroundColor: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (provider.budgetProgressList.isEmpty)
                    _buildEmptyState(context, provider)
                  else
                    for (final item in provider.budgetProgressList) ...[
                      _buildBudgetItemCard(context, provider, item),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector(FinanceProvider provider, String periodLabel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(provider, -1),
            icon: const Icon(Icons.chevron_left_rounded),
            color: _neutralPrimary,
          ),
          Text(
            periodLabel,
            style: const TextStyle(
              color: _neutralPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(provider, 1),
            icon: const Icon(Icons.chevron_right_rounded),
            color: _neutralPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(FinanceProvider provider) {
    final totalBudget = provider.totalBudget;
    final totalSpent = provider.totalSpent;
    final totalRemaining = provider.totalRemaining;
    final isOver = totalRemaining < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Budget Bulan Ini',
            style: TextStyle(
              color: Color(0xFFB6C4FF),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.formatRupiah(totalBudget),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terpakai',
                      style: TextStyle(
                        color: Color(0xFFB6C4FF),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatRupiah(totalSpent),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sisa Budget',
                      style: TextStyle(
                        color: Color(0xFFB6C4FF),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatRupiah(totalRemaining),
                      style: TextStyle(
                        color: isOver ? const Color(0xFFFFB3B3) : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, FinanceProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 44,
            color: _neutralSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada budget untuk periode ini',
            style: TextStyle(
              color: _neutralPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tambahkan batas pengeluaran per kategori agar keuangan lebih terkontrol.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _neutralSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddBudgetDialog(context, provider),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Budget'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItemCard(
    BuildContext context,
    FinanceProvider provider,
    BudgetProgress item,
  ) {
    final statusColor = _statusColor(item.status);
    final progressValue = (item.percentage / 100).clamp(0.0, 1.0);
    final isOverBudget = item.remaining < 0;

    return InkWell(
      onTap: () => _showEditBudgetDialog(context, provider, item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.category.iconData,
                    color: item.category.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category.name,
                        style: const TextStyle(
                          color: _neutralPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Limit: ${CurrencyFormatter.formatRupiah(item.budget.limitAmount)}',
                        style: const TextStyle(
                          color: _neutralSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_statusLabel(item.status)} (${item.percentage.toStringAsFixed(0)}%)',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                backgroundColor: const Color(0xFFF2F3FF),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terpakai: ${CurrencyFormatter.formatRupiah(item.spentAmount)}',
                  style: const TextStyle(
                    color: _neutralSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isOverBudget
                      ? 'Melebihi: ${CurrencyFormatter.formatRupiah(item.remaining.abs())}'
                      : 'Sisa: ${CurrencyFormatter.formatRupiah(item.remaining)}',
                  style: TextStyle(
                    color: isOverBudget ? _criticalColor : _neutralPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddBudgetDialog(
    BuildContext context,
    FinanceProvider provider,
  ) async {
    final expenseCategories = provider.getCategoriesByType('expense');
    final existingCategoryIds =
        provider.budgetProgressList.map((b) => b.category.id).toSet();
    final availableCategories = expenseCategories
        .where((c) => !existingCategoryIds.contains(c.id))
        .toList();

    if (availableCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Semua kategori pengeluaran sudah memiliki budget pada periode ini.',
          ),
        ),
      );
      return;
    }

    CategoryModel selectedCategory = availableCategories.first;
    final amountController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final parsed =
                CurrencyFormatter.parseRupiah(amountController.text);
            return AlertDialog(
              title: const Text('Tambah Budget'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<CategoryModel>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori Pengeluaran',
                      border: OutlineInputBorder(),
                    ),
                    items: availableCategories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    onChanged: (_) => setDialogState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Limit Budget',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: parsed > 0
                      ? () async {
                          final ok = await provider.addBudget(
                            categoryId: selectedCategory.id,
                            limitAmount: parsed,
                          );
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Budget berhasil ditambahkan.'
                                    : (provider.errorMessage ??
                                        'Gagal menambahkan budget.'),
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditBudgetDialog(
    BuildContext context,
    FinanceProvider provider,
    BudgetProgress item,
  ) async {
    final amountController = TextEditingController(
      text: CurrencyFormatter.formatNumber(item.budget.limitAmount.round()),
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final parsed =
                CurrencyFormatter.parseRupiah(amountController.text);
            return AlertDialog(
              title: Text('Edit Budget ${item.category.name}'),
              content: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                onChanged: (_) => setDialogState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Limit Budget',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: parsed > 0
                      ? () async {
                          final ok = await provider.updateBudget(
                            item.budget,
                            parsed,
                          );
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Budget berhasil diperbarui.'
                                    : (provider.errorMessage ??
                                        'Gagal memperbarui budget.'),
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
