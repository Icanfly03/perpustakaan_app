import 'package:perpustakaan_app/helpers/api_client.dart';

class LoginService {
  final ApiClient api = ApiClient();

  Future<bool> login(String username, String password) async {
    final res = await api.dio.get('user');
    for (var user in res.data) {
      if (user['username'] == username && user['password'] == password) {
        return true;
      }
    }
    return false;
  }
}
