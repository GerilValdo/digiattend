import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:digiattend/core/constants/app_color.dart';
import 'package:digiattend/core/service/auth_local_storage.dart';
import 'package:digiattend/core/utils/avatar_helper.dart';

import 'package:digiattend/feature/authentication/data/models/user_model.dart';
import 'package:digiattend/feature/authentication/data/models/attendance_model.dart';
import 'package:digiattend/feature/authentication/data/models/training_model.dart';
import 'package:digiattend/feature/authentication/data/service/attendance_api.dart';
import 'package:digiattend/feature/authentication/data/service/training_api.dart';

import 'package:digiattend/feature/home/presentation/screen/map_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? user;
  String trainingTitle = "";

  DateTime now = DateTime.now();
  Timer? timer;

  bool hasCheckedIn = false;
  bool hasCheckedOut = false;
  String? checkInTime;
  String? checkOutTime;

  bool loadingHistory = true;
  List<AttendanceData> history = [];

  @override
  void initState() {
    super.initState();
    loadUser();
    loadAttendance();

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

  void showSnack(String text, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }

  String _calcDuration(String? start, String? end) {
    if (start == null || end == null) return "-";

    try {
      final fmt = DateFormat("HH:mm");
      final s = fmt.parse(start.trim());
      final e = fmt.parse(end.trim());

      Duration diff = e.difference(s);
      if (diff.isNegative) {
        diff = e.add(const Duration(days: 1)).difference(s);
      }

      final h = diff.inHours.toString().padLeft(2, "0");
      final m = (diff.inMinutes % 60).toString().padLeft(2, "0");
      return "$h:$m Jam";
    } catch (_) {
      return "-";
    }
  }

  Future<void> loadUser() async {
    final json = await AuthLocalStorage.getUser();
    if (json == null) return;

    final model = UserModel.fromJson(json);
    final trainings = await TrainingAPI.getTrainingList();

    final matched = trainings.firstWhere(
      (e) => e.id == model.trainingId,
      orElse: () => TrainingData(title: "Unknown"),
    );

    setState(() {
      user = model;
      trainingTitle = matched.title ?? "-";
    });
  }

  Future<void> loadAttendance() async {
    loadingHistory = true;
    setState(() {});

    try {
      final list = await AttendanceAPI.getHistory();
      history = list;

      final todayStr = DateFormat("yyyy-MM-dd").format(DateTime.now());
      final today = history.firstWhere(
        (x) => x.attendanceDate == todayStr,
        orElse: () => AttendanceData(attendanceDate: ""),
      );

      if (today.attendanceDate != "") {
        hasCheckedIn = today.checkInTime != null;
        hasCheckedOut = today.checkOutTime != null;
        checkInTime = today.checkInTime;
        checkOutTime = today.checkOutTime;
      }
    } catch (e) {
      showSnack(e.toString(), AppColor.error);
    }

    loadingHistory = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColor.background,
        body: Center(child: CircularProgressIndicator(color: AppColor.primary)),
      );
    }

    final photoUrl = getFinalPhoto(user!.profilePhoto);

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          user!.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryDark,
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
                        user!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColor.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Batch ${user!.batchKe} • $trainingTitle",
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
            _buildLiveAttendance(),

            const SizedBox(height: 24),
            const Text(
              "Absence Statistics",
              style: TextStyle(
                color: AppColor.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatistics(),

            const SizedBox(height: 24),
            _buildTodayStatus(),

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
            _buildHistory(),

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
            // ------------------------------------------------------------
          ],
        ),
      ),
    );
  }

  Widget _buildLiveAttendance() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
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
      ),
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
              Expanded(
                child: ElevatedButton(
                  onPressed: hasCheckedIn
                      ? null
                      : () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MapScreen(isCheckIn: true),
                            ),
                          );
                          if (res == true) loadAttendance();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasCheckedIn
                        ? AppColor.border
                        : AppColor.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Check In"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (!hasCheckedIn || hasCheckedOut)
                      ? null
                      : () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MapScreen(isCheckIn: false),
                            ),
                          );
                          if (res == true) loadAttendance();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasCheckedOut
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

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statBox(
            "Hadir",
            history.where((e) => e.status == "masuk").length,
            AppColor.success,
          ),
          _statBox(
            "Telat",
            history.where((e) {
              if (e.checkInTime == null) return false;
              final t = DateFormat("HH:mm").parse(e.checkInTime!);
              return t.isAfter(DateFormat("HH:mm").parse("08:00"));
            }).length,
            AppColor.warning,
          ),
          _statBox(
            "Izin",
            history.where((e) => e.status == "izin").length,
            AppColor.info,
          ),
          _statBox(
            "Alfa",
            history
                .where(
                  (e) =>
                      e.status != "masuk" &&
                      e.status != "keluar" &&
                      e.status != "izin",
                )
                .length,
            AppColor.danger,
          ),
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
            count.toString(),
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

  Widget _buildTodayStatus() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasCheckedIn
                ? hasCheckedOut
                      ? "Sudah Check-out"
                      : "Sudah Check-in"
                : "Belum Absen",
            style: TextStyle(
              color: hasCheckedIn ? AppColor.success : AppColor.error,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          _statusLine("Check-in", checkInTime),
          _statusLine("Check-out", checkOutTime),

          if (hasCheckedIn && hasCheckedOut)
            _statusLine("Durasi", _calcDuration(checkInTime!, checkOutTime!)),
        ],
      ),
    );
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

  Widget _buildHistory() {
    if (loadingHistory) return _shimmerHistory();

    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.border),
        ),
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

    return Column(children: history.map((e) => _historyItem(e)).toList());
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
    final pretty = date != null
        ? DateFormat("EEE, dd MMM yyyy", "id_ID").format(date)
        : "-";

    final timeText = status == "izin"
        ? (item.alasanIzin ?? "Izin")
        : "${item.checkInTime ?? "-"} • ${item.checkOutTime ?? "-"}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
                  pretty,
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
          decoration: BoxDecoration(
            color: AppColor.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColor.border),
          ),
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
}
