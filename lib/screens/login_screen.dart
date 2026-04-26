// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form     = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure   = true;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    context.read<AuthProvider>().clearError();
    final ok = await context.read<AuthProvider>()
        .login(_emailCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primary, AppTheme.primaryDark,
                Color(0xFF0A1929)])),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                // Brand
                Column(children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.accent.withOpacity(0.4), width: 2)),
                    child: const Icon(Icons.hotel, size: 52,
                        color: AppTheme.accent),
                  ),
                  const SizedBox(height: 16),
                  const Text('Grand Mugarsari',
                      style: TextStyle(color: Colors.white, fontSize: 24,
                          fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                  const SizedBox(height: 4),
                  const Text('Hotel Reservation System',
                      style: TextStyle(color: AppTheme.accent, fontSize: 12,
                          letterSpacing: 2)),
                ])
                    .animate().fadeIn(duration: 500.ms)
                    .slideY(begin: -0.2, end: 0, duration: 500.ms),

                const SizedBox(height: 36),

                // Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: Form(
                    key: _form,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Masuk ke Akun',
                          style: TextStyle(fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPri)),
                      const SizedBox(height: 4),
                      const Text('Selamat datang kembali',
                          style: TextStyle(color: AppTheme.textSec,
                              fontSize: 13)),
                      const SizedBox(height: 22),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined)),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email wajib diisi';
                          if (!v.contains('@')) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_off : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                      ),

                      // Error
                      Consumer<AuthProvider>(builder: (_, a, __) {
                        if (a.errorMessage == null) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.error.withOpacity(0.3)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline,
                                color: AppTheme.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(a.errorMessage!,
                                style: const TextStyle(
                                    color: AppTheme.error, fontSize: 13))),
                          ]),
                        ).animate().shake(duration: 400.ms);
                      }),

                      const SizedBox(height: 22),

                      Consumer<AuthProvider>(builder: (_, a, __) =>
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: a.isLoading ? null : _login,
                            child: a.isLoading
                                ? const SizedBox(width: 20, height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white)))
                                : const Text('Masuk'),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, duration: 400.ms),

                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Belum punya akun? ',
                      style: TextStyle(color: Colors.white70)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Daftar Sekarang',
                        style: TextStyle(color: AppTheme.accent,
                            fontWeight: FontWeight.bold)),
                  ),
                ]).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 16),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
