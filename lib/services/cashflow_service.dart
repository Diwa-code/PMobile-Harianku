import '../models/transaction_model.dart';

enum PeriodeCashflow { mingguan, bulanan, tahunan }

// Satu batang pada grafik tren
class TitikTren {
  const TitikTren({
    required this.label,
    required this.pemasukan,
    required this.pengeluaran,
  });

  final String label;
  final double pemasukan;
  final double pengeluaran;
}

// Satu baris pada daftar pengeluaran per kategori
class PengeluaranKategori {
  const PengeluaranKategori({
    required this.categoryId,
    required this.total,
    required this.persen,
  });

  final String categoryId;
  final double total;
  final double persen;
}

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

  // Margin = saldo / pemasukan x 100. Jika tidak ada pemasukan, hasilnya 0.
  static double marginPersen(List<TransactionModel> daftar) {
    final pemasukan = totalPemasukan(daftar);
    if (pemasukan == 0) return 0;
    return saldo(daftar) / pemasukan * 100;
  }

  // Perubahan persen dari nilai lama ke nilai baru.
  // Hasil null jika nilai lama 0, karena persennya tidak bisa dihitung.
  static double? perubahanPersen(double sebelumnya, double sekarang) {
    if (sebelumnya == 0) return null;
    return (sekarang - sebelumnya) / sebelumnya * 100;
  }

  // Minggu ke-1 sampai ke-4 dalam sebulan. Tanggal 29 sampai 31 masuk minggu ke-4.
  static int _indeksMinggu(int hari) {
    final minggu = (hari - 1) ~/ 7;
    return minggu > 3 ? 3 : minggu;
  }

  // Data batang grafik tren untuk periode yang memuat [acuan].
  static List<TitikTren> tren(
    List<TransactionModel> daftar,
    PeriodeCashflow periode,
    DateTime acuan,
  ) {
    const namaHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const namaBulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    final List<String> label = switch (periode) {
      PeriodeCashflow.mingguan => namaHari,
      PeriodeCashflow.bulanan => ['Mgg 1', 'Mgg 2', 'Mgg 3', 'Mgg 4'],
      PeriodeCashflow.tahunan => namaBulan,
    };

    final masuk = List<double>.filled(label.length, 0);
    final keluar = List<double>.filled(label.length, 0);

    for (final t in filterPeriode(daftar, periode, acuan)) {
      final tanggal = DateTime.tryParse(t.date);
      if (tanggal == null) continue;

      final i = switch (periode) {
        PeriodeCashflow.mingguan => tanggal.weekday - 1,
        PeriodeCashflow.bulanan => _indeksMinggu(tanggal.day),
        PeriodeCashflow.tahunan => tanggal.month - 1,
      };

      if (t.type == tipePemasukan) {
        masuk[i] += t.amount;
      } else if (t.type == tipePengeluaran) {
        keluar[i] += t.amount;
      }
    }

    return [
      for (var i = 0; i < label.length; i++)
        TitikTren(
          label: label[i],
          pemasukan: masuk[i],
          pengeluaran: keluar[i],
        ),
    ];
  }

  // Total pengeluaran per kategori, diurutkan dari yang terbesar.
  // Saring dulu dengan filterPeriode kalau hanya butuh satu periode.
  static List<PengeluaranKategori> pengeluaranPerKategori(
    List<TransactionModel> daftar,
  ) {
    final totalKeluar = totalPengeluaran(daftar);
    if (totalKeluar == 0) return [];

    final perKategori = <String, double>{};
    for (final t in daftar) {
      if (t.type != tipePengeluaran) continue;
      perKategori[t.categoryId] = (perKategori[t.categoryId] ?? 0) + t.amount;
    }

    final hasil = [
      for (final e in perKategori.entries)
        PengeluaranKategori(
          categoryId: e.key,
          total: e.value,
          persen: e.value / totalKeluar * 100,
        ),
    ];
    hasil.sort((a, b) => b.total.compareTo(a.total));
    return hasil;
  }
}