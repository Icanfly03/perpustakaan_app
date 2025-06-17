class Buku {
  final String id;
  final String judul;
  final String pengarang;
  final String tahunTerbit;

  Buku({
    required this.id,
    required this.judul,
    required this.pengarang,
    required this.tahunTerbit
  });

  factory Buku.fromJson(Map<String, dynamic> json) => Buku(
    id: json['id'],
    judul: json['judul'],
    pengarang: json['pengarang'],
    tahunTerbit: json['tahunTerbit'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, // tambahkan ID agar lengkap
    'judul': judul,
    'pengarang': pengarang,
    'tahunTerbit': tahunTerbit,
  };
}
