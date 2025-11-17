import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vw = MediaQuery.of(context).size.width;
    final vh = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: vw * 0.06, vertical: vh * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with avatar
          Row(
            children: [
              CircleAvatar(
                radius: vw * 0.07,
                backgroundColor: Colors.blue,
                child: const Text(
                  'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: vw * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Mamat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '12345678 • Junior UX Designer',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.qr_code, color: Colors.white),
              ),
            ],
          ),

          SizedBox(height: vh * 0.03),

          // Attendance card
          Container(
            width: double.infinity,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Live Attendance',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: vh * 0.01),
                Text(
                  '09:41 AM',
                  style: TextStyle(
                    fontSize: vw * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: vh * 0.01),
                const Text(
                  'Mon, 18 April 2023',
                  style: TextStyle(color: Colors.black54),
                ),
                Divider(color: Colors.black.withValues(alpha: 0.2)),
                const SizedBox(height: 14),
                Text('Office Hours', style: TextStyle(color: Colors.black54)),
                SizedBox(height: 6),
                Text(
                  '08:00 AM - 05:00 PM',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text('Check in'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text('Check out'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: vh * 0.03),

          // Attendance history header
          const Text(
            'Attendance History',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: vh * 0.015),

          // Attendance history list
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: vh * 0.01),
            child: Column(
              children: List.generate(6, (i) {
                final days = [
                  'Mon, 18 April 2023',
                  'Fri, 15 April 2023',
                  'Thu, 14 April 2023',
                  'Wed, 13 April 2023',
                  'Tue, 12 April 2023',
                  'Mon, 11 April 2023',
                ];
                final times = [
                  '08:00 - 05:00',
                  '08:52 - 05:00',
                  '07:45 - 05:00',
                  '07:55 - 05:00',
                  '07:48 - 05:00',
                  '07:52 - 05:00',
                ];
                return ListTile(
                  title: Text(days[i]),
                  trailing: Text(
                    times[i],
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
