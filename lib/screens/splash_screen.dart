// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    await context.read<AuthProvider>().checkSession();
    if (!mounted) return;
    final ok = context.read<AuthProvider>().isLoggedIn;
    Navigator.pushReplacementNamed(context, ok ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primary, AppTheme.primaryDark])),
        child: SafeArea(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppTheme.accent.withOpacity(0.4), width: 2),
                ),
                child: const Icon(Icons.hotel, size: 60, color: AppTheme.accent),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              const Text('Grand Mugarsari',
                  style: TextStyle(color: Colors.white, fontSize: 28,
                      fontWeight: FontWeight.bold, letterSpacing: 1))
                  .animate(delay: 200.ms).fadeIn(duration: 500.ms)
                  .slideY(begin: 0.3, end: 0, duration: 400.ms),

              const SizedBox(height: 6),
              const Text('HOTEL RESERVATION',
                  style: TextStyle(color: AppTheme.accent, fontSize: 12,
                      letterSpacing: 4))
                  .animate(delay: 350.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: 60),

              const SizedBox(width: 28, height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppTheme.accent)))
                  .animate(delay: 500.ms).fadeIn(duration: 400.ms),
            ]),
          ),
        ),
      ),
    );
  }
}
