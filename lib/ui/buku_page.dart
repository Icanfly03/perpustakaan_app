import 'package:flutter/material.dart';
import 'package:perpustakaan_app/model/buku.dart';
import 'package:perpustakaan_app/service/buku_service.dart';
import 'package:perpustakaan_app/ui/buku_form.dart';
import 'package:perpustakaan_app/ui/sidebar.dart';

class BukuPage extends StatefulWidget {
  const BukuPage({super.key});

  @override
  State<BukuPage> createState() => _BukuPageState();
}

class _BukuPageState extends State<BukuPage> {
  final BukuService _bukuService = BukuService();
  List<Buku> _bukuList = [];
  List<Buku> _filteredBukuList = [];
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _tahunMinCtrl = TextEditingController();
  final TextEditingController _tahunMaxCtrl = TextEditingController();

  String sortBy = 'Judul';
  bool ascending = true;

  void getData() async {
    _bukuList = await _bukuService.getAll();
    _filteredBukuList = _bukuList;
    setState(() {});
  }

  void deleteData(String id) async {
    await _bukuService.delete(id);
    getData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data Buku berhasil dihapus!'), backgroundColor: Colors.redAccent),
    );
  }

  void searchAndFilter() {
    String query = _searchCtrl.text.toLowerCase();
    int? tahunMin = int.tryParse(_tahunMinCtrl.text);
    int? tahunMax = int.tryParse(_tahunMaxCtrl.text);

    List<Buku> hasil = _bukuList.where((buku) {
      final judulLower = buku.judul.toLowerCase();
      final pengarangLower = buku.pengarang.toLowerCase();
      final tahun = int.tryParse(buku.tahunTerbit) ?? 0;

      final cocokJudul = judulLower.contains(query) || pengarangLower.contains(query);
      final cocokTahunMin = tahunMin == null || tahun >= tahunMin;
      final cocokTahunMax = tahunMax == null || tahun <= tahunMax;

      return cocokJudul && cocokTahunMin && cocokTahunMax;
    }).toList();

    // Urutkan
    hasil.sort((a, b) {
      int cmp;
      if (sortBy == 'Judul') {
        cmp = a.judul.compareTo(b.judul);
      } else {
        cmp = int.parse(a.tahunTerbit).compareTo(int.parse(b.tahunTerbit));
      }
      return ascending ? cmp : -cmp;
    });

    setState(() => _filteredBukuList = hasil);
  }

  void resetFilter() {
    _searchCtrl.clear();
    _tahunMinCtrl.clear();
    _tahunMaxCtrl.clear();
    sortBy = 'Judul';
    ascending = true;
    searchAndFilter();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Buku')),
      drawer: const Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari judul atau pengarang...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.teal.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => searchAndFilter(),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tahunMinCtrl,
                    decoration: InputDecoration(
                      labelText: 'Tahun Min',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.teal.shade50,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => searchAndFilter(),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: _tahunMaxCtrl,
                    decoration: InputDecoration(
                      labelText: 'Tahun Max',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.teal.shade50,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => searchAndFilter(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: sortBy,
                    isExpanded: true,
                    items: ['Judul', 'Tahun'].map((item) {
                      return DropdownMenuItem(value: item, child: Text('Urut: $item'));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        sortBy = value!;
                        searchAndFilter();
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      ascending = !ascending;
                      searchAndFilter();
                    });
                  },
                ),
                ElevatedButton.icon(
                  onPressed: resetFilter,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredBukuList.length,
                itemBuilder: (context, index) {
                  Buku buku = _filteredBukuList[index];
                  return Card(
                    color: Colors.teal.shade50,
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        'ID: ${buku.id} - ${buku.judul}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Pengarang: ${buku.pengarang}\nTahun: ${buku.tahunTerbit}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.push(context, MaterialPageRoute(
                                builder: (_) => BukuForm(buku: buku),
                              ));
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
                                  content: const Text('Yakin hapus buku ini?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                                    TextButton(onPressed: () {
                                      deleteData(buku.id);
                                      Navigator.pop(context);
                                    }, child: const Text('Hapus'))
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
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const BukuForm()));
          getData();
        },
        label: const Text('Tambah Buku'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
