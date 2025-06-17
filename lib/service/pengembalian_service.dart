import 'package:perpustakaan_app/helpers/api_client.dart';
import 'package:perpustakaan_app/model/pengembalian.dart';

class PengembalianService {
  final ApiClient api = ApiClient();

  // Ambil semua data pengembalian
  Future<List<Pengembalian>> getAll() async {
    final res = await api.dio3.get('pengembalian'); // endpoint dari MockAPI kamu
    return (res.data as List)
        .map((json) => Pengembalian.fromJson(json))
        .toList();
  }

  // Tambahkan data pengembalian baru
  Future<void> create(Pengembalian pengembalian) async {
    await api.dio3.post('pengembalian', data: pengembalian.toJson());
  }

  // Hapus data pengembalian
  Future<void> delete(String id) async {
    await api.dio3.delete('pengembalian/$id');
  }
}
