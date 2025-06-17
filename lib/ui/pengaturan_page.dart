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
  final dendaCtrl = TextEditingController();
  final maxPinjamCtrl = TextEditingController();

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
    });
  }

  Future<void> simpanPengaturan() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('denda', int.parse(dendaCtrl.text));
    prefs.setInt('maxPinjam', int.parse(maxPinjamCtrl.text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan berhasil disimpan!'),
        backgroundColor: Colors.teal,
      ),
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
  }

  void konfirmasiSimpan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menyimpan pengaturan ini?'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Aplikasi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: dendaCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Denda (Rp)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value!.isEmpty ? 'Denda wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: maxPinjamCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Maksimal Peminjaman Buku',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value!.isEmpty ? 'Maksimal peminjaman wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) konfirmasiSimpan();
                },
                icon: const Icon(Icons.save),
                label: const Text('Simpan Pengaturan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const BerandaPage()),
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali Tanpa Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: resetPengaturan,
                icon: const Icon(Icons.restore),
                label: const Text('Reset ke Default'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
