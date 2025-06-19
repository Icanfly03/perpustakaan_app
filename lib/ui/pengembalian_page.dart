import 'package:flutter/material.dart';
import 'package:perpustakaan_app/model/pengembalian.dart';
import 'package:perpustakaan_app/model/peminjaman.dart';
import 'package:perpustakaan_app/service/pengembalian_service.dart';
import 'package:perpustakaan_app/service/peminjaman_service.dart';
import 'package:perpustakaan_app/ui/pengembalian_form.dart';
import 'package:perpustakaan_app/widget/sidebar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengembalianPage extends StatefulWidget {
  const PengembalianPage({super.key});

  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  final PengembalianService _pengembalianService = PengembalianService();
  final PeminjamanService _peminjamanService = PeminjamanService();
  List<Pengembalian> _pengembalianList = [];
  List<Peminjaman> _peminjamanList = [];
  int _dendaPengaturan = 5000;

  @override
  void initState() {
    super.initState();
    getData();
    loadPengaturan();
  }

  void getData() async {
    _pengembalianList = await _pengembalianService.getAll();
    _peminjamanList = await _peminjamanService.getAll();
    setState(() {});
  }

  Future<void> loadPengaturan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dendaPengaturan = prefs.getInt('denda') ?? 5000;
    });
  }

  void deleteData(String id) async {
    await _pengembalianService.delete(id);
    getData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data Pengembalian berhasil dihapus!'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  String formatTanggal(String tanggal) {
    try {
      DateTime date = DateFormat('dd-MMM-yyyy').parse(tanggal);
      return DateFormat('dd-MMM-yyyy').format(date);
    } catch (e) {
      return tanggal;
    }
  }

  int hitungDenda(Pengembalian kembali) {
    Peminjaman? pinjam = _peminjamanList.firstWhere(
      (p) => p.idBuku == kembali.idBuku && p.idAnggota == kembali.idAnggota,
      orElse: () => Peminjaman(id: '', idBuku: '', idAnggota: '', tanggalPinjam: ''),
    );

    if (pinjam.id == '') return 0;

    DateTime tglPinjam = DateTime.parse(pinjam.tanggalPinjam);
    DateTime tglKembali = DateFormat('dd-MMM-yyyy').parse(kembali.tanggalPengembalian);
    int selisih = tglKembali.difference(tglPinjam).inDays;

    return selisih > 7 ? _dendaPengaturan : 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Data Pengembalian')),
      drawer: const Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: _pengembalianList.length,
          itemBuilder: (context, index) {
            Pengembalian kembali = _pengembalianList[index];
            int denda = hitungDenda(kembali);

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              color: denda > 0 
                ? (theme.brightness == Brightness.dark ? Colors.red.shade900 : Colors.red.shade100)
                : (theme.brightness == Brightness.dark ? Colors.green.shade900 : Colors.green.shade50),
              child: ListTile(
                leading: Icon(
                  Icons.assignment_return,
                  color: denda > 0 ? Colors.red : Colors.green,
                ),
                title: Text(
                  'ID Buku: ${kembali.idBuku}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  'ID Anggota: ${kembali.idAnggota}\n'
                  'Tanggal Kembali: ${formatTanggal(kembali.tanggalPengembalian)}\n'
                  'Denda: Rp ${denda > 0 ? denda : 0}',
                  style: TextStyle(
                    color: denda > 0 
                        ? Colors.red 
                        : (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black),
                    fontWeight: denda > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi'),
                        content: const Text('Yakin hapus pengembalian ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              deleteData(kembali.id);
                              Navigator.pop(context);
                            },
                            child: const Text('Hapus'),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PengembalianForm()),
          );
          getData();
        },
        label: const Text('Tambah Pengembalian'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
