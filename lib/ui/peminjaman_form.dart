import 'package:flutter/material.dart';
import 'package:perpustakaan_app/model/peminjaman.dart';
import 'package:perpustakaan_app/service/peminjaman_service.dart';
import 'package:perpustakaan_app/service/buku_service.dart';
import 'package:perpustakaan_app/service/anggota_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeminjamanForm extends StatefulWidget {
  final Peminjaman? peminjaman;
  const PeminjamanForm({super.key, this.peminjaman});

  @override
  State<PeminjamanForm> createState() => _PeminjamanFormState();
}

class _PeminjamanFormState extends State<PeminjamanForm> {
  final _formKey = GlobalKey<FormState>();
  final idBukuCtrl = TextEditingController();
  final idAnggotaCtrl = TextEditingController();
  final tanggalPinjamCtrl = TextEditingController();
  final PeminjamanService _peminjamanService = PeminjamanService();
  final BukuService _bukuService = BukuService();
  final AnggotaService _anggotaService = AnggotaService();

  List<String> _idBukuList = [];
  List<String> _idAnggotaList = [];
  int _batasPinjam = 3;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.peminjaman != null) {
      idBukuCtrl.text = widget.peminjaman!.idBuku;
      idAnggotaCtrl.text = widget.peminjaman!.idAnggota;
      tanggalPinjamCtrl.text = widget.peminjaman!.tanggalPinjam;
    }
    initForm();
  }

  Future<void> initForm() async {
    await loadData();
    await loadPengaturan();
    setState(() => _isLoading = false);
  }

  Future<void> loadPengaturan() async {
    final prefs = await SharedPreferences.getInstance();
    _batasPinjam = prefs.getInt('maxPinjam') ?? 3;
  }

  Future<void> loadData() async {
    var bukuList = await _bukuService.getAll();
    var anggotaList = await _anggotaService.getAll();
    _idBukuList = bukuList.map((buku) => buku.id).toList();
    _idAnggotaList = anggotaList.map((anggota) => anggota.id).toList();
  }

  Future<void> pilihTanggal() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      tanggalPinjamCtrl.text = pickedDate.toIso8601String().split('T').first;
    }
  }

  void save() async {
    if (_formKey.currentState!.validate()) {
      List<Peminjaman> existingPeminjaman = await _peminjamanService.getAll();

      if (!_idBukuList.contains(idBukuCtrl.text)) {
        showError('ID Buku tidak ditemukan!');
        return;
      }

      if (!_idAnggotaList.contains(idAnggotaCtrl.text)) {
        showError('ID Anggota tidak ditemukan!');
        return;
      }

      bool sudahDipinjam = existingPeminjaman.any((pinjam) =>
          pinjam.idBuku == idBukuCtrl.text &&
          pinjam.id != widget.peminjaman?.id);

      if (sudahDipinjam) {
        showError('Buku ini sudah dipinjam!');
        return;
      }

      int jumlahPinjamanAnggota = existingPeminjaman
          .where((pinjam) =>
              pinjam.idAnggota == idAnggotaCtrl.text &&
              pinjam.id != widget.peminjaman?.id)
          .length;

      if (jumlahPinjamanAnggota >= _batasPinjam) {
        showError('Anggota ini sudah meminjam maksimal $_batasPinjam buku!');
        return;
      }

      Peminjaman pinjam = Peminjaman(
        id: widget.peminjaman?.id ?? '',
        idBuku: idBukuCtrl.text,
        idAnggota: idAnggotaCtrl.text,
        tanggalPinjam: tanggalPinjamCtrl.text,
      );

      if (widget.peminjaman == null) {
        await _peminjamanService.create(pinjam);
      } else {
        await _peminjamanService.update(widget.peminjaman!.id, pinjam);
      }

      Navigator.pop(context);
      showSuccess('Data Peminjaman berhasil disimpan!');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.teal),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.peminjaman == null ? 'Tambah Peminjaman' : 'Edit Peminjaman')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: idBukuCtrl,
                      decoration: InputDecoration(
                        labelText: 'ID Buku',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: theme.brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.teal.shade50,
                      ),
                      style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                      validator: (value) => value!.isEmpty ? 'ID Buku wajib diisi' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: idAnggotaCtrl,
                      decoration: InputDecoration(
                        labelText: 'ID Anggota',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: theme.brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.teal.shade50,
                      ),
                      style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                      validator: (value) => value!.isEmpty ? 'ID Anggota wajib diisi' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: tanggalPinjamCtrl,
                      readOnly: true,
                      onTap: pilihTanggal,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Pinjam',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: theme.brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.teal.shade50,
                      ),
                      style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                      validator: (value) => value!.isEmpty ? 'Tanggal Pinjam wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: save,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
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
