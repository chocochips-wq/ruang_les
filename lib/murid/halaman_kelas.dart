import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import 'drawer/drawer.dart';
import 'drawer/bottomnav.dart';

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
            icon: Icons.today,
            child: Column(
              children: [
                _buildScheduleItem(
                  time: '08.00',
                  title: 'Matematika - SMP',
                  buttonText: 'Masuk Kelas',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ====== HARI SECTION ======
          _buildSimpleCard(
            padding: 16,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu']
                  .map((day) => _buildDayChip(day, day == 'Senin'))
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ====== KELASKU ======
          _buildSectionCard(
            title: 'Kelasku',
            icon: Icons.class_,
            child: _buildClassDetail(),
          ),

          const SizedBox(height: 16),

          // ====== ABSEN ======
          _buildSectionCard(
            title: 'Absen',
            icon: Icons.checklist,
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

  Widget _buildSectionCard({required String title, required Widget child, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
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
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // Day chip
  Widget _buildDayChip(String day, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.primary : Colors.grey.shade300,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Text(
        day,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? AppColors.primary : AppColors.textLight,
        ),
      ),
    );
  }

  // Jadwal item
  Widget _buildScheduleItem({
    required String time,
    required String title,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.schedule, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Detail kelas
  Widget _buildClassDetail() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.book, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Matematika - SMP',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person, 'Private - Bu Ismaturrohmah'),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.access_time, 'Senin 08.00 | Rabu 09.00'),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.analytics, '3/8 Pertemuan'),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton('Materi', Icons.description, () {}),
              _buildActionButton('Quiz', Icons.quiz, () {}),
              _buildActionButton('Forum', Icons.forum, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textLight),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.textDark),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
            color: AppColors.primary.withOpacity(0.05),
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
            color: Colors.white,
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