import 'package:digiattend/core/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:digiattend/feature/authentication/data/models/attendance_model.dart';
import 'package:digiattend/feature/authentication/data/service/attendance_api.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool loading = true;
  bool refreshing = false;
  String? error;

  List<AttendanceData> allHistory = [];
  List<AttendanceData> filtered = [];

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

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

  List<int> yearOptions = [];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await initializeDateFormatting('id_ID', null);
    await loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final list = await AttendanceAPI.getHistory();
      allHistory = list;

      // ---- BUILT-IN UX: Always show 3-year range ----
      final currentYear = DateTime.now().year;
      final defaultYears = {currentYear - 1, currentYear, currentYear + 1};

      // ---- Add years from API if exist ----
      final apiYears = list
          .where(
            (e) => e.attendanceDate != null && e.attendanceDate!.isNotEmpty,
          )
          .map((e) => DateTime.parse(e.attendanceDate!).year)
          .toSet();

      // ---- Combine & Sort ----
      final result = {...defaultYears, ...apiYears}.toList();
      result.sort();

      yearOptions = result;

      // Auto correct selectedYear if outside range
      if (!yearOptions.contains(selectedYear)) {
        selectedYear = currentYear;
      }

      applyFilter();
    } catch (e) {
      error = e.toString();
      filtered = [];
    }

    setState(() => loading = false);
  }

  void applyFilter() {
    filtered = allHistory.where((item) {
      if (item.attendanceDate == null || item.attendanceDate!.isEmpty)
        return false;

      final dt = DateTime.parse(item.attendanceDate!);
      return dt.month == selectedMonth && dt.year == selectedYear;
    }).toList();

    filtered.sort((a, b) {
      final da = DateTime.parse(a.attendanceDate!);
      final db = DateTime.parse(b.attendanceDate!);
      return db.compareTo(da);
    });
  }

  Future<void> _onRefresh() async {
    setState(() => refreshing = true);
    await loadHistory();
    setState(() => refreshing = false);
  }

  String dayName(DateTime d) {
    try {
      return DateFormat.EEEE('id_ID').format(d);
    } catch (_) {
      return DateFormat.EEEE().format(d);
    }
  }

  String prettyDate(DateTime d) {
    try {
      return DateFormat("dd MMM yyyy", 'id_ID').format(d);
    } catch (_) {
      return DateFormat("dd MMM yyyy").format(d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vw = MediaQuery.of(context).size.width;
    final vh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: vw * 0.06,
            vertical: vh * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              Text(
                "Attendance History",
                style: TextStyle(
                  color: AppColor.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 14),

              // YEAR FILTER ===============================
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: yearOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final y = yearOptions[i];
                    final sel = y == selectedYear;

                    return ChoiceChip(
                      label: Text(
                        "$y",
                        style: TextStyle(
                          color: sel ? Colors.white : AppColor.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: sel,
                      selectedColor: AppColor.primary,
                      backgroundColor: AppColor.primaryLight,
                      onSelected: (_) {
                        setState(() {
                          selectedYear = y;
                          applyFilter();
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // MONTH FILTER ===============================
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: monthsID.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final m = i + 1;
                    final sel = m == selectedMonth;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMonth = m;
                          applyFilter();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: sel ? AppColor.primary : AppColor.primaryLight,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          monthsID[i],
                          style: TextStyle(
                            color: sel ? Colors.white : AppColor.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // CONTENT LIST =============================================
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: Colors.white,
                  backgroundColor: AppColor.primary,
                  child: buildContent(vh),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContent(double vh) {
    if (loading) {
      return ListView(
        children: const [
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator(color: AppColor.primary)),
        ],
      );
    }

    if (filtered.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: vh * 0.12),
          Column(
            children: [
              Icon(
                Icons.calendar_today,
                size: 70,
                color: AppColor.subtitleText,
              ),
              const SizedBox(height: 12),
              Text(
                "Tidak ada data untuk bulan ini",
                style: TextStyle(
                  color: AppColor.subtitleText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // LIST
    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => SizedBox(height: vh * 0.018),
      itemBuilder: (_, i) {
        final item = filtered[i];
        final dt = DateTime.parse(item.attendanceDate!);

        final status = (item.status ?? "").toLowerCase();

        Color color;
        IconData icon;

        switch (status) {
          case "masuk":
            color = AppColor.success;
            icon = Icons.login;
            break;
          case "keluar":
            color = AppColor.info;
            icon = Icons.logout;
            break;
          case "izin":
            color = AppColor.warning;
            icon = Icons.event_busy;
            break;
          default:
            color = AppColor.subtitleText;
            icon = Icons.help_outline;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.border),
          ),
          child: Row(
            children: [
              // Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),

              const SizedBox(width: 14),

              // Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayName(dt),
                      style: TextStyle(
                        color: AppColor.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prettyDate(dt),
                      style: TextStyle(color: AppColor.subtitleText),
                    ),
                  ],
                ),
              ),

              // Status + time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status == "izin"
                        ? (item.alasanIzin ?? "Izin")
                        : "${item.checkInTime ?? '-'} • ${item.checkOutTime ?? '-'}",
                    style: TextStyle(
                      color: AppColor.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
