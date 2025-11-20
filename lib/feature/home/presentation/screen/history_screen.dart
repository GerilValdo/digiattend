import 'package:digiattend/core/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:digiattend/feature/authentication/data/models/attendance_model.dart';
import 'package:digiattend/feature/authentication/data/service/attendance_api.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool loading = true;
  List<AttendanceData> history = [];

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  AttendanceData? selectedDayData;

  final monthsID = const [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agu",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future loadHistory() async {
    setState(() => loading = true);

    final list = await AttendanceAPI.getHistory();
    setState(() {
      history = list;
      loading = false;
    });
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "masuk":
        return Colors.green;
      case "izin":
        return Colors.orange;
      case "alfa":
        return Colors.red;
      case "keluar":
        return Colors.blue;
      default:
        return Colors.grey.shade400;
    }
  }

  AttendanceData? getDataForDate(DateTime date) {
    final s = DateFormat("yyyy-MM-dd").format(date);
    try {
      return history.firstWhere((e) => e.attendanceDate == s);
    } catch (_) {
      return null;
    }
  }

  List<Widget> buildCalendar() {
    List<Widget> cells = [];

    final firstDay = DateTime(selectedYear, selectedMonth, 1);
    final lastDay = DateTime(selectedYear, selectedMonth + 1, 0);

    final weekdayOffset = firstDay.weekday == 7 ? 0 : firstDay.weekday;

    // Tambahkan sel kosong untuk offset
    for (int i = 0; i < weekdayOffset; i++) {
      cells.add(Container());
    }

    // Generate tanggal
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(selectedYear, selectedMonth, day);
      final data = getDataForDate(date);

      final isSelected =
          selectedDayData?.attendanceDate ==
          DateFormat("yyyy-MM-dd").format(date);

      final Color bgColor = data == null
          ? Colors.white
          : getStatusColor(data.status).withOpacity(isSelected ? 0.85 : 0.60);

      final Color textColor = data == null ? AppColor.textColor : Colors.white;

      cells.add(
        GestureDetector(
          onTap: () {
            setState(() => selectedDayData = data);
          },
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.black87 : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                "$day",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: AppColor.background,
        body: Center(child: CircularProgressIndicator(color: AppColor.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Attendance Calendar",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),

              const SizedBox(height: 20),

              // MONTH + YEAR PICKER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<int>(
                    value: selectedMonth,
                    items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(monthsID[i]),
                      ),
                    ),
                    onChanged: (v) => setState(() => selectedMonth = v!),
                  ),
                  DropdownButton<int>(
                    value: selectedYear,
                    items: List.generate(
                      5,
                      (i) => DropdownMenuItem(
                        value: DateTime.now().year - 2 + i,
                        child: Text("${DateTime.now().year - 2 + i}"),
                      ),
                    ),
                    onChanged: (v) => setState(() => selectedYear = v!),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // DAYS HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Min"),
                  Text("Sen"),
                  Text("Sel"),
                  Text("Rab"),
                  Text("Kam"),
                  Text("Jum"),
                  Text("Sab"),
                ],
              ),

              const SizedBox(height: 10),

              // CALENDAR GRID
              Expanded(
                child: GridView.count(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  children: buildCalendar(),
                ),
              ),

              const SizedBox(height: 10),

              // DETAIL SECTION
              if (selectedDayData != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedDayData!.attendanceDate!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColor.textColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (selectedDayData!.status == "izin")
                        Text(
                          "Status : Izin\nAlasan : ${selectedDayData!.alasanIzin}",
                          style: const TextStyle(color: AppColor.textColor),
                        )
                      else
                        Text(
                          "Check-in  : ${selectedDayData!.checkInTime ?? '-'}\n"
                          "Check-out : ${selectedDayData!.checkOutTime ?? '-'}\n"
                          "Status    : ${selectedDayData!.status ?? '-'}",
                          style: const TextStyle(color: AppColor.textColor),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 18),

              // ----------------------------------------------------
              // CREATED BY DIGIATTEND
              // ----------------------------------------------------
              Center(
                child: Opacity(
                  opacity: 0.7,
                  child: Text(
                    "Created by Geril Valdo",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.subtitleText,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
