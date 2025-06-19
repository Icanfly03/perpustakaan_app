import 'package:flutter/material.dart';
import 'package:perpustakaan_app/model/pengembalian.dart';
import 'package:perpustakaan_app/model/peminjaman.dart';
import 'package:perpustakaan_app/service/pengembalian_service.dart';
import 'package:perpustakaan_app/service/peminjaman_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengembalianForm extends StatefulWidget {
  const PengembalianForm({super.key});

  @override
  State<PengembalianForm> createState() => _PengembalianFormState();
}

class _PengembalianFormState extends State<PengembalianForm> {
  final _formKey = GlobalKey<FormState>();
  final idAnggotaCtrl = TextEditingController();
  final idBukuCtrl = TextEditingController();
  final tanggalPengembalianCtrl = TextEditingController();

  final PengembalianService _pengembalianService = PengembalianService();
  final PeminjamanService _peminjamanService = PeminjamanService();

  List<Peminjaman> _peminjamanList = [];
  List<Pengembalian> _pengembalianList = [];
  int _denda = 0;
  int _dendaPengaturan = 5000;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initForm();
  }

  Future<void> initForm() async {
    await loadData();
    await loadPengaturan();
    setState(() => _isLoading = false);
  }

  Future<void> loadData() async {
    var peminjamanData = await _peminjamanService.getAll();
    var pengembalianData = await _pengembalianService.getAll();
    _peminjamanList = peminjamanData;
    _pengembalianList = pengembalianData;
  }

  Future<void> loadPengaturan() async {
    final prefs = await SharedPreferences.getInstance();
    _dendaPengaturan = prefs.getInt('denda') ?? 5000;
  }

  Future<void> pilihTanggal() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      tanggalPengembalianCtrl.text = DateFormat('dd-MMM-yyyy').format(pickedDate);
    }
  }

  void save() async {
    if (_formKey.currentState!.validate()) {
      bool kombinasiAda = _peminjamanList.any((pinjam) =>
        pinjam.idBuku == idBukuCtrl.text && pinjam.idAnggota == idAnggotaCtrl.text);

      if (!kombinasiAda) {
        showError('Error: Kombinasi ID Buku & ID Anggota tidak ditemukan!');
        return;
      }

      bool sudahDikembalikan = _pengembalianList.any((kembali) =>
        kembali.idBuku == idBukuCtrl.text && kembali.idAnggota == idAnggotaCtrl.text);

      if (sudahDikembalikan) {
        showError('Error: Pengembalian untuk kombinasi ini sudah ada!');
        return;
      }

      Peminjaman? dataPinjam = _peminjamanList.firstWhere(
        (pinjam) => pinjam.idBuku == idBukuCtrl.text && pinjam.idAnggota == idAnggotaCtrl.text,
        orElse: () => Peminjaman(id: '', idBuku: '', idAnggota: '', tanggalPinjam: ''),
      );

      if (dataPinjam.id == '') {
        showError('Error: Data Peminjaman tidak valid!');
        return;
      }

      DateTime tglPinjam = DateTime.parse(dataPinjam.tanggalPinjam);
      DateTime tglKembali = DateFormat('dd-MMM-yyyy').parse(tanggalPengembalianCtrl.text);
      int selisih = tglKembali.difference(tglPinjam).inDays;

      if (selisih > 7) {
        _denda = _dendaPengaturan;
        showWarning('Terlambat! Denda: Rp $_denda');
      } else {
        _denda = 0;
      }

      Pengembalian pengembalian = Pengembalian(
        id: '', // Auto-generated
        idAnggota: idAnggotaCtrl.text,
        idBuku: idBukuCtrl.text,
        tanggalPengembalian: tanggalPengembalianCtrl.text,
      );

      await _pengembalianService.create(pengembalian);
      Navigator.pop(context);
      showSuccess('Data Pengembalian berhasil disimpan!');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
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
      appBar: AppBar(title: const Text('Tambah Pengembalian')),
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
                      controller: tanggalPengembalianCtrl,
                      readOnly: true,
                      onTap: pilihTanggal,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Pengembalian',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: theme.brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.teal.shade50,
                      ),
                      style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                      validator: (value) => value!.isEmpty ? 'Tanggal Pengembalian wajib diisi' : null,
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
                    const SizedBox(height: 10),
                    if (_denda > 0)
                      Text('Denda: Rp $_denda',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
    );
  }
}
