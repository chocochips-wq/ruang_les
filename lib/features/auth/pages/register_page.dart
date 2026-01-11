import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/colors.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../providers/auth_provider.dart';

class HalamanDaftar extends StatefulWidget {
  const HalamanDaftar({super.key});

  @override
  State<HalamanDaftar> createState() => _HalamanDaftarState();
}

class _HalamanDaftarState extends State<HalamanDaftar> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedRole = 'Murid'; // Role default

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleDaftar() async {
    if (_formKey.currentState!.validate()) {
      // Logic berdasarkan role
      // - Teacher: Langsung daftar (verified)
      // - Student/Parent: Masuk pending (perlu verifikasi dari teacher)

      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final nama = _namaController.text.trim();

      final authProvider = context.read<AuthProvider>();

      // Mapping role
      String role;
      String verificationStatus;
      
      if (_selectedRole == 'Pengajar') {
        role = 'teacher';
        verificationStatus = 'verified'; // Teacher langsung verified
      } else if (_selectedRole == 'Murid') {
        role = 'student';
        verificationStatus = 'pending'; // Perlu verifikasi
      } else if (_selectedRole == 'Orangtua') {
        role = 'parent';
        verificationStatus = 'pending'; // Perlu verifikasi
      } else {
        role = 'student';
        verificationStatus = 'pending';
      }

      // Prepare role data for student/parent/teacher
      Map<String, dynamic>? roleData;
      if (role == 'student') {
        roleData = {
          'nickname': nama.split(' ').first, // Use first name as nickname
          'fullName': nama,
          'gradeLevel': 'SD 1-3', // Default, bisa diubah nanti
        };
      } else if (role == 'parent') {
        roleData = {
          'address': '', // Default empty, bisa diisi nanti
          'studentIds': [], // Empty array, bisa ditambah nanti
        };
      } else if (role == 'teacher') {
        roleData = {
          'specialization': 'Umum', // Default specialization
          'yearsOfExperience': 0,
          'classIds': [], // Empty array, akan diisi saat membuat kelas
        };
      }

      final success = await authProvider.register(
        email: email,
        password: password,
        name: nama,
        phone: '', // Optional/Later
        role: role,
        verificationStatus: verificationStatus,
        roleData: roleData,
      );

      if (!mounted) return;

      if (success) {
        if (verificationStatus == 'verified') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pendaftaran Berhasil! Silakan Login.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Kembali ke login
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Pendaftaran berhasil! Akun Anda sedang menunggu verifikasi dari Pengajar. Silakan login setelah akun diverifikasi.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
          Navigator.pop(context); // Kembali ke login
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Gagal Mendaftar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon & Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ruang Les',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'By Ismaturrohmah',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Daftar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 24),

                // Pilih Role
                const Text(
                  'Daftar Sebagai',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.textLight.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: AppColors.primary),
                      items: const [
                        DropdownMenuItem(value: 'Murid', child: Text('Murid')),
                        DropdownMenuItem(
                            value: 'Pengajar', child: Text('Pengajar')),
                        DropdownMenuItem(
                            value: 'Orangtua', child: Text('Orang Tua')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Nama Input
                InputText(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  controller: _namaController,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Email Input
                InputText(
                  label: 'Email',
                  hint: 'Masukkan email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password Input
                InputText(
                  label: 'Password',
                  hint: 'Masukkan password',
                  controller: _passwordController,
                  isPassword: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Button Daftar
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return TombolCustom(
                      teks: auth.isLoading ? 'Loading...' : 'Daftar',
                      onPressed: auth.isLoading ? null : () => _handleDaftar(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Sudah Punya Akun
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
