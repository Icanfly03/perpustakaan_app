import 'package:flutter/material.dart';
import 'package:perpustakaan_app/model/buku.dart';
import 'package:perpustakaan_app/service/buku_service.dart';

class BukuForm extends StatefulWidget {
  final Buku? buku;
  const BukuForm({super.key, this.buku});

  @override
  State<BukuForm> createState() => _BukuFormState();
}

class _BukuFormState extends State<BukuForm> {
  final _formKey = GlobalKey<FormState>();
  final judulCtrl = TextEditingController();
  final pengarangCtrl = TextEditingController();
  final tahunCtrl = TextEditingController();
  final BukuService _bukuService = BukuService();

  List<Buku> _bukuList = [];

  @override
  void initState() {
    super.initState();
    if (widget.buku != null) {
      judulCtrl.text = widget.buku!.judul;
      pengarangCtrl.text = widget.buku!.pengarang;
      tahunCtrl.text = widget.buku!.tahunTerbit;
    }
    loadBukuList();
  }

  void loadBukuList() async {
    var list = await _bukuService.getAll();
    setState(() {
      _bukuList = list;
    });
  }

  void save() async {
    if (_formKey.currentState!.validate()) {
      bool duplikat = _bukuList.any((buku) =>
          buku.judul.toLowerCase() == judulCtrl.text.toLowerCase() &&
          buku.pengarang.toLowerCase() == pengarangCtrl.text.toLowerCase() &&
          buku.tahunTerbit == tahunCtrl.text &&
          buku.id != widget.buku?.id);

      if (duplikat) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: Buku dengan data yang sama sudah ada!'),
              backgroundColor: Colors.red),
        );
        return;
      }

      Buku buku = Buku(
        id: widget.buku?.id ?? '',
        judul: judulCtrl.text,
        pengarang: pengarangCtrl.text,
        tahunTerbit: tahunCtrl.text,
      );

      if (widget.buku == null) {
        await _bukuService.create(buku);
      } else {
        await _bukuService.update(widget.buku!.id, buku);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Data Buku berhasil disimpan!'),
            backgroundColor: Colors.teal),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Theme aware

    return Scaffold(
      appBar: AppBar(title: Text(widget.buku == null ? 'Tambah Buku' : 'Edit Buku')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: judulCtrl,
                decoration: InputDecoration(
                  labelText: 'Judul Buku',
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.teal.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                style: TextStyle(
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: pengarangCtrl,
                decoration: InputDecoration(
                  labelText: 'Pengarang',
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.teal.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                style: TextStyle(
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Pengarang wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: tahunCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tahun Terbit',
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.teal.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                style: TextStyle(
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tahun wajib diisi';
                  } else if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                    return 'Tahun harus berupa 4 digit angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: save,
                icon: const Icon(Icons.save),
                label: const Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
