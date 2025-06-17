import 'package:perpustakaan_app/helpers/api_client.dart';
import 'package:perpustakaan_app/model/peminjaman.dart';

class PeminjamanService {
  final ApiClient api = ApiClient();

  Future<List<Peminjaman>> getAll() async {
    final res = await api.dio2.get('peminjaman');
    return (res.data as List).map((json) => Peminjaman.fromJson(json)).toList();
  }

  Future<void> create(Peminjaman peminjaman) async {
    await api.dio2.post('peminjaman', data: peminjaman.toJson());
  }

  Future<void> update(String id, Peminjaman peminjaman) async {
    await api.dio2.put('peminjaman/$id', data: peminjaman.toJson());
  }

  Future<void> delete(String id) async {
    await api.dio2.delete('peminjaman/$id');
  }
}
