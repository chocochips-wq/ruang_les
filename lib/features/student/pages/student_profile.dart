import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import '../widgets/student_drawer.dart';
import '../widgets/student_bottom_nav.dart';

class ProfileMurid extends StatefulWidget {
  const ProfileMurid({super.key});

  @override
  State<ProfileMurid> createState() => _ProfileMuridState();
}

class _ProfileMuridState extends State<ProfileMurid> {
  int _selectedIndex = 0;

  final _profileData = {
    'name': 'Alfito',
    'phone': '0812-3456-7890',
    'alamat': 'Jalan Kelapa 2, Depok',
    'sekolah': 'SMPN 1 Depok',
    'kelas': '8',
  };

  final _badges = [
    {'title': 'Siswa Aktif', 'icon': '🏆', 'color': const Color(0xFFFFD700)},
    {'title': 'Juara Quiz', 'icon': '⭐', 'color': const Color(0xFF4CAF50)},
    {'title': 'Rajin Belajar', 'icon': '📚', 'color': const Color(0xFF2196F3)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: const Text('Profil Kamu',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: const DrawerMurid(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildProgressSection(),
                    const SizedBox(height: 20),
                    _buildBadges(),
                    const SizedBox(height: 20),
                    _buildInfoCard(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: FooterMurid(selectedIndex: 2));
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const CircleAvatar(
                  radius: 55,
                  backgroundImage: AssetImage('../assets/gambar/profile.png'),
                  backgroundColor: Colors.white,
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: AppColors.primary, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _profileData['name']!,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_profileData['sekolah']} - Kelas ${_profileData['kelas']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '📊 ',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                'Perkembanganmu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressItem('Tugas Selesai', 24, 30, Colors.green),
          const SizedBox(height: 16),
          _buildProgressItem('Nilai Rata-rata', 85, 100, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, int value, int max, Color color) {
    double percentage = value / max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              '$value/$max',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildBadges() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🎖️ ',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                'Badge Kamu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _badges.map((badge) {
              return Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: (badge['color'] as Color).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: badge['color'] as Color,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        badge['icon'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      badge['title'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '👤 ',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                'Tentang Kamu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSimpleInfoRow('📞', 'No. Telepon', _profileData['phone']!),
          const SizedBox(height: 12),
          _buildSimpleInfoRow('📍', 'Alamat', _profileData['alamat']!),
          const SizedBox(height: 12),
          _buildSimpleInfoRow('🏫', 'Sekolah', _profileData['sekolah']!),
          const SizedBox(height: 12),
          _buildSimpleInfoRow('📖', 'Kelas', _profileData['kelas']!),
        ],
      ),
    );
  }

  Widget _buildSimpleInfoRow(String emoji, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildBigButton(
          'Ubah Profil',
          Icons.edit,
          Colors.blue,
          () {},
        ),
        const SizedBox(height: 12),
        _buildBigButton(
          'Butuh Bantuan?',
          Icons.help_outline,
          Colors.green,
          () {},
        ),
      ],
    );
  }

  Widget _buildBigButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
