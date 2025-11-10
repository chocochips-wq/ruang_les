import 'package:flutter/material.dart';
import '../../pengaturan/warna.dart';
import 'drawer/drawer.dart';
import 'drawer/buttomnav.dart'; 

class ProfileMurid extends StatefulWidget {
  const ProfileMurid({super.key});

  @override
  State<ProfileMurid> createState() => _ProfileMuridState();
}

class _ProfileMuridState extends State<ProfileMurid> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Mengatur warna ikon burger menjadi putih
        ),
      ),
      drawer: const DrawerMurid(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto Profil dan Edit Profile
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('../assets/gambar/profile.png'), // Ganti dengan foto profil pengguna
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        // Aksi untuk edit profil
                        // Navigasi ke halaman edit profil jika diperlukan
                      },
                      child: const Text(
                        '(Edit Profil)',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Detail Profil
              _buildProfileDetail('Nama Lengkap', 'Alfito'),
              _buildProfileDetail('Email', 'alfito@email.com'),
              _buildProfileDetail('Alamat', 'Jalan kelapa 2 Depok'),
              _buildProfileDetail('No. HP', '0812-3456-7890'),
              const SizedBox(height: 24),

              // Sekolah & Kelas
              _buildProfileDetail('Sekolah', 'SMPN 1 DEPOK'),
              _buildProfileDetail('Kelas', '8'),
              _buildProfileDetail('Bergabung Sejak', '12 Januari 2025'),
              const SizedBox(height: 24),

              // Status Akun
              const Row(
                children: [
                  Text(
                    'Status Akun : ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Aktif',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FooterMurid(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Widget untuk menampilkan detail profil
  Widget _buildProfileDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$title : ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
