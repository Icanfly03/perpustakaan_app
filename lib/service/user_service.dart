import 'package:dio/dio.dart';

class UserService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://684e4d63f0c9c9848d27ca3b.mockapi.io/user'; // endpoint MockAPI kamu

  // Fungsi login
  Future<String?> login(String username, String password) async {
    try {
      final response = await _dio.get(baseUrl);
      final List users = response.data;

      // Cari user dengan username dan password yang cocok
      final user = users.firstWhere(
        (u) => u['username'] == username && u['password'] == password,
        orElse: () => null,
      );

      if (user != null) {
        // Karena di MockAPI tidak ada token asli, return dummy token
        return 'mock_api_token';
      } else {
        return null;
      }
    } catch (e) {
      print('Terjadi kesalahan saat login: $e');
      return null;
    }
  }
}
