import 'package:flutter/material.dart';
import 'package:perpustakaan_app/helpers/user_info.dart';
import 'package:perpustakaan_app/ui/login.dart';
import 'package:perpustakaan_app/ui/beranda.dart';
import 'package:perpustakaan_app/helpers/theme_notifier.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLogin() async {
    return await UserInfo().getToken() != null;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'Aplikasi Perpustakaan',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: themeNotifier.isDark ? Brightness.dark : Brightness.light,
              primarySwatch: Colors.teal,
              useMaterial3: true,
            ),
            home: FutureBuilder<bool>(
              future: checkLogin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return snapshot.data! ? const BerandaPage() : const LoginPage();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
