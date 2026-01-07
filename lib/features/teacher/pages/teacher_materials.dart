import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import '../widgets/teacher_app_bar.dart';
import '../widgets/teacher_bottom_nav.dart';
import 'teacher_material_management.dart';

class PengajarMateri extends StatefulWidget {
  const PengajarMateri({super.key});

  @override
  State<PengajarMateri> createState() => _PengajarMateriState();
}

class _PengajarMateriState extends State<PengajarMateri> {
  int _selectedMenuIndex = 0;

  final List<Map<String, dynamic>> _materiList = [
    {
      'mata_pelajaran': 'Matematika',
      'jumlah': 5,
      'icon': Icons.calculate,
      'color': Colors.blue,
      'deskripsi': 'Aljabar, Geometri, Statistika',
    },
    {
      'mata_pelajaran': 'IPA',
      'jumlah': 3,
      'icon': Icons.science,
      'color': Colors.green,
      'deskripsi': 'Biologi, Fisika, Kimia',
    },
    {
      'mata_pelajaran': 'Bahasa Inggris',
      'jumlah': 4,
      'icon': Icons.language,
      'color': Colors.orange,
      'deskripsi': 'Grammar, Vocabulary, Reading',
    },
    {
      'mata_pelajaran': 'Bahasa Indonesia',
      'jumlah': 6,
      'icon': Icons.book,
      'color': Colors.purple,
      'deskripsi': 'Tata Bahasa, Sastra, Menulis',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ GUNAKAN PengajarScaffold dari appbar.dart
    return TeacherScaffold(
      title: "Kelola Materi",
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) {
        setState(() {
          _selectedMenuIndex = index;
        });
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _materiList.length,
              itemBuilder: (context, index) {
                return _buildMateriCard(_materiList[index]);
              },
            ),
          ),
          // ✅ GUNAKAN PengajarFooter dari bottomnav.dart (urutan: Materi, Home, Profile)
          const TeacherBottomNav(
            currentIndex: 0, // Index 0 = Materi (posisi pertama)
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mata Pelajaran',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih mata pelajaran untuk mengelola materi',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.folder, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_materiList.length} Mata Pelajaran',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD MATERI
  // ============================================================
  Widget _buildMateriCard(Map<String, dynamic> materi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: materi['color'].withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _bukaKelolaMateri(materi),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _buildIconBox(materi),
              const SizedBox(width: 16),
              _buildMateriInfo(materi),
              _buildArrow(materi),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBox(Map<String, dynamic> materi) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            materi['color'],
            materi['color'].withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: materi['color'].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        materi['icon'],
        color: Colors.white,
        size: 36,
      ),
    );
  }

  Widget _buildMateriInfo(Map<String, dynamic> materi) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            materi['mata_pelajaran'],
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            materi['deskripsi'],
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: materi['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_copy_outlined,
                    size: 14, color: materi['color']),
                const SizedBox(width: 4),
                Text(
                  '${materi['jumlah']} Materi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: materi['color'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow(Map<String, dynamic> materi) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: materi['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.arrow_forward_ios, size: 18, color: materi['color']),
    );
  }

  void _bukaKelolaMateri(Map<String, dynamic> materi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherMaterialManagement(
          mataPelajaran: materi['mata_pelajaran'],
          warna: materi['color'],
          icon: materi['icon'],
        ),
      ),
    );
  }
}
