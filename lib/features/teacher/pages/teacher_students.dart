import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import 'drawer/appbar.dart';

// Model Data Murid
class Murid {
  int? id;
  String nama;
  String? kelas;
  String? email;
  String? noHp;
  String status; // Aktif / Tidak Aktif
  DateTime? tanggalDaftar;

  Murid({
    this.id,
    required this.nama,
    this.kelas,
    this.email,
    this.noHp,
    this.status = 'Aktif',
    this.tanggalDaftar,
  });
}

class HalamanKelolaMurid extends StatefulWidget {
  const HalamanKelolaMurid({super.key});

  @override
  State<HalamanKelolaMurid> createState() => _HalamanKelolaMuridState();
}

class _HalamanKelolaMuridState extends State<HalamanKelolaMurid> {
  int _selectedMenuIndex = 7; // Index untuk menu Kelola Murid
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'Semua';
  
  // Data Murid
  List<Murid> _muridList = [
    Murid(id: 1, nama: 'Putri', kelas: 'SP.TK', email: 'putri@gmail.com', tanggalDaftar: DateTime(2024, 1, 15)),
    Murid(id: 2, nama: 'Rexy', kelas: 'P.TK', email: 'rexy@gmail.com', tanggalDaftar: DateTime(2024, 1, 20)),
    Murid(id: 3, nama: 'Syauqi', kelas: 'SPE.3', email: 'syauqi@gmail.com', tanggalDaftar: DateTime(2024, 2, 5)),
    Murid(id: 4, nama: 'Nadiya', kelas: 'SP.4', email: 'nadiya@gmail.com', tanggalDaftar: DateTime(2024, 2, 10)),
    Murid(id: 5, nama: 'Keysha', kelas: 'SP.5', email: 'keysha@gmail.com', tanggalDaftar: DateTime(2024, 3, 1)),
    Murid(id: 6, nama: 'Jelovha', kelas: 'SP.5', email: 'jelovha@gmail.com', tanggalDaftar: DateTime(2024, 3, 5)),
    Murid(id: 7, nama: 'Hanum', kelas: 'SP.6', email: 'hanum@gmail.com', tanggalDaftar: DateTime(2024, 3, 10)),
    Murid(id: 8, nama: 'Choirul', kelas: 'R.4', email: 'choirul@gmail.com', tanggalDaftar: DateTime(2024, 3, 15)),
    Murid(id: 9, nama: 'Alita', kelas: 'SP.4', email: 'alita@gmail.com', tanggalDaftar: DateTime(2024, 4, 1)),
    Murid(id: 10, nama: 'Abiyu', kelas: 'SP.5', email: 'abiyu@gmail.com', tanggalDaftar: DateTime(2024, 4, 5)),
    Murid(id: 11, nama: 'Syafiqah', kelas: 'SP.6', email: 'syafiqah@gmail.com', tanggalDaftar: DateTime(2024, 4, 10)),
    Murid(id: 12, nama: 'Elviana', kelas: 'R.5', email: 'elviana@gmail.com', tanggalDaftar: DateTime(2024, 4, 15)),
    Murid(id: 13, nama: 'Irghi', kelas: 'SPE.5', email: 'irghi@gmail.com', tanggalDaftar: DateTime(2024, 5, 1)),
    Murid(id: 14, nama: 'Kayden', kelas: 'SP.5', email: 'kayden@gmail.com', tanggalDaftar: DateTime(2024, 5, 5)),
    Murid(id: 15, nama: 'Nabila', kelas: 'R.6', email: 'nabila@gmail.com', tanggalDaftar: DateTime(2024, 5, 10)),
    Murid(id: 16, nama: 'Naysila', kelas: 'SP.6', email: 'naysila@gmail.com', tanggalDaftar: DateTime(2024, 5, 15)),
    Murid(id: 17, nama: 'Kayla', kelas: 'SP.7', email: 'kayla@gmail.com', tanggalDaftar: DateTime(2024, 6, 1)),
    Murid(id: 18, nama: 'Nayla', kelas: 'SP.7', email: 'nayla@gmail.com', tanggalDaftar: DateTime(2024, 6, 5)),
    Murid(id: 19, nama: 'Alvaro', kelas: 'R.7', email: 'alvaro@gmail.com', tanggalDaftar: DateTime(2024, 6, 10)),
    Murid(id: 20, nama: 'Haikal', kelas: 'SP.8', email: 'haikal@gmail.com', tanggalDaftar: DateTime(2024, 6, 15)),
    Murid(id: 21, nama: 'Labib', kelas: 'SP.8', email: 'labib@gmail.com', tanggalDaftar: DateTime(2024, 7, 1)),
    Murid(id: 22, nama: 'Sabrina', kelas: 'R.8', email: 'sabrina@gmail.com', tanggalDaftar: DateTime(2024, 7, 5)),
    Murid(id: 23, nama: 'Anindya', kelas: 'SP.9', email: 'anindya@gmail.com', tanggalDaftar: DateTime(2024, 7, 10)),
    Murid(id: 24, nama: 'Laiqa', kelas: 'SP.9', email: 'laiqa@gmail.com', tanggalDaftar: DateTime(2024, 7, 15)),
    Murid(id: 25, nama: 'Ashylla', kelas: 'R.9', email: 'ashylla@gmail.com', tanggalDaftar: DateTime(2024, 8, 1)),
    Murid(id: 26, nama: 'Fadli', kelas: 'SP.10', email: 'fadli@gmail.com', tanggalDaftar: DateTime(2024, 8, 5)),
    Murid(id: 27, nama: 'Daffa', kelas: 'SP.10', email: 'daffa@gmail.com', tanggalDaftar: DateTime(2024, 8, 10)),
    Murid(id: 28, nama: 'Arjuna', kelas: 'R.10', email: 'arjuna@gmail.com', tanggalDaftar: DateTime(2024, 8, 15)),
    Murid(id: 29, nama: 'Alvaro', kelas: 'SP.11', email: 'alvaro2@gmail.com', tanggalDaftar: DateTime(2024, 9, 1)),
    Murid(id: 30, nama: 'Sahla', kelas: 'SP.11', email: 'sahla@gmail.com', tanggalDaftar: DateTime(2024, 9, 5)),
    Murid(id: 31, nama: 'Zhainah', kelas: 'R.11', email: 'zhainah@gmail.com', tanggalDaftar: DateTime(2024, 9, 10)),
    Murid(id: 32, nama: 'Naqiyya', kelas: 'SP.12', email: 'naqiyya@gmail.com', tanggalDaftar: DateTime(2024, 9, 15)),
    Murid(id: 33, nama: 'Azka', kelas: 'P.7', email: 'azka@gmail.com', tanggalDaftar: DateTime(2024, 10, 1)),
  ];

