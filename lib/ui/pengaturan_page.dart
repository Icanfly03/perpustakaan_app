import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perpustakaan_app/ui/beranda.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dendaCtrl = TextEditingController();
  final TextEditingController maxPinjamCtrl = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPengaturan();
  }

  Future<void> loadPengaturan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dendaCtrl.text = (prefs.getInt('denda') ?? 5000).toString();
      maxPinjamCtrl.text = (prefs.getInt('maxPinjam') ?? 3).toString();
      isLoading = false;
    });
  }

  Future<void> simpanPengaturan() async {
    final prefs = await SharedPreferences.getInstance();
    final int? denda = int.tryParse(dendaCtrl.text);
    final int? maxPinjam = int.tryParse(maxPinjamCtrl.text);

    if (denda == null || maxPinjam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Denda & Maksimal Pinjam harus angka valid!'), backgroundColor: Colors.red),
      );
      return;
    }

    await prefs.setInt('denda', denda);
    await prefs.setInt('maxPinjam', maxPinjam);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan berhasil disimpan!'), backgroundColor: Colors.teal),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const BerandaPage()),
      (Route<dynamic> route) => false,
    );
  }

  void resetPengaturan() {
    setState(() {
      dendaCtrl.text = '5000';
      maxPinjamCtrl.text = '3';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan direset ke default.'), backgroundColor: Colors.orange),
    );
  }

  void konfirmasiSimpan() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Simpan perubahan pengaturan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                simpanPengaturan();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    }
  }

  void kembaliTanpaSimpan() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BerandaPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Aplikasi')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: dendaCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Denda (Rp)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Denda wajib diisi';
                        if (int.tryParse(value) == null) return 'Denda harus berupa angka';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: maxPinjamCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Maksimal Peminjaman Buku',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Maksimal Pinjam wajib diisi';
                        if (int.tryParse(value) == null) return 'Harus berupa angka';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: konfirmasiSimpan,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Pengaturan'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: kembaliTanpaSimpan,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Kembali Tanpa Simpan'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: resetPengaturan,
                      icon: const Icon(Icons.restore),
                      label: const Text('Reset ke Default'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
