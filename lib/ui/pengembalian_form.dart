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

  @override
  void initState() {
    super.initState();
    loadData();
    loadPengaturan();
  }

  void loadData() async {
    var peminjamanData = await _peminjamanService.getAll();
    var pengembalianData = await _pengembalianService.getAll();
    setState(() {
      _peminjamanList = peminjamanData;
      _pengembalianList = pengembalianData;
    });
  }

  Future<void> loadPengaturan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dendaPengaturan = prefs.getInt('denda') ?? 5000;
    });
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
      // Validasi kombinasi ID Buku + ID Anggota HARUS ADA di data Peminjaman
      bool kombinasiAda = _peminjamanList.any((pinjam) =>
          pinjam.idBuku == idBukuCtrl.text && pinjam.idAnggota == idAnggotaCtrl.text);

      if (!kombinasiAda) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Kombinasi ID Buku & ID Anggota tidak ditemukan di data Peminjaman!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validasi kombinasi ID Buku + ID Anggota TIDAK BOLEH ADA di data Pengembalian
      bool sudahDikembalikan = _pengembalianList.any((kembali) =>
          kembali.idBuku == idBukuCtrl.text && kembali.idAnggota == idAnggotaCtrl.text);

      if (sudahDikembalikan) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Data pengembalian untuk kombinasi ini sudah ada!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Cari data peminjaman terkait
      Peminjaman? dataPinjam = _peminjamanList.firstWhere(
        (pinjam) =>
            pinjam.idBuku == idBukuCtrl.text &&
            pinjam.idAnggota == idAnggotaCtrl.text,
        orElse: () => Peminjaman(id: '', idBuku: '', idAnggota: '', tanggalPinjam: ''),
      );

      if (dataPinjam.id == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Data Peminjaman tidak valid!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Hitung denda jika terlambat lebih dari 7 hari
      DateTime tglPinjam = DateTime.parse(dataPinjam.tanggalPinjam);
      DateTime tglKembali = DateFormat('dd-MMM-yyyy').parse(tanggalPengembalianCtrl.text);
      int selisih = tglKembali.difference(tglPinjam).inDays;

      if (selisih > 7) {
        _denda = _dendaPengaturan;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terlambat! Denda: Rp $_denda'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        _denda = 0;
      }

      Pengembalian pengembalian = Pengembalian(
        id: '', // Auto-generated oleh MockAPI
        idAnggota: idAnggotaCtrl.text,
        idBuku: idBukuCtrl.text,
        tanggalPengembalian: tanggalPengembalianCtrl.text,
      );

      await _pengembalianService.create(pengembalian);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data Pengembalian berhasil disimpan!'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pengembalian')),
      body: Padding(
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
                  fillColor: Colors.teal.shade50,
                ),
                validator: (value) => value!.isEmpty ? 'ID Buku wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: idAnggotaCtrl,
                decoration: InputDecoration(
                  labelText: 'ID Anggota',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.teal.shade50,
                ),
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
                  fillColor: Colors.teal.shade50,
                ),
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