  List<Murid> get filteredMuridList {
    return _muridList.where((murid) {
      final matchesSearch = murid.nama.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                           (murid.kelas?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
      final matchesFilter = _filterStatus == 'Semua' || murid.status == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PengajarScaffold(
      title: 'Kelola Murid',
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) => setState(() => _selectedMenuIndex = index),
      onNotificationTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi')),
        );
      },
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSearchAndFilter(),
                  const SizedBox(height: 24),
                  _buildMuridList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.people, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kelola Data Murid',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${_muridList.length} murid terdaftar',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddEditDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari nama atau kelas...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          initialValue: _filterStatus,
          onSelected: (value) => setState(() => _filterStatus = value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                Text(_filterStatus),
              ],
            ),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Semua', child: Text('Semua')),
            const PopupMenuItem(value: 'Aktif', child: Text('Aktif')),
            const PopupMenuItem(value: 'Tidak Aktif', child: Text('Tidak Aktif')),
          ],
        ),
      ],
    );
  }

  Widget _buildMuridList() {
    final muridList = filteredMuridList;

    if (muridList.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Tidak ada murid ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: muridList.length,
      itemBuilder: (context, index) {
        final murid = muridList[index];
        return _buildMuridCard(murid);
      },
    );
  }

  Widget _buildMuridCard(Murid murid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          radius: 28,
          child: Text(
            murid.nama[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        title: Text(
          murid.nama,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.class_, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  murid.kelas ?? 'Belum ada kelas',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: murid.status == 'Aktif' 
                        ? Colors.green.withOpacity(0.1) 
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    murid.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: murid.status == 'Aktif' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'detail',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  const Text('Detail'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 20, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  const Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  const Text('Hapus'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'detail') {
              _showDetailDialog(murid);
            } else if (value == 'edit') {
              _showAddEditDialog(murid: murid);
            } else if (value == 'delete') {
              _showDeleteDialog(murid);
            }
          },
        ),
      ),
    );
  }

  void _showAddEditDialog({Murid? murid}) {
    final isEdit = murid != null;
    final namaController = TextEditingController(text: murid?.nama ?? '');
    final kelasController = TextEditingController(text: murid?.kelas ?? '');
    final emailController = TextEditingController(text: murid?.email ?? '');
    final noHpController = TextEditingController(text: murid?.noHp ?? '');
    String status = murid?.status ?? 'Aktif';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isEdit ? Icons.edit : Icons.person_add,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(isEdit ? 'Edit Murid' : 'Tambah Murid'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: kelasController,
                  decoration: InputDecoration(
                    labelText: 'Kelas',
                    prefixIcon: const Icon(Icons.class_),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noHpController,
                  decoration: InputDecoration(
                    labelText: 'No. HP',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    prefixIcon: const Icon(Icons.check_circle),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                    DropdownMenuItem(value: 'Tidak Aktif', child: Text('Tidak Aktif')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => status = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (namaController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama harus diisi')),
                  );
                  return;
                }

                setState(() {
                  if (isEdit) {
                    murid.nama = namaController.text;
                    murid.kelas = kelasController.text;
                    murid.email = emailController.text;
                    murid.noHp = noHpController.text;
                    murid.status = status;
                  } else {
                    final newId = _muridList.isEmpty ? 1 : _muridList.map((m) => m.id!).reduce((a, b) => a > b ? a : b) + 1;
                    _muridList.add(Murid(
                      id: newId,
                      nama: namaController.text,
                      kelas: kelasController.text,
                      email: emailController.text,
                      noHp: noHpController.text,
                      status: status,
                      tanggalDaftar: DateTime.now(),
                    ));
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'Murid berhasil diupdate' : 'Murid berhasil ditambahkan'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(Murid murid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                murid.nama[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                murid.nama,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.class_, 'Kelas', murid.kelas ?? '-'),
            _buildDetailRow(Icons.email, 'Email', murid.email ?? '-'),
            _buildDetailRow(Icons.phone, 'No. HP', murid.noHp ?? '-'),
            _buildDetailRow(
              Icons.calendar_today,
              'Tanggal Daftar',
              murid.tanggalDaftar != null
                  ? '${murid.tanggalDaftar!.day}/${murid.tanggalDaftar!.month}/${murid.tanggalDaftar!.year}'
                  : '-',
            ),
            _buildDetailRow(
              Icons.check_circle,
              'Status',
              murid.status,
              valueColor: murid.status == 'Aktif' ? Colors.green : Colors.red,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Murid murid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Hapus Murid'),
          ],
        ),
        content: Text('Apakah Anda yakin ingin menghapus murid "${murid.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _muridList.removeWhere((m) => m.id == murid.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Murid "${murid.nama}" berhasil dihapus'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}