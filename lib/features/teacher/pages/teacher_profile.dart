import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/routes.dart';
import '../widgets/teacher_app_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/teacher_provider.dart';

class PengajarProfil extends StatefulWidget {
  const PengajarProfil({super.key});

  @override
  State<PengajarProfil> createState() => _PengajarProfilState();
}

class _PengajarProfilState extends State<PengajarProfil> {
  int _selectedMenuIndex = 2; // Profile = index 2

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      title: 'Profile',
      selectedMenuIndex: _selectedMenuIndex,
      onMenuSelected: (index) {
        setState(() => _selectedMenuIndex = index);
      },
      onNotificationTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi')),
        );
      },
      body: Consumer2<AuthProvider, TeacherProvider>(
        builder: (context, authProvider, teacherProvider, child) {
          final user = authProvider.user;
          final teacher = teacherProvider.currentTeacher;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(user.name, user.email),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoCard(
                              name: user.name,
                              email: user.email,
                              phone: user.phone,
                              specialization: teacher?.specialization ?? '-',
                              gender: teacher?.gender,
                              birthDate: teacher?.birthDate,
                              address: teacher?.address,
                            ),
                            const SizedBox(height: 16),
                            _buildEditButton(
                              currentName: user.name,
                              currentPhone: user.phone,
                              currentSpecialization:
                                  teacher?.specialization ?? '',
                              currentGender: teacher?.gender,
                              currentBirthDate: teacher?.birthDate,
                              currentAddress: teacher?.address,
                            ),
                            const SizedBox(height: 16),
                            _buildLogoutButton(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const ClipOval(
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showPhotoOptions,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: const Text(
              '👨‍🏫 Pengajar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String name,
    required String email,
    required String phone,
    required String specialization,
    String? gender,
    DateTime? birthDate,
    String? address,
  }) {
    return Container(
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
          const Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Informasi Pribadi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'Nama Lengkap', name),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email, 'Email', email),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, 'No. Telepon', phone),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.work, 'Spesialisasi', specialization),
          if (gender != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.wc, 'Jenis Kelamin', gender),
          ],
          if (birthDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.cake,
              'Tanggal Lahir',
              '${birthDate.day}/${birthDate.month}/${birthDate.year}',
            ),
          ],
          if (address != null && address.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.home, 'Alamat', address),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton({
    required String currentName,
    required String currentPhone,
    required String currentSpecialization,
    String? currentGender,
    DateTime? currentBirthDate,
    String? currentAddress,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _showEditDialog(
          currentName,
          currentPhone,
          currentSpecialization,
          currentGender,
          currentBirthDate,
          currentAddress,
        ),
        icon: const Icon(Icons.edit, size: 20),
        label: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Apakah Anda yakin ingin keluar?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child:
                      const Text('Keluar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (confirm == true && context.mounted) {
            final teacherProvider = context.read<TeacherProvider>();
            final authProvider = context.read<AuthProvider>();

            await authProvider.logout();
            teacherProvider.clearTeacherData();

            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.pilihRole,
                (route) => false,
              );
            }
          }
        },
        icon: const Icon(Icons.logout, size: 20, color: Colors.red),
        label: const Text(
          'Logout',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
    String currentName,
    String currentPhone,
    String currentSpecialization,
    String? currentGender,
    DateTime? currentBirthDate,
    String? currentAddress,
  ) {
    final namaCtrl = TextEditingController(text: currentName);
    final noHpCtrl = TextEditingController(text: currentPhone);
    final specCtrl = TextEditingController(text: currentSpecialization);
    final alamatCtrl = TextEditingController(text: currentAddress);
    String? selectedGender = currentGender;
    DateTime? selectedBirthDate = currentBirthDate;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Edit Profile',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(namaCtrl, 'Nama Lengkap', Icons.person),
                  const SizedBox(height: 12),
                  _buildTextField(noHpCtrl, 'No. Telepon', Icons.phone,
                      inputType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildTextField(specCtrl, 'Spesialisasi', Icons.work),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      prefixIcon:
                          const Icon(Icons.wc, color: AppColors.primary),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Laki-laki', child: Text('Laki-laki')),
                      DropdownMenuItem(
                          value: 'Perempuan', child: Text('Perempuan')),
                    ],
                    onChanged: (v) => setState(() => selectedGender = v),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedBirthDate ?? DateTime(1990),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedBirthDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Tanggal Lahir',
                        prefixIcon:
                            const Icon(Icons.cake, color: AppColors.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        selectedBirthDate != null
                            ? '${selectedBirthDate!.day}/${selectedBirthDate!.month}/${selectedBirthDate!.year}'
                            : 'Pilih tanggal',
                        style: TextStyle(
                          color: selectedBirthDate != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(alamatCtrl, 'Alamat', Icons.home,
                      maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final authProvider = context.read<AuthProvider>();
                  final teacherProvider = context.read<TeacherProvider>();

                  // 1. Update User Profile (Auth)
                  final successAuth = await authProvider.updateProfile(
                    name: namaCtrl.text,
                    phone: noHpCtrl.text,
                  );

                  // 2. Update Teacher Profile (Specialization + biodata)
                  bool successTeacher = true;
                  final currentTeacher = teacherProvider.currentTeacher;
                  if (currentTeacher != null) {
                    final updatedTeacher = currentTeacher.copyWith(
                      specialization: specCtrl.text,
                      gender: selectedGender,
                      birthDate: selectedBirthDate,
                      address: alamatCtrl.text,
                    );
                    successTeacher =
                        await teacherProvider.updateTeacher(updatedTeacher);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    if (successAuth && successTeacher) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Profile berhasil diperbarui')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(authProvider.error ??
                              teacherProvider.error ??
                              'Gagal update profile'),
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: inputType,
      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ubah Foto Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur kamera segera hadir')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur galeri segera hadir')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
