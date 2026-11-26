import 'package:flutter_test/flutter_test.dart';
import 'package:pmobile_harianku/models/transaction_model.dart';
import 'package:pmobile_harianku/services/cashflow_service.dart';

TransactionModel buat(String id, String type, double amount) {
  final tanggal = DateTime(2026, 11, 20).toIso8601String();
  return TransactionModel(
    id: id,
    title: 'Tes $id',
    amount: amount,
    type: type,
    categoryId: 'cat_tes',
    date: tanggal,
    source: 'manual',
    createdAt: tanggal,
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
}