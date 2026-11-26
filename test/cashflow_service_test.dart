import 'package:flutter_test/flutter_test.dart';
import 'package:pmobile_harianku/models/transaction_model.dart';
import 'package:pmobile_harianku/services/cashflow_service.dart';

TransactionModel buat(
  String id,
  String type,
  double amount, {
  DateTime? tanggal,
}) {
  final iso = (tanggal ?? DateTime(2026, 11, 20)).toIso8601String();
  return TransactionModel(
    id: id,
    title: 'Tes $id',
    amount: amount,
    type: type,
    categoryId: 'cat_tes',
    date: iso,
    source: 'manual',
    createdAt: iso,
  );
}

void main() {
  final data = [
    buat('t1', 'income', 2000000),
    buat('t2', 'expense', 25000),
    buat('t3', 'expense', 150000),
    buat('t4', 'income', 300000),
    buat('t5', 'expense', 75000),
    buat('t6', 'expense', 30000),
  ];

  test('hitung pemasukan, pengeluaran, dan saldo', () {
    expect(CashflowService.totalPemasukan(data), 2300000);
    expect(CashflowService.totalPengeluaran(data), 280000);
    expect(CashflowService.saldo(data), 2020000);
  });

  test('daftar kosong menghasilkan saldo 0', () {
    expect(CashflowService.saldo([]), 0);
  });

  test('tipe selain income dan expense diabaikan', () {
    final lain = [buat('x1', 'transfer', 500000)];
    expect(CashflowService.saldo(lain), 0);
  });

  group('filterPeriode', () {
    // Acuan: Kamis, 26 November 2026 (minggu itu: Senin 23 sampai Minggu 29)
    final acuan = DateTime(2026, 11, 26);

    final tanggalan = [
      buat('a', 'income', 100000, tanggal: DateTime(2026, 11, 26, 8, 0)),
      buat('b', 'expense', 20000, tanggal: DateTime(2026, 11, 26, 23, 59)),
      buat('c', 'expense', 30000, tanggal: DateTime(2026, 11, 24)),
      buat('d', 'expense', 40000, tanggal: DateTime(2026, 11, 22)),
      buat('e', 'expense', 50000, tanggal: DateTime(2026, 11, 30)),
      buat('f', 'expense', 60000, tanggal: DateTime(2026, 10, 25)),
      buat('g', 'expense', 70000, tanggal: DateTime(2026, 1, 5)),
      buat('h', 'expense', 80000, tanggal: DateTime(2025, 12, 31)),
    ];

    List<String> idHasil(PeriodeCashflow p) => CashflowService
        .filterPeriode(tanggalan, p, acuan)
        .map((t) => t.id)
        .toList();

    test('mingguan mengambil Senin sampai Minggu', () {
      expect(idHasil(PeriodeCashflow.mingguan), ['a', 'b', 'c']);
    });

    test('bulanan mengambil seluruh transaksi di bulan yang sama', () {
      expect(idHasil(PeriodeCashflow.bulanan), ['a', 'b', 'c', 'd', 'e']);
    });

    test('tahunan mengambil seluruh transaksi di tahun yang sama', () {
      expect(
        idHasil(PeriodeCashflow.tahunan),
        ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
      );
    });

    test('saldo dihitung dari hasil filter', () {
      final bulanIni = CashflowService.filterPeriode(
        tanggalan,
        PeriodeCashflow.bulanan,
        acuan,
      );
      expect(CashflowService.saldo(bulanIni), -40000);
    });

    test('tanggal yang tidak valid diabaikan', () {
      final rusak = TransactionModel(
        id: 'z',
        title: 'rusak',
        amount: 1000,
        type: 'income',
        categoryId: 'cat_tes',
        date: 'bukan-tanggal',
        source: 'manual',
        createdAt: 'bukan-tanggal',
      );
      expect(
        CashflowService.filterPeriode([rusak], PeriodeCashflow.bulanan, acuan),
        isEmpty,
      );
    });
  });

  group('rentangPeriode', () {
    test('mingguan dimulai Senin dan berakhir sebelum Senin berikutnya', () {
      // Minggu, 29 November 2026 masih satu minggu dengan Senin 23 November
      final (awal, akhir) = CashflowService.rentangPeriode(
        PeriodeCashflow.mingguan,
        DateTime(2026, 11, 29),
      );
      expect(awal, DateTime(2026, 11, 23));
      expect(akhir, DateTime(2026, 11, 30));
    });

    test('bulanan Desember berakhir pada 1 Januari tahun berikutnya', () {
      final (awal, akhir) = CashflowService.rentangPeriode(
        PeriodeCashflow.bulanan,
        DateTime(2026, 12, 15),
      );
      expect(awal, DateTime(2026, 12, 1));
      expect(akhir, DateTime(2027, 1, 1));
    });

    test('tahunan dari 1 Januari sampai 1 Januari berikutnya', () {
      final (awal, akhir) = CashflowService.rentangPeriode(
        PeriodeCashflow.tahunan,
        DateTime(2026, 6, 10),
      );
      expect(awal, DateTime(2026, 1, 1));
      expect(akhir, DateTime(2027, 1, 1));
    });
  });

  group('geserPeriode', () {
    test('mingguan maju dan mundur 7 hari', () {
      final acuan = DateTime(2026, 11, 26);
      expect(
        CashflowService.geserPeriode(PeriodeCashflow.mingguan, acuan, 1),
        DateTime(2026, 12, 3),
      );
      expect(
        CashflowService.geserPeriode(PeriodeCashflow.mingguan, acuan, -1),
        DateTime(2026, 11, 19),
      );
    });

    test('bulanan selalu mendarat di tanggal 1', () {
      expect(
        CashflowService.geserPeriode(
          PeriodeCashflow.bulanan,
          DateTime(2026, 1, 31),
          1,
        ),
        DateTime(2026, 2, 1),
      );
      expect(
        CashflowService.geserPeriode(
          PeriodeCashflow.bulanan,
          DateTime(2026, 1, 15),
          -1,
        ),
        DateTime(2025, 12, 1),
      );
    });

    test('tahunan maju satu tahun', () {
      expect(
        CashflowService.geserPeriode(
          PeriodeCashflow.tahunan,
          DateTime(2026, 6, 10),
          1,
        ),
        DateTime(2027, 1, 1),
      );
    });
  });
}