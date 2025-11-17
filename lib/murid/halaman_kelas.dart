import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import 'drawer/drawer.dart';
import 'drawer/buttomnav.dart';

class HalamanKelas extends StatefulWidget {
  const HalamanKelas({super.key});

  @override
  State<HalamanKelas> createState() => _HalamanKelasState();
}

class _HalamanKelasState extends State<HalamanKelas> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Kelas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      drawer: const DrawerMurid(),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====== HARI INI ======
          _buildSectionCard(
            title: 'Hari ini',
            child: Column(
              children: [
                _buildScheduleItem(
                  time: '08.00',
                  title: 'Matematika - SMP',
                  buttonText: '[Masuk Kelas]',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ====== HARI SECTION ======
          _buildSimpleCard(
            padding: 16,
            child: const Text(
              'Senin  •  Selasa  •  Rabu  •  Kamis  •  Jumat  •  Sabtu  •  Minggu',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // ====== KELASKU ======
          _buildSectionCard(
            title: 'Kelasku',
            child: _buildClassDetail(),
          ),

          const SizedBox(height: 16),

          // ====== ABSEN ======
          _buildSectionCard(
            title: 'Absen',
            child: _buildAbsenceTable(),
          ),
        ],
      ),

      bottomNavigationBar: FooterMurid(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // -----------------------------
  // COMPONENTS
  // -----------------------------

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSimpleCard({required Widget child, double padding = 12}) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: _cardDecoration(),
      child: child,
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Jadwal item
  Widget _buildScheduleItem({
    required String time,
    required String title,
    required String buttonText,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$time  $title',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          _buildSmallButton(buttonText),
        ],
      ),
    );
  }

  // Button kecil
  Widget _buildSmallButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Detail kelas
  Widget _buildClassDetail() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration().copyWith(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Matematika - SMP',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Private - Bu Ismaturrohmah',
              style: TextStyle(fontSize: 13, color: AppColors.textLight)),
          const SizedBox(height: 4),
          const Text('Senin 08.00 | Rabu 09.00',
              style: TextStyle(fontSize: 13, color: AppColors.textLight)),
          const SizedBox(height: 4),
          const Text('3/8 Pertemuan',
              style: TextStyle(fontSize: 13, color: AppColors.textLight)),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallButton('Materi'),
              const SizedBox(width: 8),
              _buildSmallButton('Quiz'),
              const SizedBox(width: 8),
              _buildSmallButton('Forum'),
            ],
          ),
        ],
      ),
    );
  }

  // Tabel Absen
  Widget _buildAbsenceTable() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Row(
            children: [
              Expanded(flex: 2, child: Text('Nama', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Tanggal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              const Expanded(
                flex: 2,
                child: Text('Alfito', style: TextStyle(fontSize: 13)),
              ),
              const Expanded(
                flex: 2,
                child: Text('01 Januari - 25', style: TextStyle(fontSize: 13)),
              ),
              Expanded(
                flex: 1,
                child: _buildStatusBadge('Hadir', AppColors.success),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Badge status
  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
