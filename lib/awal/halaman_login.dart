import 'package:flutter/material.dart';
import '../pengaturan/warna.dart';
import '../pengaturan/rute.dart';
import '../komponen/tombol_custom.dart';
import '../komponen/input_text.dart';

class HalamanLogin extends StatefulWidget {
  final String? selectedRole;
  
  const HalamanLogin({super.key, this.selectedRole});

  @override
  State<HalamanLogin> createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Dummy data untuk login
  final Map<String, Map<String, String>> _dummyUsers = {
    'pengajar@gmail.com': {
      'password': '123456',
      'role': 'pengajar',
      'nama': 'Ibu Ismaturrohmah'
    },
    'murid@gmail.com': {
      'password': '123456',
      'role': 'murid',
      'nama': 'Alfito'
    },
    'orangtua@gmail.com': {
      'password': '123456',
      'role': 'orangtua',
      'nama': 'Agustina Suraisa'
    },
  };

  @override
  void initState() {
    super.initState();
    // Otomatis isi email berdasarkan role yang dipilih
    if (widget.selectedRole != null) {
      switch (widget.selectedRole) {
        case 'pengajar':
          _emailController.text = 'pengajar@gmail.com';
          break;
        case 'murid':
          _emailController.text = 'murid@gmail.com';
          break;
        case 'orangtua':
          _emailController.text = 'orangtua@gmail.com';
          break;
      }
    }
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Cek apakah email ada di dummy data
      if (_dummyUsers.containsKey(email)) {
        final userData = _dummyUsers[email]!;
        
        // Cek password
        if (userData['password'] == password) {
          final role = userData['role']!;
          
          // Validasi role sesuai yang dipilih
          if (widget.selectedRole != null && role != widget.selectedRole) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Akun ini bukan untuk role ${widget.selectedRole}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }
          
          // Navigasi berdasarkan role (DIPERBAIKI)
          String route;
          switch (role) {
            case 'pengajar':
              route = AppRoutes.pengajarBeranda; // ✅ Diperbaiki
              break;
            case 'murid':
              route = AppRoutes.muridBeranda; // ✅ Diperbaiki
              break;
            case 'orangtua':
              route = AppRoutes.orangtuaBeranda; // ✅ Diperbaiki
              break;
            default:
              route = AppRoutes.pengajarBeranda; // ✅ Diperbaiki
          }
          
          // Navigasi ke halaman sesuai role
          Navigator.pushReplacementNamed(context, route);
          
          // Tampilkan snackbar sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selamat datang, ${userData['nama']}!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Password salah
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password salah!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Email tidak ditemukan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email tidak terdaftar!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
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
                      // Tampilkan role yang dipilih
                      if (widget.selectedRole != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Login sebagai ${widget.selectedRole}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                const Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Email Input
                InputText(
                  label: 'Masukkan Email',
                  hint: 'Email',
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
                  label: 'Masukkan Password',
                  hint: 'Password',
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
                
                const SizedBox(height: 12),
                
                // Lupa Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.lupaPassword);
                    },
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Button Masuk
                TombolCustom(
                  teks: 'Masuk',
                  onPressed: _handleLogin,
                ),
                
                const SizedBox(height: 24),
                
                // Belum Punya Akun
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.daftar);
                      },
                      child: const Text(
                        'Daftar disini',
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