import 'package:flutter/material.dart';
import 'package:perpustakaan_app/helpers/user_info.dart';
import 'package:perpustakaan_app/ui/beranda.dart';
import 'package:perpustakaan_app/ui/login.dart';
import 'package:perpustakaan_app/ui/buku_page.dart';
import 'package:perpustakaan_app/ui/anggota_page.dart';
import 'package:perpustakaan_app/ui/peminjaman_page.dart';
import 'package:perpustakaan_app/ui/pengembalian_page.dart';
import 'package:perpustakaan_app/ui/pengaturan_page.dart';
import 'package:provider/provider.dart';
import 'package:perpustakaan_app/helpers/theme_notifier.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_books, color: Colors.white, size: 50),
                SizedBox(height: 8),
                Text('Perpustakaan App',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Beranda'),
            onTap: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const BerandaPage())),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Buku'),
            onTap: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const BukuPage())),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Anggota'),
            onTap: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const AnggotaPage())),
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Peminjaman'),
            onTap: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const PeminjamanPage())),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_return),
            title: const Text('Pengembalian'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PengembalianPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Pengaturan'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PengaturanPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await UserInfo().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Mode Gelap/Terang'),
            trailing: Consumer<ThemeNotifier>(
              builder: (context, themeNotifier, child) {
                return Switch(
                  value: themeNotifier.isDark,
                  onChanged: (value) {
                    themeNotifier.toggleTheme();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
