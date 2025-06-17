class Peminjaman {
  String id;
  String idBuku;
  String idAnggota;
  String tanggalPinjam;

  Peminjaman({
    required this.id,
    required this.idBuku,
    required this.idAnggota,
    required this.tanggalPinjam,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) => Peminjaman(
    id: json['id'],
    idBuku: json['idBuku'],
    idAnggota: json['idAnggota'],
    tanggalPinjam: json['tanggalPinjam'],
  );

  Map<String, dynamic> toJson() => {
    'idBuku': idBuku,
    'idAnggota': idAnggota,
    'tanggalPinjam': tanggalPinjam,
  };
}
