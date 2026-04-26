// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form        = GlobalKey<FormState>();
  final _userCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureP = true, _obscureC = true;

  @override
  void dispose() {
    _userCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    context.read<AuthProvider>().clearError();
    final r = await context.read<AuthProvider>().register(
        _userCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (r['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(r['message'] as String? ?? 'Registrasi berhasil!'),
          backgroundColor: AppTheme.success));
      Navigator.pop(context);
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
          child: Column(children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20)),
                const Expanded(
                  child: Text('Buat Akun Baru', textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 48),
              ]),
            ),
            const Text('Grand Mugarsari Hotel',
                style: TextStyle(color: AppTheme.accent, fontSize: 12,
                    letterSpacing: 1.5)),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(children: [
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
                      child: Column(children: [
                        TextFormField(
                          controller: _userCtrl,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person_outline)),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                            if (v.trim().length < 3) return 'Minimal 3 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined)),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Wajib diisi';
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscureP,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureP
                                  ? Icons.visibility_off : Icons.visibility),
                              onPressed: () =>
                                  setState(() => _obscureP = !_obscureP),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Wajib diisi';
                            if (v.length < 6) return 'Minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmCtrl,
                          obscureText: _obscureC,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _register(),
                          decoration: InputDecoration(
                            labelText: 'Konfirmasi Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureC
                                  ? Icons.visibility_off : Icons.visibility),
                              onPressed: () =>
                                  setState(() => _obscureC = !_obscureC),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Wajib diisi';
                            if (v != _passCtrl.text) return 'Password tidak cocok';
                            return null;
                          },
                        ),

                        // Error
                        Consumer<AuthProvider>(builder: (_, a, __) {
                          if (a.errorMessage == null) {
                            return const SizedBox.shrink();
                          }
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
                              onPressed: a.isLoading ? null : _register,
                              child: a.isLoading
                                  ? const SizedBox(width: 20, height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white)))
                                  : const Text('Daftar Sekarang'),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ).animate().fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, duration: 400.ms),

                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('Sudah punya akun? ',
                        style: TextStyle(color: Colors.white70)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Masuk',
                          style: TextStyle(color: AppTheme.accent,
                              fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
