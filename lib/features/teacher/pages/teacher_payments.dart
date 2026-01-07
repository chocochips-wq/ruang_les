import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import '../widgets/teacher_app_bar.dart';

class PengajarPembayaran extends StatefulWidget {
  const PengajarPembayaran({super.key});

  @override
  State<PengajarPembayaran> createState() => _PengajarPembayaranState();
}

class _PengajarPembayaranState extends State<PengajarPembayaran> {
  int _selectedMenuIndex = 5;

  final List<Map<String, dynamic>> _pembayaranList = [
    {
      'nama': 'Zayn Athallah',
      'kelas': 'Private - SD',
      'status': 'Belum Lunas',
      'lunas': false,
    },
    {
      'nama': 'Alfito',
      'kelas': 'Reguler - PAUD',
      'status': 'Lunas',
      'lunas': true,
    },
    {
      'nama': 'Jonathan',
      'kelas': 'Semi Private - SD',
      'status': 'Lunas',
      'lunas': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      title: 'Kelola Pembayaran', // Atau hapus untuk pakai default "Pembayaran"
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) => setState(() => _selectedMenuIndex = index),
      onNotificationTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda memiliki 3 notifikasi baru')),
        );
      },
      body: Container(
        color: AppColors.background,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _pembayaranList.length,
          itemBuilder: (context, index) {
            return _buildPembayaranCard(_pembayaranList[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildPembayaranCard(Map<String, dynamic> data, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: data['lunas'] ? Colors.green : Colors.orange,
          width: 1.5,
        ),
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
                      data['nama'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      data['kelas'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: data['lunas']
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: data['lunas'] ? Colors.green : Colors.orange,
                  ),
                ),
                child: Text(
                  data['status'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: data['lunas'] ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          if (!data['lunas'])
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showKonfirmasiDialog(data, index),
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Tandai Lunas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Pembayaran telah lunas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showKonfirmasiDialog(Map<String, dynamic> data, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Konfirmasi Pembayaran'),
        content: Text(
          'Apakah Anda yakin pembayaran ${data['nama']} sudah lunas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _pembayaranList[index]['lunas'] = true;
                _pembayaranList[index]['status'] = 'Lunas';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Text('Pembayaran ${data['nama']} telah lunas'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Ya, Lunas'),
          ),
        ],
      ),
    );
  }
}
