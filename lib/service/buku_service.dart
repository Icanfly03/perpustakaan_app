import 'package:dio/dio.dart';
import 'package:perpustakaan_app/model/buku.dart';

class BukuService {
  final Dio _dio = Dio();
  final String url = 'https://684e4d63f0c9c9848d27ca3b.mockapi.io/buku'; // URL penuh Akun 1 (Buku)

  Future<List<Buku>> getAll() async {
    final res = await _dio.get(url);
    return (res.data as List).map((json) => Buku.fromJson(json)).toList();
  }

  Future<void> create(Buku buku) async {
    await _dio.post(url, data: buku.toJson());
  }

  Future<void> update(String id, Buku buku) async {
    await _dio.put('$url/$id', data: buku.toJson());
  }

  Future<void> delete(String id) async {
    await _dio.delete('$url/$id');
  }
}
