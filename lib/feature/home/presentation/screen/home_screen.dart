import 'dart:async';
import 'package:digiattend/feature/authentication/data/models/attendance_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:digiattend/core/constants/app_color.dart';
import 'package:digiattend/core/utils/avatar_helper.dart';

import 'package:digiattend/feature/home/presentation/bloc/home_bloc.dart';
import 'package:digiattend/feature/home/presentation/screen/map_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime now = DateTime.now();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeData());

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => mounted ? setState(() => now = DateTime.now()) : null,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ==========================================================================
  // UI BUILD
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, state) {
        if (state.loadingUser || state.user == null) {
          return const Scaffold(
            backgroundColor: AppColor.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColor.primary),
            ),
          );
        }

        final user = state.user!;
        final photoUrl = getFinalPhoto(user.profilePhoto);

        return Scaffold(
          backgroundColor: AppColor.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================================
                // HEADER
                // ============================================================
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColor.primaryLight,
                      backgroundImage: (photoUrl != null)
                          ? NetworkImage(
                              "$photoUrl?v=${DateTime.now().millisecondsSinceEpoch}",
                            )
                          : null,
                      child: (photoUrl == null)
                          ? Text(
                              user.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                color: AppColor.primaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColor.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Batch ${user.batchKe ?? '-'} • ${state.trainingTitle}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColor.subtitleText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(Icons.qr_code, color: AppColor.primaryDark),
                  ],
                ),

                const SizedBox(height: 24),

                // ============================================================
                // LIVE ATTENDANCE
                // ============================================================
                _buildLiveAttendance(state),

                const SizedBox(height: 24),

                // ============================================================
                // STAT
                // ============================================================
                const Text(
                  "Absence Statistics",
                  style: TextStyle(
                    color: AppColor.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildStatistics(state),

                const SizedBox(height: 24),

                _buildTodayStatus(state),

                const SizedBox(height: 24),

                const Text(
                  "Today's Attendance",
                  style: TextStyle(
                    color: AppColor.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildHistory(state),

                const SizedBox(height: 30),

                Center(
                  child: Text(
                    "Created by Geril Valdo",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.subtitleText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // WIDGETS
  // ==========================================================================

  Widget _buildLiveAttendance(HomeState state) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Text(
            "Live Attendance",
            style: TextStyle(
              color: AppColor.subtitleText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              DateFormat("HH:mm:ss").format(now),
              key: ValueKey(now.toString()),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppColor.textColor,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            DateFormat("EEEE, dd MMM yyyy", "id_ID").format(now),
            style: const TextStyle(color: AppColor.subtitleText),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              // CHECK-IN BUTTON
              Expanded(
                child: ElevatedButton(
                  onPressed: state.hasCheckedIn
                      ? null
                      : () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MapScreen(isCheckIn: true),
                            ),
                          );

                          if (res == true) {
                            context
                                .read<HomeBloc>()
                                .add(const RefreshAttendance());
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.hasCheckedIn
                        ? AppColor.border
                        : AppColor.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Check In"),
                ),
              ),

              const SizedBox(width: 12),

              // CHECK-OUT BUTTON
              Expanded(
                child: ElevatedButton(
                  onPressed: (!state.hasCheckedIn || state.hasCheckedOut)
                      ? null
                      : () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MapScreen(isCheckIn: false),
                            ),
                          );
                          if (res == true) {
                            context
                                .read<HomeBloc>()
                                .add(const RefreshAttendance());
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.hasCheckedOut
                        ? AppColor.border
                        : AppColor.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Check Out"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(HomeState state) {
    final history = state.history;

    int hadir = history.where((e) => e.status == "masuk").length;
    int izin = history.where((e) => e.status == "izin").length;
    int telat = history.where((e) {
      if (e.checkInTime == null) return false;
      final t = DateFormat("HH:mm").parse(e.checkInTime!);
      return t.isAfter(DateFormat("HH:mm").parse("08:00"));
    }).length;
    int alfa = history.where((e) {
      return e.status != "masuk" &&
          e.status != "keluar" &&
          e.status != "izin";
    }).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statBox("Hadir", hadir, AppColor.success),
          _statBox("Telat", telat, AppColor.warning),
          _statBox("Izin", izin, AppColor.info),
          _statBox("Alfa", alfa, AppColor.danger),
        ],
      ),
    );
  }

  Widget _statBox(String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(.15),
          child: Text(
            "$count",
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColor.subtitleText),
        ),
      ],
    );
  }

  Widget _buildTodayStatus(HomeState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.hasCheckedIn
                ? state.hasCheckedOut
                    ? "Sudah Check-out"
                    : "Sudah Check-in"
                : "Belum Absen",
            style: TextStyle(
              color: state.hasCheckedIn ? AppColor.success : AppColor.error,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          _statusLine("Check-in", state.checkInTime),
          _statusLine("Check-out", state.checkOutTime),

          if (state.hasCheckedIn && state.hasCheckedOut)
            _statusLine("Durasi",
                _calcDuration(state.checkInTime!, state.checkOutTime!)),
        ],
      ),
    );
  }

  String _calcDuration(String start, String end) {
    try {
      final fmt = DateFormat("HH:mm");
      final s = fmt.parse(start);
      final e = fmt.parse(end);

      Duration diff = e.difference(s);
      if (diff.isNegative) diff = e.add(const Duration(days: 1)).difference(s);

      final h = diff.inHours.toString().padLeft(2, "0");
      final m = (diff.inMinutes % 60).toString().padLeft(2, "0");
      return "$h:$m Jam";
    } catch (_) {
      return "-";
    }
  }

  Widget _statusLine(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColor.subtitleText)),
          Text(
            value ?? "-",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(HomeState state) {
    if (state.loadingHistory) return _shimmerHistory();

    if (state.history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        decoration: _cardDecoration(),
        child: Column(
          children: const [
            Icon(Icons.calendar_today, size: 60, color: AppColor.subtitleText),
            SizedBox(height: 10),
            Text(
              "Belum ada absen hari ini",
              style: TextStyle(
                color: AppColor.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: state.history.map((e) => _historyItem(e)).toList(),
    );
  }

  Widget _historyItem(AttendanceData item) {
    String status = item.status ?? "-";
    Color color = AppColor.info;

    if (status == "masuk") color = AppColor.success;
    if (status == "keluar") color = AppColor.primary;
    if (status == "izin") color = AppColor.warning;
    if (status != "masuk" && status != "keluar" && status != "izin") {
      color = AppColor.danger;
    }

    final date = DateTime.tryParse(item.attendanceDate ?? "");
    final prettyDate = (date != null)
        ? DateFormat("EEE, dd MMM yyyy", "id_ID").format(date)
        : "-";

    final timeText = status == "izin"
        ? (item.alasanIzin ?? "Izin")
        : "${item.checkInTime ?? "-"} • ${item.checkOutTime ?? "-"}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.15),
            child: Icon(Icons.access_time, color: color),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prettyDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            timeText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerHistory() {
    return Column(
      children: List.generate(4, (i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: AppColor.border,
                highlightColor: AppColor.primaryLight,
                child: const CircleAvatar(radius: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: AppColor.border,
                      highlightColor: AppColor.primaryLight,
                      child: Container(height: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: AppColor.border,
                      highlightColor: AppColor.primaryLight,
                      child: Container(
                        height: 12,
                        width: 120,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColor.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColor.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
