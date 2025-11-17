import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import 'drawer/drawer.dart';
import 'drawer/bottomnav.dart';
import 'pengajar_kelola_materi.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: const Text(
          'Kelola Materi',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      drawer: PengajarDrawer(
        selectedMenuIndex: _selectedMenuIndex,
        onMenuSelected: (index) {
          setState(() => _selectedMenuIndex = index);
        },
      ),
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
        ],
      ),
      bottomNavigationBar: const PengajarFooter(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
          Text(
            'Pilih mata pelajaran untuk mengelola materi',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _bukaKelolaMateri(materi),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
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
                ),
                const SizedBox(width: 16),
                Expanded(
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
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: materi['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.file_copy_outlined,
                                  size: 14,
                                  color: materi['color'],
                                ),
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
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: materi['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: materi['color'],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _bukaKelolaMateri(Map<String, dynamic> materi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PengajarKelolaMateri(
          mataPelajaran: materi['mata_pelajaran'],
          warna: materi['color'],
          icon: materi['icon'],
        ),
      ),
    );
  }
}