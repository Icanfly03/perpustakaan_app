import 'package:dio/dio.dart';

class ApiClient {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://684e4d63f0c9c9848d27ca3b.mockapi.io/',
    headers: {'Content-Type': 'application/json'},
  ));

  final dio2 = Dio(BaseOptions(
    baseUrl: 'https://684e8801f0c9c9848d28620e.mockapi.io/',
    headers: {'Content-Type': 'application/json'},
  ));
  final dio3 = Dio(BaseOptions(
    baseUrl: 'https://684a805f165d05c5d358fc2b.mockapi.io/',
    headers: {'Content-Type': 'application/json'},
  ));
}
