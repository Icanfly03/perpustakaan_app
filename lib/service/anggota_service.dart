import 'package:perpustakaan_app/helpers/api_client.dart';
import 'package:perpustakaan_app/model/anggota.dart';

class AnggotaService {
  final ApiClient api = ApiClient();

  Future<List<Anggota>> getAll() async {
    final res = await api.dio2.get('anggota');
    return (res.data as List).map((json) => Anggota.fromJson(json)).toList();
  }

  Future<void> create(Anggota anggota) async {
    await api.dio2.post('anggota', data: anggota.toJson());
  }

  Future<void> update(String id, Anggota anggota) async {
    await api.dio2.put('anggota/$id', data: anggota.toJson());
  }

  Future<void> delete(String id) async {
    await api.dio2.delete('anggota/$id');
  }
}
