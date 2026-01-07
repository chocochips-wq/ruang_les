import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:provider/provider.dart'; // For context.read and Consumer
import '../../../core/utils/colors.dart';
import '../../../core/utils/routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../providers/auth_provider.dart'; // For AuthProvider class

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

  @override
  void initState() {
    super.initState();
    // Pre-fill email only for debug/testing if needed, or remove completely for production
    // Keeping it clear for now or maybe just hint based on role
    if (widget.selectedRole != null && kDebugMode) {
      // Optional: Pre-fill for easier testing if desired
      // switch (widget.selectedRole) {
      //   case 'pengajar':
      //     _emailController.text = 'pengajar@gmail.com';
      //     break;
      //   // ...
      // }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final authProvider = context.read<AuthProvider>();

      // Call login method
      final success = await authProvider.login(email, password);

      if (!mounted) return;

      if (success) {
        final user = authProvider.user;

        // Role Mapping helper
        // Maps UI selection (Indonesian) to DB role (English)
        // Returns true if roles are equivalent
        bool isRoleMatch(String? userRole, String? selectedRole) {
          if (userRole == null || selectedRole == null) return false;

          final dbRole = userRole.toLowerCase();
          final uiRole = selectedRole.toLowerCase();

          // Direct match
          if (dbRole == uiRole) return true;

          // Mapping
          if (dbRole == 'teacher' && uiRole == 'pengajar') return true;
          if (dbRole == 'student' && uiRole == 'murid') return true;
          if (dbRole == 'parent' &&
              (uiRole == 'orangtua' || uiRole == 'orang tua')) return true;

          return false;
        }

        // Validate role
        if (widget.selectedRole != null &&
            !isRoleMatch(user?.role, widget.selectedRole)) {
          // Logout if role doesn't match
          await authProvider.logout();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Akun ini terdaftar sebagai ${user?.role}, bukan ${widget.selectedRole}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Determine route based on role
        String route;
        switch (user?.role) {
          case 'teacher': // AuthProvider uses 'teacher', 'student', 'parent'
          case 'pengajar': // Backwards compatibility if stored as Indonesian
            route = AppRoutes.pengajarBeranda;
            break;
          case 'student':
          case 'murid':
            route = AppRoutes.muridBeranda;
            break;
          case 'parent':
          case 'orangtua':
            route = AppRoutes.orangtuaBeranda;
            break;
          default:
            route = AppRoutes.pengajarBeranda; // Default or error page
        }

        Navigator.pushReplacementNamed(context, route);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat datang, ${user?.name}!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Login gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                      if (widget.selectedRole != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
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
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return TombolCustom(
                      teks: auth.isLoading ? 'Loading...' : 'Masuk',
                      onPressed: auth.isLoading ? null : () => _handleLogin(),
                    );
                  },
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
