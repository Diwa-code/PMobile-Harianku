import '../models/transaction_model.dart';

enum PeriodeCashflow { harian, mingguan, bulanan }

class CashflowService {
  static const String tipePemasukan = 'income';
  static const String tipePengeluaran = 'expense';

  // Total semua transaksi bertipe income
  static double totalPemasukan(List<TransactionModel> daftar) {
    return daftar
        .where((t) => t.type == tipePemasukan)
        .fold(0.0, (jumlah, t) => jumlah + t.amount);
  }

  // Total semua transaksi bertipe expense
  static double totalPengeluaran(List<TransactionModel> daftar) {
    return daftar
        .where((t) => t.type == tipePengeluaran)
        .fold(0.0, (jumlah, t) => jumlah + t.amount);
  }

  // Saldo = pemasukan - pengeluaran
  static double saldo(List<TransactionModel> daftar) {
    return totalPemasukan(daftar) - totalPengeluaran(daftar);
  }

  // Saring transaksi yang jatuh pada periode yang mengandung tanggal [acuan].
  // Mingguan dihitung Senin sampai Minggu.
  static List<TransactionModel> filterPeriode(
    List<TransactionModel> daftar,
    PeriodeCashflow periode,
    DateTime acuan,
  ) {
    final (awal, akhir) = switch (periode) {
      PeriodeCashflow.harian => (
          DateTime(acuan.year, acuan.month, acuan.day),
          DateTime(acuan.year, acuan.month, acuan.day + 1),
        ),
      PeriodeCashflow.mingguan => (
          DateTime(acuan.year, acuan.month, acuan.day - (acuan.weekday - 1)),
          DateTime(acuan.year, acuan.month, acuan.day - (acuan.weekday - 1) + 7),
        ),
      PeriodeCashflow.bulanan => (
          DateTime(acuan.year, acuan.month, 1),
          DateTime(acuan.year, acuan.month + 1, 1),
        ),
    };

    return daftar.where((t) {
      final tanggal = DateTime.tryParse(t.date);
      if (tanggal == null) return false;
      return !tanggal.isBefore(awal) && tanggal.isBefore(akhir);
    }).toList();
  }
}