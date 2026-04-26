// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/reservation_provider.dart';
import 'providers/reschedule_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_shell.dart';
import 'screens/reservation_detail_screen.dart';
import 'screens/reservation_form_screen.dart';
import 'screens/admin/admin_reservations_screen.dart';
import 'screens/admin/admin_reschedule_screen.dart';
import 'screens/user/reschedule_screen.dart';
import 'widgets/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const HotelApp());
}

class HotelApp extends StatelessWidget {
  const HotelApp({super.key});

  // Custom page route with slide + fade transition
  static Route<dynamic> _buildRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/':
        page = const SplashScreen();
      case '/login':
        page = const LoginScreen();
      case '/register':
        page = const RegisterScreen();
      case '/home':
        page = const HomeShell();
      case '/reservations/detail':
        page = const ReservationDetailScreen();
      case '/reservations/add':
        page = const ReservationFormScreen();
      case '/reservations/edit':
        page = const ReservationFormScreen();
      case '/reservations/reschedule':
        page = const RescheduleScreen();
      case '/admin/reschedule-requests':
        page = const AdminRescheduleScreen();
      case '/reservations/standalone':
        page = const AdminReservationsScreen();
      default:
        page = const SplashScreen();
    }
    return _SmoothRoute(page: page, settings: settings);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => RescheduleProvider()),
      ],
      child: MaterialApp(
        title: 'Hotel Reservasi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/',
        onGenerateRoute: _buildRoute,
      ),
    );
  }
}

// ── Smooth page transition ────────────────────────────────────────────────────
class _SmoothRoute extends PageRouteBuilder {
  final Widget page;

  _SmoothRoute({required this.page, required RouteSettings settings})
      : super(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
                parent: animation, curve: Curves.easeOutCubic);

            // Fade + slide up for overlay screens
            final isOverlay = settings.name == '/reservations/detail' ||
                settings.name == '/reservations/add' ||
                settings.name == '/reservations/edit' ||
                settings.name == '/reservations/reschedule' ||
                settings.name == '/admin/reschedule-requests' ||
                settings.name == '/reservations/standalone';

            if (isOverlay) {
              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
                child: SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0, 0.06), end: Offset.zero)
                      .animate(curved),
                  child: child,
                ),
              );
            }

            // Slide + fade for main navigation
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
              child: child,
            );
          },
        );
}
