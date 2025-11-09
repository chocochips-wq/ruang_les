import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import '../pengaturan/rute.dart';

class BerandaOrangtua extends StatefulWidget {
  const BerandaOrangtua({super.key});

  @override
  State<BerandaOrangtua> createState() => _BerandaOrangtuaState();
}

class _BerandaOrangtuaState extends State<BerandaOrangtua> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _dataAnak = [
    {
      'nama': 'Andi Prasetyo',
      'kelas': 'Kelas 10 A',
      'foto': Icons.person,
    },
  ];

  final List<Map<String, dynamic>> _perkembanganAnak = [
    {
      'mataPelajaran': 'Matematika',
      'nilai': '85',
      'kehadiran': '95%',
      'tugas': '8/10',
      'color': Colors.blue,
    },
    {
      'mataPelajaran': 'Bahasa Inggris',
      'nilai': '90',
      'kehadiran': '100%',
      'tugas': '10/10',
      'color': Colors.green,
    },
    {
      'mataPelajaran': 'Fisika',
      'nilai': '78',
      'kehadiran': '90%',
      'tugas': '7/10',
      'color': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _aktivitasTerkini = [
    {
      'judul': 'Mengumpulkan PR Matematika',
      'waktu': '2 jam yang lalu',
      'icon': Icons.assignment_turned_in,
      'color': Colors.green,
    },
    {
      'judul': 'Hadir di Kelas Bahasa Inggris',
      'waktu': '5 jam yang lalu',
      'icon': Icons.check_circle,
      'color': Colors.blue,
    },
    {
      'judul': 'Nilai Quiz Fisika: 85',
      'waktu': '1 hari yang lalu',
      'icon': Icons.grade,
      'color': Colors.orange,
    },
  ];

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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Dashboard Orang Tua',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Halo, Ibu Ningsih!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pantau perkembangan anak Anda',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Data Anak
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text(
                'Anak Saya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),

            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _dataAnak.length,
              itemBuilder: (context, index) {
                final anak = _dataAnak[index];
                return _buildAnakCard(anak);
              },
            ),

            const SizedBox(height: 24),

            // Menu Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    icon: Icons.grade,
                    label: 'Nilai',
                    color: Colors.blue,
                    onTap: () {},
                  ),
                  _buildMenuCard(
                    icon: Icons.calendar_today,
                    label: 'Jadwal',
                    color: Colors.green,
                    onTap: () {},
                  ),
                  _buildMenuCard(
                    icon: Icons.check_circle,
                    label: 'Kehadiran',
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  _buildMenuCard(
                    icon: Icons.payment,
                    label: 'Pembayaran',
                    color: Colors.purple,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Perkembangan Akademik
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perkembangan Akademik',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Detail'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _perkembanganAnak.length,
              itemBuilder: (context, index) {
                final perkembangan = _perkembanganAnak[index];
                return _buildPerkembanganCard(perkembangan);
              },
            ),

            const SizedBox(height: 32),

            // Aktivitas Terkini
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text(
                'Aktivitas Terkini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),

            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _aktivitasTerkini.length,
              itemBuilder: (context, index) {
                final aktivitas = _aktivitasTerkini[index];
                return _buildAktivitasCard(aktivitas);
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Anak',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // Drawer untuk Orang Tua
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header Drawer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ibu Ningsih',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'orangtua@gmail.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate ke halaman profile
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.forum,
                  title: 'Forum',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate ke halaman forum
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.assessment,
                  title: 'Laporan Belajar',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate ke halaman laporan belajar
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.payment,
                  title: 'Pembayaran',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate ke halaman pembayaran
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.feedback,
                  title: 'Feedback',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate ke halaman feedback
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Pengaturan',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate ke halaman pengaturan
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Keluar',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Versi 1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textDark),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppColors.textDark,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildAnakCard(Map<String, dynamic> anak) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              anak['foto'],
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anak['nama'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  anak['kelas'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerkembanganCard(Map<String, dynamic> perkembangan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: perkembangan['color'],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                perkembangan['mataPelajaran'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Nilai', perkembangan['nilai'], Icons.grade),
              _buildStatItem(
                  'Kehadiran', perkembangan['kehadiran'], Icons.check_circle),
              _buildStatItem('Tugas', perkembangan['tugas'], Icons.assignment),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildAktivitasCard(Map<String, dynamic> aktivitas) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: aktivitas['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              aktivitas['icon'],
              color: aktivitas['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aktivitas['judul'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  aktivitas['waktu'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
