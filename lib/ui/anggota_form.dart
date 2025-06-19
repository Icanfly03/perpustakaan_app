import 'package:flutter/material.dart';
import 'package:perpustakaan_app/model/anggota.dart';
import 'package:perpustakaan_app/service/anggota_service.dart';

class AnggotaForm extends StatefulWidget {
  final Anggota? anggota;
  const AnggotaForm({super.key, this.anggota});

  @override
  State<AnggotaForm> createState() => _AnggotaFormState();
}

class _AnggotaFormState extends State<AnggotaForm> {
  final _formKey = GlobalKey<FormState>();
  final namaCtrl = TextEditingController();
  final nimCtrl = TextEditingController();
  final jurusanCtrl = TextEditingController();
  final AnggotaService _anggotaService = AnggotaService();

  List<Anggota> _anggotaList = [];

  @override
  void initState() {
    super.initState();
    if (widget.anggota != null) {
      namaCtrl.text = widget.anggota!.nama;
      nimCtrl.text = widget.anggota!.nim;
      jurusanCtrl.text = widget.anggota!.jurusan;
    }
    loadData();
  }

  void loadData() async {
    _anggotaList = await _anggotaService.getAll();
    setState(() {});
  }

  void save() async {
    if (_formKey.currentState!.validate()) {
      bool nimSudahAda = _anggotaList.any((anggota) =>
          anggota.nim.toLowerCase() == nimCtrl.text.toLowerCase() &&
          anggota.id != (widget.anggota?.id ?? ''));

      if (nimSudahAda) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: NIM sudah digunakan oleh anggota lain!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Anggota anggota = Anggota(
        id: widget.anggota?.id ?? '',
        nama: namaCtrl.text,
        nim: nimCtrl.text,
        jurusan: jurusanCtrl.text,
      );

      if (widget.anggota == null) {
        await _anggotaService.create(anggota);
      } else {
        await _anggotaService.update(widget.anggota!.id, anggota);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data Anggota berhasil disimpan!'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.anggota == null ? 'Tambah Anggota' : 'Edit Anggota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Anggota',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.blue.shade50,
                ),
                style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: nimCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'NIM (Angka Saja)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.blue.shade50,
                ),
                style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                validator: (value) {
                  if (value!.isEmpty) return 'NIM wajib diisi';
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'NIM harus berupa angka';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: jurusanCtrl,
                decoration: InputDecoration(
                  labelText: 'Jurusan',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.blue.shade50,
                ),
                style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                validator: (value) => value!.isEmpty ? 'Jurusan wajib diisi' : null,
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
