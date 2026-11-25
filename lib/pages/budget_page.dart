import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  static const _primaryColor = Color(0xFF1E3A8A);
  static const _darkBlue = Color(0xFF072369);
  static const _neutralPrimary = Color(0xFF171B29);
  static const _neutralSecondary = Color(0xFF8A90A0);
  static const _surfaceSoft = Color(0xFFEEF1FA);
  static const _borderColor = Color(0xFFECEEF3);

  static const _safeColor = Color(0xFF10B981);
  static const _warningColor = Color(0xFFF59E0B);
  static const _criticalColor = Color(0xFFEF4444);

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
        return 'Terkendali';
      case BudgetStatus.warning:
        return 'Mendekati Limit';
      case BudgetStatus.critical:
        return 'Melebihi Limit';
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
    final periodLabel = DateFormat('MMM yyyy').format(periodDate);
    final warningItems = provider.budgetProgressList
        .where((b) => b.percentage >= 75)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Harianku',
              style: TextStyle(
                color: _neutralPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              'Anggaran Bulanan',
              style: TextStyle(
                color: _neutralSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
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
                  _buildTopActionRow(context, provider, periodLabel),
                  const SizedBox(height: 16),
                  _buildHeroOverviewCard(provider),
                  if (warningItems.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildWarningBanner(warningItems.first),
                  ],
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kategori Anggaran',
                            style: TextStyle(
                              color: _neutralPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Realisasi per pos pengeluaran',
                            style: TextStyle(
                              color: _neutralSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _surfaceSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${provider.budgetProgressList.length} Kategori',
                          style: const TextStyle(
                            color: _primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (provider.budgetProgressList.isEmpty)
                    _buildEmptyState(context, provider)
                  else
                    for (final item in provider.budgetProgressList) ...[
                      _buildBudgetItemCard(context, provider, item),
                      const SizedBox(height: 12),
                    ],
                  const SizedBox(height: 8),
                  _buildBottomAdjustButton(context, provider),
                ],
              ),
            ),
    );
  }

  Widget _buildTopActionRow(
    BuildContext context,
    FinanceProvider provider,
    String periodLabel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: _surfaceSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => _changeMonth(provider, -1),
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 18,
                    color: _neutralPrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  periodLabel,
                  style: const TextStyle(
                    color: _neutralPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _changeMonth(provider, 1),
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: _neutralPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddBudgetDialog(context, provider),
          icon: const Icon(Icons.add_circle_outline_rounded, size: 17),
          label: const Text(
            'Atur Budget',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroOverviewCard(FinanceProvider provider) {
    final totalBudget = provider.totalBudget;
    final totalSpent = provider.totalSpent;
    final totalRemaining = provider.totalRemaining;
    final usedPct =
        totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0.0;
    final availPct = (100 - usedPct).clamp(0.0, 100.0);

    final now = DateTime.now();
    final daysInMonth =
        DateUtils.getDaysInMonth(provider.selectedYear, provider.selectedMonth);
    final remainingDays = (provider.selectedYear == now.year &&
            provider.selectedMonth == now.month)
        ? (daysInMonth - now.day).clamp(1, daysInMonth)
        : daysInMonth;
    final safeDaily = totalRemaining > 0 ? totalRemaining / remainingDays : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_darkBlue, _primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'STATUS ANGGARAN BULANAN',
                style: TextStyle(
                  color: Color(0xFFB6C4FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 7,
                      color: Color(0xFF69DCA1),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Aktif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.formatRupiah(totalBudget),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (usedPct / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF69DCA1),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terpakai ${usedPct.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFFDCE1FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Tersedia ${availPct.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFFDCE1FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Terpakai',
                        style: TextStyle(
                          color: Color(0xFFB6C4FF),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatRupiah(totalSpent),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sisa Anggaran',
                        style: TextStyle(
                          color: Color(0xFFB6C4FF),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatRupiah(totalRemaining),
                        style: TextStyle(
                          color: totalRemaining < 0
                              ? const Color(0xFFFFB3B3)
                              : const Color(0xFF69DCA1),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.speed_rounded,
                size: 16,
                color: Color(0xFF69DCA1),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Sisa $remainingDays hari lagi. Rata-rata aman: ${CurrencyFormatter.formatRupiah(safeDaily)}/hari.',
                  style: const TextStyle(
                    color: Color(0xFFDCE1FF),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(BudgetProgress item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFDAD9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFFFDAD9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFB91C1C),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Batas Kuota Hampir Penuh',
                  style: TextStyle(
                    color: _neutralPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kategori ${item.category.name} sudah mencapai ${item.percentage.toStringAsFixed(0)}% dari kuota bulanan.',
                  style: const TextStyle(
                    color: Color(0xFF444651),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
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
        borderRadius: BorderRadius.circular(18),
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
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
                        'Kapasitas ${CurrencyFormatter.formatRupiah(item.budget.limitAmount)}',
                        style: const TextStyle(
                          color: _neutralSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOverBudget
                          ? 'Lebih ${CurrencyFormatter.formatRupiah(item.remaining.abs())}'
                          : 'Sisa ${CurrencyFormatter.formatRupiah(item.remaining)}',
                      style: TextStyle(
                        color: isOverBudget
                            ? _criticalColor
                            : _neutralSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 7,
                backgroundColor: _surfaceSoft,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terpakai ${CurrencyFormatter.formatRupiah(item.spentAmount)}',
                  style: const TextStyle(
                    color: _neutralPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _statusLabel(item.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAdjustButton(
    BuildContext context,
    FinanceProvider provider,
  ) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => _showAddBudgetDialog(context, provider),
        icon: const Icon(Icons.tune_rounded, size: 18),
        label: const Text(
          'Sesuaikan Kuota Anggaran',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE4E7FB),
          foregroundColor: _neutralPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
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
