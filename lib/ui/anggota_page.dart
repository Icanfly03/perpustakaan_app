import 'package:flutter/material.dart';
import 'package:perpustakaan_app/model/anggota.dart';
import 'package:perpustakaan_app/service/anggota_service.dart';
import 'package:perpustakaan_app/ui/anggota_form.dart';
import 'package:perpustakaan_app/widget/sidebar.dart';

class AnggotaPage extends StatefulWidget {
  const AnggotaPage({super.key});

  @override
  State<AnggotaPage> createState() => _AnggotaPageState();
}

class _AnggotaPageState extends State<AnggotaPage> {
  final AnggotaService _anggotaService = AnggotaService();
  List<Anggota> _anggotaList = [];
  List<Anggota> _filteredAnggotaList = [];

  final TextEditingController _searchNamaCtrl = TextEditingController();
  final TextEditingController _searchNimCtrl = TextEditingController();
  String? _selectedJurusan;

  List<String> _jurusanList = [];

  void getData() async {
    _anggotaList = await _anggotaService.getAll();
    _filteredAnggotaList = _anggotaList;

    // Ambil jurusan unik
    _jurusanList = _anggotaList.map((e) => e.jurusan).toSet().toList();
    setState(() {});
  }

  void deleteData(String id) async {
    await _anggotaService.delete(id);
    getData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data Anggota berhasil dihapus!'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void filterAnggota() {
    String namaQuery = _searchNamaCtrl.text.toLowerCase();
    String nimQuery = _searchNimCtrl.text.toLowerCase();

    setState(() {
      _filteredAnggotaList = _anggotaList.where((anggota) {
        final nama = anggota.nama.toLowerCase();
        final nim = anggota.nim.toLowerCase();
        final jurusan = anggota.jurusan;

        final matchNama = nama.contains(namaQuery);
        final matchNim = nim.contains(nimQuery);
        final matchJurusan = _selectedJurusan == null || jurusan == _selectedJurusan;

        return matchNama && matchNim && matchJurusan;
      }).toList();
    });
  }

  void resetFilter() {
    setState(() {
      _searchNamaCtrl.clear();
      _searchNimCtrl.clear();
      _selectedJurusan = null;
      _filteredAnggotaList = _anggotaList;
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
      appBar: AppBar(title: const Text('Data Anggota')),
      drawer: const Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _searchNamaCtrl,
              decoration: InputDecoration(
                labelText: 'Filter Nama',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.teal.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => filterAnggota(),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _searchNimCtrl,
              decoration: InputDecoration(
                labelText: 'Filter NIM',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.teal.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => filterAnggota(),
            ),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: _selectedJurusan,
              hint: const Text('Filter Jurusan'),
              isExpanded: true,
              items: _jurusanList.map((jurusan) {
                return DropdownMenuItem(value: jurusan, child: Text(jurusan));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedJurusan = value;
                  filterAnggota();
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.teal.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 5),
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
                itemCount: _filteredAnggotaList.length,
                itemBuilder: (context, index) {
                  Anggota anggota = _filteredAnggotaList[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.blue.shade50,
                    child: ListTile(
                      leading: Icon(Icons.person, color: theme.brightness == Brightness.dark ? Colors.white : Colors.blue),
                      title: Text(
                        anggota.nama,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${anggota.id}\nNIM: ${anggota.nim}\nJurusan: ${anggota.jurusan}',
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
                                  builder: (_) => AnggotaForm(anggota: anggota),
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
                                  content: const Text('Yakin hapus anggota ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteData(anggota.id);
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
            MaterialPageRoute(builder: (_) => const AnggotaForm()),
          );
          getData();
        },
        label: const Text('Tambah Anggota'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
