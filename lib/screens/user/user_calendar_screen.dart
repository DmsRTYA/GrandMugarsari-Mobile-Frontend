// lib/screens/user/user_calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/reservation_provider.dart';
import '../../models/reservation_model.dart';
import '../../models/app_constants.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/common_widgets.dart';

class UserCalendarScreen extends StatefulWidget {
  const UserCalendarScreen({super.key});
  @override State<UserCalendarScreen> createState() =>
      _UserCalendarScreenState();
}

class _UserCalendarScreenState extends State<UserCalendarScreen> {
  DateTime _focusedDay  = DateTime.now();
  DateTime? _selectedDay;

  List<Reservation> _eventsForDay(ReservationProvider res, DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return res.allReservations.where((r) {
      final ci = r.checkInDate;
      final co = r.checkOutDate;
      if (ci == null || co == null) return false;
      final ciDay = DateTime(ci.year, ci.month, ci.day);
      final coDay = DateTime(co.year, co.month, co.day);
      return (d.isAtSameMomentAs(ciDay) || d.isAfter(ciDay)) &&
          d.isBefore(coDay);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final res    = context.watch<ReservationProvider>();
    final sel    = _selectedDay ?? DateTime.now();
    final events = _eventsForDay(res, sel);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.primary,
            title: const Text('Jadwal Saya'),
            actions: [
              IconButton(
                icon: const Icon(Icons.today, color: Colors.white),
                onPressed: () => setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDay = DateTime.now();
                }),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () =>
                    Navigator.pushNamed(context, '/reservations/add'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(children: [
              Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                clipBehavior: Clip.hardEdge,
                child: TableCalendar<Reservation>(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                  eventLoader: (d) => _eventsForDay(res, d),
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Bulan',
                    CalendarFormat.week: 'Minggu',
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (sel, foc) => setState(() {
                    _selectedDay = sel; _focusedDay = foc;
                  }),
                  onPageChanged: (f) => setState(() => _focusedDay = f),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.3),
                        shape: BoxShape.circle),
                    todayTextStyle: const TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.bold),
                    selectedDecoration: const BoxDecoration(
                        color: AppTheme.primary, shape: BoxShape.circle),
                    selectedTextStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    markerDecoration: const BoxDecoration(
                        color: AppTheme.accent, shape: BoxShape.circle),
                    markersMaxCount: 3,
                    markerSize: 6,
                    weekendTextStyle: const TextStyle(color: AppTheme.error),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonDecoration: BoxDecoration(
                        color: AppTheme.accentLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.accent.withOpacity(0.4))),
                    formatButtonTextStyle: const TextStyle(
                        color: AppTheme.accent, fontSize: 12,
                        fontWeight: FontWeight.w600),
                    titleCentered: true,
                    titleTextStyle: const TextStyle(
                        color: AppTheme.textPri, fontSize: 15,
                        fontWeight: FontWeight.bold),
                    leftChevronIcon: const Icon(Icons.chevron_left,
                        color: AppTheme.primary),
                    rightChevronIcon: const Icon(Icons.chevron_right,
                        color: AppTheme.primary),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: AppTheme.textSec,
                        fontWeight: FontWeight.w600, fontSize: 12),
                    weekendStyle: TextStyle(color: AppTheme.error,
                        fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: SectionHeader(
                  title: events.isEmpty
                      ? 'Tidak ada jadwal hari ini'
                      : '${events.length} jadwal — ${formatDate(sel.toIso8601String())}',
                ),
              ),

              if (events.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(children: [
                    Icon(Icons.event_available,
                        size: 44, color: AppTheme.accent.withOpacity(0.35)),
                    const SizedBox(height: 8),
                    const Text('Tidak ada jadwal reservasi',
                        style: TextStyle(color: AppTheme.textSec)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/reservations/add'),
                      icon: const Icon(Icons.add),
                      label: const Text('Buat Booking'),
                    ),
                  ]),
                ).animate().fadeIn(duration: 300.ms)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: events.length,
                  itemBuilder: (_, i) {
                    final r = events[i];
                    return _MyEventTile(r: r, i: i,
                      onTap: () => Navigator.pushNamed(
                          context, '/reservations/detail', arguments: r),
                    );
                  },
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _MyEventTile extends StatelessWidget {
  final Reservation r;
  final int i;
  final VoidCallback onTap;
  const _MyEventTile({required this.r, required this.i, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(r.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 8)],
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(r.namaTamu, style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 3),
            Text('${r.jenisKamar} · ${r.jumlahMalam} malam',
                style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            StatusBadge(status: r.status, small: true),
            const SizedBox(height: 5),
            Text(formatRupiah(r.totalHarga),
                style: const TextStyle(color: AppTheme.accent,
                    fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ]),
      ),
    ).animate(delay: Duration(milliseconds: 60 * i))
        .fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0, duration: 300.ms);
  }
}
