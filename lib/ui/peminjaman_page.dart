import 'package:flutter/material.dart';
import 'package:perpustakaan_app/model/peminjaman.dart';
import 'package:perpustakaan_app/service/peminjaman_service.dart';
import 'package:perpustakaan_app/service/buku_service.dart';
import 'package:perpustakaan_app/ui/peminjaman_form.dart';
import 'package:perpustakaan_app/widget/sidebar.dart';
import 'package:intl/intl.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final PeminjamanService _peminjamanService = PeminjamanService();
  final BukuService _bukuService = BukuService();
  List<Peminjaman> _peminjamanList = [];
  List<String> _idBukuList = [];
  List<String> _idAnggotaList = [];

  String? selectedIdBuku;
  String? selectedIdAnggota;

  void getData() async {
    _peminjamanList = await _peminjamanService.getAll();
    var bukuList = await _bukuService.getAll();
    _idBukuList = bukuList.map((buku) => buku.id).toList();
    _idAnggotaList = _peminjamanList.map((p) => p.idAnggota).toSet().toList();
    setState(() {});
  }

  void deleteData(String id) async {
    await _peminjamanService.delete(id);
    getData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data Peminjaman berhasil dihapus!'), backgroundColor: Colors.redAccent),
    );
  }

  String formatTanggal(String tanggal) {
    try {
      DateTime date = DateTime.parse(tanggal);
      return DateFormat('dd-MMM-yyyy').format(date);
    } catch (e) {
      return tanggal;
    }
  }

  List<Peminjaman> getFilteredList() {
    return _peminjamanList.where((pinjam) {
      final matchIdBuku = selectedIdBuku == null || pinjam.idBuku == selectedIdBuku;
      final matchIdAnggota = selectedIdAnggota == null || pinjam.idAnggota == selectedIdAnggota;
      return matchIdBuku && matchIdAnggota;
    }).toList();
  }

  void resetFilter() {
    setState(() {
      selectedIdBuku = null;
      selectedIdAnggota = null;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Data Peminjaman')),
      drawer: const Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedIdBuku,
              hint: const Text('Filter ID Buku'),
              isExpanded: true,
              items: _idBukuList.map((id) {
                return DropdownMenuItem(value: id, child: Text(id));
              }).toList(),
              onChanged: (value) => setState(() => selectedIdBuku = value),
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.teal.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: selectedIdAnggota,
              hint: const Text('Filter ID Anggota'),
              isExpanded: true,
              items: _idAnggotaList.map((id) {
                return DropdownMenuItem(value: id, child: Text(id));
              }).toList(),
              onChanged: (value) => setState(() => selectedIdAnggota = value),
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.teal.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: resetFilter,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: getFilteredList().length,
                itemBuilder: (context, index) {
                  Peminjaman pinjam = getFilteredList()[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.teal.shade50,
                    child: ListTile(
                      leading: Icon(Icons.book, color: theme.brightness == Brightness.dark ? Colors.white : Colors.teal),
                      title: Text(
                        'ID Buku: ${pinjam.idBuku}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'ID Anggota: ${pinjam.idAnggota}\nTanggal Pinjam: ${formatTanggal(pinjam.tanggalPinjam)}',
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PeminjamanForm(peminjaman: pinjam),
                                ),
                              );
                              getData();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi'),
                                  content: const Text('Yakin hapus peminjaman ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteData(pinjam.id);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PeminjamanForm()),
          );
          getData();
        },
        label: const Text('Tambah Peminjaman'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
