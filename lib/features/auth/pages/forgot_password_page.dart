import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';

class HalamanLupaPassword extends StatefulWidget {
  const HalamanLupaPassword({super.key});

  @override
  State<HalamanLupaPassword> createState() => _HalamanLupaPasswordState();
}

class _HalamanLupaPasswordState extends State<HalamanLupaPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
                const SizedBox(height: 20),

                // Icon & Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Lupa Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Masukkan email Anda untuk reset password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Email Input
                InputText(
                  label: 'Email',
                  hint: 'Masukkan email Anda',
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

                const SizedBox(height: 32),

                // Button Kirim
                TombolCustom(
                  teks: 'Kirim Link Reset',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Tampilkan dialog sukses
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 60,
                          ),
                          content: const Text(
                            'Link reset password telah dikirim ke email Anda',
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            TombolCustom(
                              teks: 'OK',
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Back to Login
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Kembali ke halaman masuk',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
