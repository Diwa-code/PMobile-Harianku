enum TipeTransaksi { pemasukan, pengeluaran }

class Transaksi {
  final String id;
  final TipeTransaksi tipe;
  final double nominal;
  final String kategori;
  final DateTime tanggal;
  final String? catatan;

  const Transaksi({
    required this.id,
    required this.tipe,
    required this.nominal,
    required this.kategori,
    required this.tanggal,
    this.catatan,
  });
}