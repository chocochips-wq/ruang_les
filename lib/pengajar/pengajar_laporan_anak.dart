import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import 'drawer/drawer.dart';

class PengajarNilai extends StatefulWidget {
  const PengajarNilai({super.key});

  @override
  State<PengajarNilai> createState() => _PengajarNilaiState();
}

class _PengajarNilaiState extends State<PengajarNilai> {
  int _selectedMenuIndex = 4;

  final List<Map<String, dynamic>> _siswaList = [
    {
      'nama': 'Agustian',
      'kelas': 'Matematika - SMP',
      'catatan': '',
    },
    {
      'nama': 'Tiyam',
      'kelas': 'Matematika - SD',
      'catatan': '',
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
          'Laporan Anak',
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _siswaList.length,
        itemBuilder: (context, index) {
          return _buildSiswaCard(_siswaList[index], index);
        },
      ),
    );
  }

  Widget _buildSiswaCard(Map<String, dynamic> siswa, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      siswa['nama'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      siswa['kelas'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Catatan:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            siswa['catatan'].isEmpty 
                ? 'Belum ada catatan' 
                : siswa['catatan'],
            style: TextStyle(
              fontSize: 14,
              color: siswa['catatan'].isEmpty 
                  ? Colors.grey.shade400 
                  : AppColors.textDark,
              fontStyle: siswa['catatan'].isEmpty 
                  ? FontStyle.italic 
                  : FontStyle.normal,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showInputCatatanDialog(siswa, index),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Tambah/Edit Catatan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInputCatatanDialog(Map<String, dynamic> siswa, int index) {
    final TextEditingController catatanController = 
        TextEditingController(text: siswa['catatan']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Catatan untuk ${siswa['nama']}'),
        content: TextField(
          controller: catatanController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Tulis catatan di sini...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _siswaList[index]['catatan'] = catatanController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Catatan berhasil disimpan')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}