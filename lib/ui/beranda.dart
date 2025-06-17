import 'package:flutter/material.dart';
import 'package:perpustakaan_app/service/buku_service.dart';
import 'package:perpustakaan_app/service/anggota_service.dart';
import 'package:perpustakaan_app/service/peminjaman_service.dart';
import 'package:perpustakaan_app/service/pengembalian_service.dart';
import 'package:perpustakaan_app/model/peminjaman.dart';
import 'package:perpustakaan_app/model/pengembalian.dart';
import 'package:intl/intl.dart';
import 'package:perpustakaan_app/ui/sidebar.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int totalBuku = 0;
  int totalAnggota = 0;
  int totalPeminjaman = 0;
  int totalPengembalian = 0;

  List<String> notifikasiTerlambat = [];
  List<String> recentActivities = [];

  final BukuService _bukuService = BukuService();
  final AnggotaService _anggotaService = AnggotaService();
  final PeminjamanService _peminjamanService = PeminjamanService();
  final PengembalianService _pengembalianService = PengembalianService();

  void getStatistik() async {
    totalBuku = (await _bukuService.getAll()).length;
    totalAnggota = (await _anggotaService.getAll()).length;
    totalPeminjaman = (await _peminjamanService.getAll()).length;
    totalPengembalian = (await _pengembalianService.getAll()).length;

    await getNotifikasiTerlambat();
    await getRecentActivity();

    setState(() {});
  }

  Future<void> getNotifikasiTerlambat() async {
    List<Peminjaman> peminjamanList = await _peminjamanService.getAll();
    notifikasiTerlambat = peminjamanList.where((pinjam) {
      DateTime kembaliDate = DateTime.parse(pinjam.tanggalPinjam).add(const Duration(days: 7));
      return DateTime.now().isAfter(kembaliDate);
    }).map((pinjam) => 'Peminjaman ID: ${pinjam.idBuku} oleh Anggota ID: ${pinjam.idAnggota} TERLAMBAT')
      .toList();
  }

  Future<void> getRecentActivity() async {
    List<Peminjaman> peminjamanList = await _peminjamanService.getAll();
    List<Pengembalian> pengembalianList = await _pengembalianService.getAll();

    // Ambil max 3 aktivitas terakhir dari peminjaman
    List<String> peminjamanRecent = peminjamanList
        .take(3)
        .map((p) => 'Pinjam Buku ${p.idBuku} oleh Anggota ${p.idAnggota} (${DateFormat('dd-MMM-yyyy').format(DateTime.parse(p.tanggalPinjam))})')
        .toList();

    // Ambil max 2 aktivitas terakhir dari pengembalian
    List<String> pengembalianRecent = pengembalianList
        .take(2)
        .map((p) => 'Kembali Buku ${p.idBuku} oleh Anggota ${p.idAnggota} (${p.tanggalPengembalian})')
        .toList();

    recentActivities = [...peminjamanRecent, ...pengembalianRecent];
  }

  @override
  void initState() {
    super.initState();
    getStatistik();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda Perpustakaan')),
      drawer: const Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Dashboard Statistik', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard('Buku', totalBuku, Icons.book),
                const SizedBox(width: 10),
                _buildStatCard('Anggota', totalAnggota, Icons.person),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatCard('Peminjaman', totalPeminjaman, Icons.assignment),
                const SizedBox(width: 10),
                _buildStatCard('Pengembalian', totalPengembalian, Icons.assignment_return),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Notifikasi Terlambat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...notifikasiTerlambat.isEmpty
                ? [const Text('Tidak ada buku yang terlambat.', style: TextStyle(color: Colors.green))]
                : notifikasiTerlambat.map((msg) => Text(msg, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 20),
            const Text('Aktivitas Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...recentActivities.isEmpty
                ? [const Text('Belum ada aktivitas terbaru.')]
                : recentActivities.map((act) => Text('• $act')),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    return Expanded(
      child: Card(
        color: Colors.teal.shade100,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.teal),
              const SizedBox(height: 8),
              Text('$count $title', style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
