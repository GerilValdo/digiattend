import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;

  final CameraPosition _initial = const CameraPosition(
    target: LatLng(-6.200000, 106.816666),
    zoom: 14,
  );

  final Marker _userMarker = const Marker(
    markerId: MarkerId('me'),
    position: LatLng(-6.200000, 106.816666),
    infoWindow: InfoWindow(title: 'You are here'),
  );

  @override
  void initState() {
    super.initState();
    // Buka bottom sheet otomatis setelah screen muncul
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openBottomSheet();
    });
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final vh = MediaQuery.of(context).size.height;

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                "Check in",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              // Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.location_on, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Your Location\nJl. Citra Indah Utama No.18, Bogor, Jawa Barat",
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Status
              const Text(
                "Status: Belum Check In",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Checked In'),
                        content: const Text(
                          'You have successfully checked in.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text("Check In", style: TextStyle(fontSize: 16)),
                ),
              ),

              SizedBox(height: vh * 0.03),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _initial,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          markers: {_userMarker},
          onMapCreated: (c) => _controller = c,
        ),

        // Top UI
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _roundButton(Icons.arrow_back, () => Navigator.pop(context)),
                _roundButton(Icons.my_location, () {
                  _controller.animateCamera(
                    CameraUpdate.newCameraPosition(_initial),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white70,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}
