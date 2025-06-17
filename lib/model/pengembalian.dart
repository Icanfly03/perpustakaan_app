class Pengembalian {
  final String id;
  final String idAnggota;
  final String idBuku;
  final String tanggalPengembalian;

  Pengembalian({
    required this.id,
    required this.idAnggota,
    required this.idBuku,
    required this.tanggalPengembalian,
  });

  factory Pengembalian.fromJson(Map<String, dynamic> json) => Pengembalian(
        id: json['id'],
        idAnggota: json['idAnggota'],
        idBuku: json['idBuku'],
        tanggalPengembalian: json['tanggalPengembalian'],
      );

  Map<String, dynamic> toJson() => {
        'idAnggota': idAnggota,
        'idBuku': idBuku,
        'tanggalPengembalian': tanggalPengembalian,
      };
}
