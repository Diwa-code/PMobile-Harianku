import '../models/transaction_model.dart';

enum PeriodeCashflow { mingguan, bulanan, tahunan }

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

  // Rentang periode yang memuat tanggal [acuan]. Batas akhir tidak ikut dihitung.
  // Mingguan dihitung Senin sampai Minggu.
  static (DateTime, DateTime) rentangPeriode(
    PeriodeCashflow periode,
    DateTime acuan,
  ) {
    switch (periode) {
      case PeriodeCashflow.mingguan:
        final senin = DateTime(
          acuan.year,
          acuan.month,
          acuan.day - (acuan.weekday - 1),
        );
        return (senin, DateTime(senin.year, senin.month, senin.day + 7));
      case PeriodeCashflow.bulanan:
        return (
          DateTime(acuan.year, acuan.month, 1),
          DateTime(acuan.year, acuan.month + 1, 1),
        );
      case PeriodeCashflow.tahunan:
        return (
          DateTime(acuan.year, 1, 1),
          DateTime(acuan.year + 1, 1, 1),
        );
    }
  }

  // Geser acuan maju (langkah positif) atau mundur (negatif), untuk tombol panah.
  static DateTime geserPeriode(
    PeriodeCashflow periode,
    DateTime acuan,
    int langkah,
  ) {
    switch (periode) {
      case PeriodeCashflow.mingguan:
        return DateTime(acuan.year, acuan.month, acuan.day + 7 * langkah);
      case PeriodeCashflow.bulanan:
        return DateTime(acuan.year, acuan.month + langkah, 1);
      case PeriodeCashflow.tahunan:
        return DateTime(acuan.year + langkah, 1, 1);
    }
  }

  // Saring transaksi yang jatuh pada periode yang memuat [acuan].
  static List<TransactionModel> filterPeriode(
    List<TransactionModel> daftar,
    PeriodeCashflow periode,
    DateTime acuan,
  ) {
    final (awal, akhir) = rentangPeriode(periode, acuan);

    return daftar.where((t) {
      final tanggal = DateTime.tryParse(t.date);
      if (tanggal == null) return false;
      return !tanggal.isBefore(awal) && tanggal.isBefore(akhir);
    }).toList();
  }
}