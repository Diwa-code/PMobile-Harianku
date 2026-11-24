import '../models/transaksi.dart';

// Data contoh untuk testing UI Cashflow dan Histori.
// Tanggal dibuat relatif terhadap hari ini supaya selalu terlihat "baru".
final List<Transaksi> dummyTransaksi = [
  Transaksi(
    id: 't1',
    tipe: TipeTransaksi.pemasukan,
    nominal: 2000000,
    kategori: 'Uang Saku',
    tanggal: DateTime.now().subtract(const Duration(days: 6)),
    catatan: 'Kiriman bulanan',
  ),
  Transaksi(
    id: 't2',
    tipe: TipeTransaksi.pengeluaran,
    nominal: 25000,
    kategori: 'Makanan',
    tanggal: DateTime.now().subtract(const Duration(days: 5)),
    catatan: 'Makan siang',
  ),
  Transaksi(
    id: 't3',
    tipe: TipeTransaksi.pengeluaran,
    nominal: 150000,
    kategori: 'Transportasi',
    tanggal: DateTime.now().subtract(const Duration(days: 3)),
    catatan: 'Isi bensin',
  ),
  Transaksi(
    id: 't4',
    tipe: TipeTransaksi.pemasukan,
    nominal: 300000,
    kategori: 'Freelance',
    tanggal: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Transaksi(
    id: 't5',
    tipe: TipeTransaksi.pengeluaran,
    nominal: 75000,
    kategori: 'Hiburan',
    tanggal: DateTime.now().subtract(const Duration(days: 1)),
    catatan: 'Nonton bioskop',
  ),
  Transaksi(
    id: 't6',
    tipe: TipeTransaksi.pengeluaran,
    nominal: 30000,
    kategori: 'Makanan',
    tanggal: DateTime.now(),
  ),
];