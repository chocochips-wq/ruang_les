import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import '../widgets/teacher_app_bar.dart';

class PengajarPengaturan extends StatefulWidget {
  const PengajarPengaturan({super.key});

  @override
  State<PengajarPengaturan> createState() => _PengajarPengaturanState();
}

class _PengajarPengaturanState extends State<PengajarPengaturan> {
  int _selectedMenuIndex = 6;
  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      // title: 'Pengaturan', // Opsional, akan auto pakai "Pengaturan" sesuai selectedMenuIndex
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) => setState(() => _selectedMenuIndex = index),
      onNotificationTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda memiliki 3 notifikasi baru')),
        );
      },
      body: Container(
        color: AppColors.background,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              title: 'Pengaturan Akun',
              icon: Icons.account_circle,
              children: [
                _buildListTile(
                  icon: Icons.lock,
                  title: 'Ubah Sandi',
                  subtitle: 'Perbarui kata sandi akun',
                  onTap: _showChangePasswordDialog,
                ),
                _buildListTile(
                  icon: Icons.language,
                  title: 'Bahasa',
                  subtitle: 'Indonesia',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur bahasa tersedia')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
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
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildRadioTile(
    String value,
    String groupValue,
    ValueChanged<String?> onChanged,
  ) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(value),
      activeColor: AppColors.primary,
    );
  }

  void _showChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Ubah Sandi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Sandi Lama',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Sandi Baru',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Sandi Baru',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sandi berhasil diubah')),
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
