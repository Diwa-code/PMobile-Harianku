import '../models/transaction_model.dart';

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
}