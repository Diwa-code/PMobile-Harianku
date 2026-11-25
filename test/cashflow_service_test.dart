import 'package:flutter_test/flutter_test.dart';
import 'package:pmobile_harianku/data/dummy_transaksi.dart';
import 'package:pmobile_harianku/services/cashflow_service.dart';

void main() {
  test('hitung cashflow dari data dummy', () {
    expect(CashflowService.totalPemasukan(dummyTransaksi), 2300000);
    expect(CashflowService.totalPengeluaran(dummyTransaksi), 280000);
    expect(CashflowService.saldo(dummyTransaksi), 2020000);
  });

  test('daftar kosong menghasilkan saldo 0', () {
    expect(CashflowService.saldo([]), 0);
  });
}