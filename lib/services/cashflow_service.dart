import '../models/transaksi.dart';

class CashflowService {
  // Total semua transaksi bertipe pemasukan
  static double totalPemasukan(List<Transaksi> daftar) {
    return daftar
        .where((t) => t.tipe == TipeTransaksi.pemasukan)
        .fold(0.0, (jumlah, t) => jumlah + t.nominal);
  }

  // Total semua transaksi bertipe pengeluaran
  static double totalPengeluaran(List<Transaksi> daftar) {
    return daftar
        .where((t) => t.tipe == TipeTransaksi.pengeluaran)
        .fold(0.0, (jumlah, t) => jumlah + t.nominal);
  }

  // Saldo = pemasukan - pengeluaran
  static double saldo(List<Transaksi> daftar) {
    return totalPemasukan(daftar) - totalPengeluaran(daftar);
  }
}