class Anggota {
  final String id;
  final String nama;
  final String nim;
  final String jurusan;

  Anggota({
    required this.id,
    required this.nama,
    required this.nim,
    required this.jurusan,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) => Anggota(
    id: json['id'],
    nama: json['nama'],
    nim: json['nim'],
    jurusan: json['jurusan'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,          // ← wajib disertakan untuk sinkronisasi dengan MockAPI
    'nama': nama,
    'nim': nim,
    'jurusan': jurusan,
  };
}
