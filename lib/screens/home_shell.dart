// lib/screens/home_shell.dart
// Persistent shell with animated bottom nav — routes differ by role.
// Admin  : 0=Dashboard  1=Reservasi  2=Kalender  3=Profil
// Staff  : 0=Beranda    1=Booking    2=Kalender  3=Profil

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reservation_provider.dart';
import '../providers/reschedule_provider.dart';
import '../widgets/app_theme.dart';

// Admin screens
import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_reservations_screen.dart';
import 'admin/admin_calendar_screen.dart';
import 'admin/admin_profile_screen.dart';

// User screens
import 'user/user_home_screen.dart';
import 'user/user_booking_screen.dart';
import 'user/user_calendar_screen.dart';
import 'user/user_profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationProvider>().load();
      // Admin juga load reschedule requests untuk badge notifikasi
      if (context.read<AuthProvider>().isAdmin) {
        context.read<RescheduleProvider>().load();
      }
    });
  }

  void _go(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    final adminPages = [
      const AdminDashboardScreen(),
      const AdminReservationsScreen(),
      const AdminCalendarScreen(),
      const AdminProfileScreen(),
    ];

    final userPages = [
      const UserHomeScreen(),
      const UserBookingScreen(),
      const UserCalendarScreen(),
      const UserProfileScreen(),
    ];

    final pages = isAdmin ? adminPages : userPages;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0.04, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
      ),
      bottomNavigationBar: _AnimatedBottomNav(
        isAdmin: isAdmin,
        currentIndex: _index,
        onTap: _go,
      ),
    );
  }
}

// ── Animated Bottom Nav ────────────────────────────────────────────────────────
class _AnimatedBottomNav extends StatelessWidget {
  final bool isAdmin;
  final int currentIndex;
  final void Function(int) onTap;
  const _AnimatedBottomNav(
      {required this.isAdmin,
      required this.currentIndex,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final adminItems = [
      const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          activeIcon: Icon(Icons.list_alt),
          label: 'Reservasi'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month),
          label: 'Kalender'),
      BottomNavigationBarItem(
          icon: Consumer<RescheduleProvider>(
            builder: (_, rp, __) => Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.manage_accounts_outlined),
                if (rp.pendingCount > 0)
                  Positioned(
                    right: -4, top: -4,
                    child: Container(
                      width: 14, height: 14,
                      decoration: const BoxDecoration(
                          color: AppTheme.error, shape: BoxShape.circle),
                      child: Center(
                        child: Text('${rp.pendingCount}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          activeIcon: const Icon(Icons.manage_accounts),
          label: 'Profil'),
    ];

    final userItems = const [
      BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Beranda'),
      BottomNavigationBarItem(
          icon: Icon(Icons.hotel_outlined),
          activeIcon: Icon(Icons.hotel),
          label: 'Booking'),
      BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month),
          label: 'Jadwal'),
      BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil'),
    ];

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.10),
              blurRadius: 20, offset: const Offset(0, -4))
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: AppTheme.accent,
        unselectedItemColor: AppTheme.textSec,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: isAdmin ? adminItems : userItems,
      ),
    );
  }
}
