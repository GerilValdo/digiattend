import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final months = ['Juni', 'Juli', 'Agustus', 'September'];
  int selectedMonthIndex = 1;

  @override
  Widget build(BuildContext context) {
    final vw = MediaQuery.of(context).size.width;
    final vh = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: vw * 0.06, vertical: vh * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          const Text(
            'History',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          SizedBox(height: vh * 0.02),

          // month pills
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: months.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final bool sel = i == selectedMonthIndex;
                return GestureDetector(
                  onTap: () => setState(() => selectedMonthIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? Colors.white : Colors.white70,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      months[i],
                      style: TextStyle(
                        color: sel ? Colors.blue : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: vh * 0.02),

          // list of entries
          Expanded(
            child: ListView.separated(
              itemCount: 8,
              separatorBuilder: (_, __) => SizedBox(height: vh * 0.02),
              itemBuilder: (context, idx) {
                return Container(
                  padding: EdgeInsets.all(vw * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monday',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '13-Jun-25',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'Check In',
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '07:50 - 17:50',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
