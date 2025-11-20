import 'package:flutter/material.dart';
import '../../../pengaturan/warna.dart';
import '../drawer/appbar.dart'; // Import scaffold baru
import 'pengajar_forum.dart';

class PengajarKelasPage extends StatefulWidget {
  const PengajarKelasPage({super.key});

  @override
  State<PengajarKelasPage> createState() => _PengajarKelasPageState();
}

class _PengajarKelasPageState extends State<PengajarKelasPage> {
  int _selectedMenuIndex = 2; // Index untuk Kelas Saya

  // Data dummy kelas
  final List<Map<String, dynamic>> _kelasList = [
    {
      'id': '1',
      'namaKelas': 'Semi Private',
      'mapel': 'Matematika - Aljabar - SMP',
      'pengajar': 'Ismaturrohmah',
      'color': Color(0xFF4D9B91),
    },
    {
      'id': '2',
      'namaKelas': 'Private',
      'mapel': 'English - Grammar - SD',
      'pengajar': 'Ismaturrohmah',
      'color': Color(0xFF5B9BD5),
    },
    {
      'id': '3',
      'namaKelas': 'Reguler',
      'mapel': 'Bahasa Indonesia - Menulis - SD',
      'pengajar': 'Ismaturrohmah',
      'color': Color(0xFFE67E22),
    },
    {
      'id': '4',
      'namaKelas': 'Semi Private',
      'mapel': 'Ilmu Pengetahuhan Alam - Kimia - SMP',
      'pengajar': 'Ismaturrohmah',
      'color': Color(0xFF9B59B6),
    },
  ];

  void _onMenuSelected(int index) {
    setState(() {
      _selectedMenuIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PengajarScaffold(
      // title: 'Kelas Saya', // Bisa dihapus biar otomatis dari index
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: _onMenuSelected,
      onNotificationTap: () {
        print('Notifikasi diklik');
        // Navigator.pushNamed(context, AppRoutes.pengajarNotifikasi);
      },
      body: Stack(
        children: [
          _kelasList.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _kelasList.length,
                  itemBuilder: (context, index) {
                    return _buildKelasCard(_kelasList[index]);
                  },
                ),
          
          // FloatingActionButton
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _showAddKelasDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: AppColors.textWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKelasCard(Map<String, dynamic> kelas) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _navigateToKelasForum(kelas);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: kelas['color'],
          ),
          child: Stack(
            children: [
              // Pattern decoration
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nama Kelas
                    Text(
                      kelas['namaKelas'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Mata Pelajaran
                    Text(
                      kelas['mapel'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Nama Pengajar
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          kelas['pengajar'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu button
              Positioned(
                right: 8,
                top: 8,
                child: PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 24,
                  ),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 20, color: Colors.black87),
                          SizedBox(width: 12),
                          Text('Edit Kelas'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text(
                            'Hapus Kelas',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteDialog(kelas);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Kelas',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan kelas pertama Anda',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToKelasForum(Map<String, dynamic> kelas) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanForumKelas(kelasData: kelas),
      ),
    );
  }

  void _showAddKelasDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Tambah Kelas',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('Fitur tambah kelas akan segera hadir'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> kelas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Hapus Kelas',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
            'Apakah Anda yakin ingin menghapus kelas "${kelas['namaKelas']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _kelasList.removeWhere((item) => item['id'] == kelas['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kelas "${kelas['namaKelas']}" telah dihapus'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}