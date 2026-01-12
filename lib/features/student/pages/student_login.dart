import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/routes.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        // Firebase login
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        // Navigate to student home
        Navigator.of(context).pushReplacementNamed(AppRoutes.muridBeranda);
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;

        String errorMessage = 'Login gagal';
        if (e.code == 'user-not-found') {
          errorMessage = 'Email tidak terdaftar';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Password salah';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Email tidak valid';
        } else if (e.code == 'user-disabled') {
          errorMessage = 'Akun telah dinonaktifkan';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // Animated Welcome Emoji
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.5 + (value * 0.5),
                    child: Text(
                      '👨‍🎓',
                      style: TextStyle(
                        fontSize: 80,
                        color: Colors.primaries[
                            DateTime.now().second % Colors.primaries.length],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Welcome text
              Column(
                children: [
                  Text(
                    'Selamat Datang di Ruang Les! 🎉',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mari mulai petualangan belajarmu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email Kamu',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.primary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
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
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Kata Sandi Kamu',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outlined,
                            color: AppColors.primary,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Kata sandi minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 3,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Masuk Sekarang',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: Colors.grey[300],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'atau',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Register Link
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.daftar);
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Belum punya akun? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    children: const [
                      TextSpan(
                        text: 'Daftar di sini',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Forgot Password Link
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.lupaPassword);
                },
                child: Text(
                  'Lupa Kata Sandi?',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Tips section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue[200]!,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gunakan email dan kata sandi yang telah kamu daftarkan sebelumnya',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
