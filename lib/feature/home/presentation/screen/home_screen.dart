import 'dart:async';
import 'package:digiattend/feature/authentication/data/models/attendance_model.dart';
import 'package:digiattend/feature/authentication/data/service/attendance_api.dart';
import 'package:flutter/material.dart';
import 'package:digiattend/core/service/auth_local_storage.dart';
import 'package:digiattend/feature/authentication/data/models/user_model.dart';
import 'package:digiattend/feature/authentication/data/models/training_model.dart';
import 'package:digiattend/feature/authentication/data/service/training_api.dart';
import 'package:intl/intl.dart';
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

  bool isCheckingIn = false;
  bool isCheckingOut = false;

  bool hasCheckedInToday = false;
  bool hasCheckedOutToday = false;
  String? serverCheckInTime;
  String? serverCheckOutTime;

  bool isLoadingHistory = true;
  List<AttendanceData> attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    loadUserAndTraining();
    loadAttendanceHistory();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // 🔥 Generate warna avatar dari nama
  Color generateAvatarColor(String name) {
    final code = name.hashCode;
    return Colors.primaries[code % Colors.primaries.length];
  }

  // 🔥 Ambil inisial (contoh: “User KC” → “UK”)
  String getInitials(String name) {
    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // 🔥 Deteksi status absen hari ini
  void detectTodayStatus() {
    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

    final todayRecord = attendanceHistory.firstWhere(
      (e) => e.attendanceDate == today,
      orElse: () => AttendanceData(attendanceDate: ""),
    );

    if (todayRecord.attendanceDate == "") {
      hasCheckedInToday = false;
      hasCheckedOutToday = false;
      serverCheckInTime = null;
      serverCheckOutTime = null;
      return;
    }

    hasCheckedInToday = todayRecord.checkInTime != null;
    hasCheckedOutToday = todayRecord.checkOutTime != null;

    serverCheckInTime = todayRecord.checkInTime;
    serverCheckOutTime = todayRecord.checkOutTime;
  }

  // 🔥 CHECK-IN
  Future<void> doCheckIn() async {
    if (hasCheckedInToday) {
      showSnack("Anda sudah check-in hari ini.", Colors.orange);
      return;
    }

    setState(() => isCheckingIn = true);

    try {
      final date = DateFormat("yyyy-MM-dd").format(DateTime.now());
      final time = DateFormat("HH:mm").format(DateTime.now());

      final res = await AttendanceAPI.checkIn(
        attendanceDate: date,
        checkIn: time,
        lat: -6.2,
        lng: 106.8,
        address: "Jakarta",
        status: "masuk",
      );

      await Future.delayed(const Duration(milliseconds: 600));
      await loadAttendanceHistory();

      showSnack(res.message ?? "Check-in berhasil!", Colors.green);
    } catch (e) {
      showSnack(e.toString(), Colors.red);
    }

    setState(() => isCheckingIn = false);
  }

  // 🔥 CHECK-OUT
  Future<void> doCheckOut() async {
    if (!hasCheckedInToday) {
      showSnack("Anda belum check-in hari ini!", Colors.red);
      return;
    }

    if (hasCheckedOutToday) {
      showSnack("Anda sudah check-out hari ini.", Colors.orange);
      return;
    }

    setState(() => isCheckingOut = true);

    try {
      final date = DateFormat("yyyy-MM-dd").format(DateTime.now());
      final time = DateFormat("HH:mm").format(DateTime.now());

      final res = await AttendanceAPI.checkOut(
        attendanceDate: date,
        checkOut: time,
        lat: -6.2,
        lng: 106.8,
        address: "Jakarta",
      );

      await Future.delayed(const Duration(milliseconds: 600));
      await loadAttendanceHistory();

      showSnack(res.message ?? "Check-out berhasil!", Colors.green);
    } catch (e) {
      showSnack(e.toString(), Colors.red);
    }

    setState(() => isCheckingOut = false);
  }

  // 🔥 Load History
  Future<void> loadAttendanceHistory() async {
    setState(() => isLoadingHistory = true);

    try {
      final list = await AttendanceAPI.getHistory();
      attendanceHistory = list;

      detectTodayStatus();
    } catch (e) {
      showSnack(e.toString(), Colors.red);
    }

    setState(() => isLoadingHistory = false);
  }

  // 🔥 Load User + Training
  Future<void> loadUserAndTraining() async {
    final json = await AuthLocalStorage.getUser();
    if (json == null) return;

    final loadedUser = UserModel.fromJson(json);
    final trainings = await TrainingAPI.getTrainingList();

    final matched = trainings.firstWhere(
      (t) => t.id == loadedUser.trainingId,
      orElse: () => TrainingData(title: "Unknown Training"),
    );

    setState(() {
      user = loadedUser;
      trainingTitle = matched.title ?? "";
    });
  }

  // 🔥 Shimmer Loading
  Widget shimmerHistorySkeleton() {
    return Column(
      children: List.generate(4, (i) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: const CircleAvatar(radius: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(height: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
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

  // ========================= UI =========================

  @override
  Widget build(BuildContext context) {
    final vw = MediaQuery.of(context).size.width;
    final vh = MediaQuery.of(context).size.height;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF2E3349),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // FIX FOTO PROFIL NULL / EMPTY
    bool hasValidPhoto =
        user!.profilePhoto != null &&
        user!.profilePhoto!.trim().isNotEmpty &&
        user!.profilePhoto!.startsWith("http");

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: vw * 0.06,
          vertical: vh * 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================= HEADER =========================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: vw * 0.065,
                  backgroundColor: hasValidPhoto
                      ? Colors.grey.shade200
                      : generateAvatarColor(user!.name),
                  backgroundImage: hasValidPhoto
                      ? NetworkImage(user!.profilePhoto!)
                      : null,
                  child: hasValidPhoto
                      ? null
                      : Text(
                          getInitials(user!.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
                SizedBox(width: vw * 0.04),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Batch ${user!.batchId} • $trainingTitle",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.qr_code, color: Colors.white),
              ],
            ),

            SizedBox(height: vh * 0.03),

            // ========================= LIVE ATTENDANCE =========================
            Container(
              padding: EdgeInsets.all(vw * 0.06),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Live Attendance",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),

                  SizedBox(height: 6),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      DateFormat("HH:mm:ss").format(now),
                      key: ValueKey(now.toString()),
                      style: TextStyle(
                        fontSize: vw * 0.12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  Text(
                    DateFormat("EEE, dd MMM yyyy").format(now),
                    style: const TextStyle(color: Colors.black54),
                  ),

                  Divider(height: 26, thickness: .5),

                  const Text(
                    "Office Hours",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const Text(
                    "08:00 AM - 05:00 PM",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 16),

                  // BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (isCheckingIn || hasCheckedInToday)
                              ? null
                              : doCheckIn,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 45),
                            backgroundColor: hasCheckedInToday
                                ? Colors.grey
                                : Colors.blue,
                          ),
                          child: isCheckingIn
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : FittedBox(
                                  child: Text(
                                    hasCheckedInToday
                                        ? "Sudah Check-in ($serverCheckInTime)"
                                        : "Check in",
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              (isCheckingOut ||
                                  !hasCheckedInToday ||
                                  hasCheckedOutToday)
                              ? null
                              : doCheckOut,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 45),
                            backgroundColor: hasCheckedOutToday
                                ? Colors.grey
                                : Colors.blue,
                          ),
                          child: isCheckingOut
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : FittedBox(
                                  child: Text(
                                    hasCheckedOutToday
                                        ? "Sudah Check-out ($serverCheckOutTime)"
                                        : "Check out",
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: vh * 0.03),

            // ========================= ATTENDANCE HISTORY =========================
            const Text(
              "Attendance History",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),

            SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: isLoadingHistory
                  ? shimmerHistorySkeleton()
                  : attendanceHistory.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Belum ada absen hari ini",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: attendanceHistory.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemBuilder: (context, index) {
                        final item = attendanceHistory[index];

                        final status = item.status ?? "-";
                        final checkIn = item.checkInTime ?? "-";
                        final checkOut = item.checkOutTime ?? "-";
                        final reason = item.alasanIzin;

                        Color color;
                        IconData icon;

                        switch (status.toLowerCase()) {
                          case "masuk":
                            color = Colors.green;
                            icon = Icons.login;
                            break;
                          case "keluar":
                            color = Colors.blue;
                            icon = Icons.logout;
                            break;
                          case "izin":
                            color = Colors.orange;
                            icon = Icons.event_busy;
                            break;
                          default:
                            color = Colors.grey;
                            icon = Icons.help_outline;
                        }

                        DateTime? parsedDate;
                        if (item.attendanceDate != null) {
                          try {
                            parsedDate = DateTime.parse(item.attendanceDate!);
                          } catch (_) {}
                        }

                        final prettyDate = parsedDate != null
                            ? DateFormat("EEE, dd MMM yyyy").format(parsedDate)
                            : "-";

                        final timeText = status == "izin"
                            ? (reason ?? "Izin")
                            : "$checkIn - $checkOut";

                        return Container(
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: color.withOpacity(.15),
                                child: Icon(icon, color: color),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prettyDate,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
