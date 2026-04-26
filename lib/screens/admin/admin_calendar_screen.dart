// lib/screens/admin/admin_calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/reservation_provider.dart';
import '../../models/reservation_model.dart';
import '../../models/app_constants.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminCalendarScreen extends StatefulWidget {
  const AdminCalendarScreen({super.key});
  @override State<AdminCalendarScreen> createState() =>
      _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends State<AdminCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Reservation> _eventsForDay(
      ReservationProvider res, DateTime day) {
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
    final res = context.watch<ReservationProvider>();
    final selected = _selectedDay ?? DateTime.now();
    final dayEvents = _eventsForDay(res, selected);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.primary,
            title: const Text('Kalender Reservasi'),
            actions: [
              IconButton(
                icon: const Icon(Icons.today, color: Colors.white),
                onPressed: () => setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDay = DateTime.now();
                }),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(children: [
              // Calendar
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
                    CalendarFormat.twoWeeks: '2 Minggu',
                    CalendarFormat.week: 'Minggu',
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (sel, foc) => setState(() {
                    _selectedDay = sel;
                    _focusedDay = foc;
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
                    selectedTextStyle: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold),
                    markerDecoration: const BoxDecoration(
                        color: AppTheme.accent, shape: BoxShape.circle),
                    markersMaxCount: 3,
                    markerSize: 6,
                    markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                    weekendTextStyle: const TextStyle(color: AppTheme.error),
                    defaultTextStyle: const TextStyle(color: AppTheme.textPri),
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
                        color: AppTheme.textPri, fontSize: 16,
                        fontWeight: FontWeight.bold),
                    leftChevronIcon: const Icon(Icons.chevron_left,
                        color: AppTheme.primary),
                    rightChevronIcon: const Icon(Icons.chevron_right,
                        color: AppTheme.primary),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                        color: AppTheme.textSec, fontWeight: FontWeight.w600,
                        fontSize: 12),
                    weekendStyle: TextStyle(
                        color: AppTheme.error, fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                ),
              ),

              // Day events
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: SectionHeader(
                  title: dayEvents.isEmpty
                      ? 'Tidak ada tamu hari ini'
                      : '${dayEvents.length} tamu — ${formatDate(selected.toIso8601String())}',
                ),
              ),

              if (dayEvents.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(children: [
                    Icon(Icons.event_available,
                        size: 44, color: AppTheme.accent.withOpacity(0.4)),
                    const SizedBox(height: 8),
                    const Text('Tidak ada reservasi pada hari ini',
                        style: TextStyle(color: AppTheme.textSec)),
                  ]),
                ).animate().fadeIn(duration: 300.ms)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: dayEvents.length,
                  itemBuilder: (_, i) {
                    final r = dayEvents[i];
                    return _EventTile(reservation: r, index: i,
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

class _EventTile extends StatelessWidget {
  final Reservation reservation;
  final int index;
  final VoidCallback onTap;
  const _EventTile(
      {required this.reservation, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(reservation.status);
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
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(reservation.namaTamu,
                style: const TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 14, color: AppTheme.textPri)),
            const SizedBox(height: 3),
            Text('${reservation.jenisKamar} · ${reservation.jumlahKamar} kamar',
                style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
            const SizedBox(height: 3),
            Text(
              '${formatDate(reservation.checkIn)} → ${formatDate(reservation.checkOut)}',
              style: const TextStyle(color: AppTheme.textSec, fontSize: 11),
            ),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            StatusBadge(status: reservation.status, small: true),
            const SizedBox(height: 6),
            Text(formatRupiah(reservation.totalHarga),
                style: const TextStyle(color: AppTheme.accent,
                    fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ]),
      ),
    ).animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0, duration: 300.ms);
  }
}
