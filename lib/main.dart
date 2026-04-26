// lib/main.dart
// Entry point aplikasi Flutter - Hotel Reservasi Grand Mugarsari
// Setup: MultiProvider, routes, MaterialApp

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/reservation_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reservations_screen.dart';
import 'screens/reservation_detail_screen.dart';
import 'screens/reservation_form_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HotelReservasiApp());
}

class HotelReservasiApp extends StatelessWidget {
  const HotelReservasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // ── Provider Registration ──────────────────────────────────────
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
      ],
      child: MaterialApp(
        title: 'Hotel Reservasi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,

        // ── Initial Route ─────────────────────────────────────────
        initialRoute: '/',

        // ── Named Routes ──────────────────────────────────────────
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/reservations': (_) => const ReservationsScreen(),
          '/reservations/detail': (_) => const ReservationDetailScreen(),
          '/reservations/add': (_) => const ReservationFormScreen(),
          '/reservations/edit': (_) => const ReservationFormScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }
}
