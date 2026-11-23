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

  // Objek -> Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipe': tipe.name,
      'nominal': nominal,
      'kategori': kategori,
      'tanggal': tanggal.toIso8601String(),
      'catatan': catatan,
    };
  }

  // Map -> Objek (untuk dibaca dari database)
  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'] as String,
      tipe: TipeTransaksi.values.byName(map['tipe'] as String),
      nominal: (map['nominal'] as num).toDouble(),
      kategori: map['kategori'] as String,
      tanggal: DateTime.parse(map['tanggal'] as String),
      catatan: map['catatan'] as String?,
    );
  }

  // Buat salinan Transaksi dengan sebagian field diganti (dipakai saat edit)
  Transaksi copyWith({
    String? id,
    TipeTransaksi? tipe,
    double? nominal,
    String? kategori,
    DateTime? tanggal,
    String? catatan,
  }) {
    return Transaksi(
      id: id ?? this.id,
      tipe: tipe ?? this.tipe,
      nominal: nominal ?? this.nominal,
      kategori: kategori ?? this.kategori,
      tanggal: tanggal ?? this.tanggal,
      catatan: catatan ?? this.catatan,
    );
  }
}