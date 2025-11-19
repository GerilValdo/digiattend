import 'package:digiattend/core/constants/app_color.dart';
import 'package:digiattend/feature/authentication/data/service/attendance_api.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class MapScreen extends StatefulWidget {
  final bool isCheckIn;
  const MapScreen({super.key, required this.isCheckIn});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  Position? position;
  bool loading = true;
  String? readableAddress;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _initGPS();
  }

  // ========================= REVERSE GEOCODING =========================
  Future<String> getReadableAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return "Lokasi tidak diketahui";
      final p = placemarks.first;
      return "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}";
    } catch (_) {
      return "Alamat tidak ditemukan";
    }
  }

  // ========================= GPS =========================
  Future<void> _initGPS() async {
    setState(() {
      loading = true;
      errorMsg = null;
      readableAddress = null;
    });

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() {
          loading = false;
          errorMsg = "GPS tidak aktif. Aktifkan lokasi terlebih dahulu.";
        });
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() {
          loading = false;
          errorMsg =
              "Izin lokasi ditolak permanen. Aktifkan melalui pengaturan.";
        });
        return;
      }
      if (perm == LocationPermission.denied) {
        setState(() {
          loading = false;
          errorMsg = "Aplikasi membutuhkan izin lokasi.";
        });
        return;
      }

      final current = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final addr = await getReadableAddress(
        current.latitude,
        current.longitude,
      );

      setState(() {
        position = current;
        readableAddress = addr;
        loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openSheet();
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMsg = "Gagal mengambil GPS: $e";
      });
    }
  }

  // ========================= BOTTOM SHEET =========================
  void _openSheet() {
    if (position == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColor.border,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                widget.isCheckIn
                    ? "Konfirmasi Check-In"
                    : "Konfirmasi Check-Out",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: AppColor.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Lokasi Anda:\n$readableAddress",
                      style: TextStyle(color: AppColor.textColor, height: 1.4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _submitAttendance(widget.isCheckIn),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.isCheckIn ? "Simpan Check-in" : "Simpan Check-out",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ========================= SUBMIT TO API =========================
  Future<void> _submitAttendance(bool isCheckIn) async {
    Navigator.pop(context); // close bottom sheet

    try {
      final lat = position!.latitude;
      final lng = position!.longitude;

      final date = DateFormat("yyyy-MM-dd").format(DateTime.now());
      final time = DateFormat("HH:mm").format(DateTime.now());

      if (isCheckIn) {
        await AttendanceAPI.checkIn(
          attendanceDate: date,
          checkIn: time,
          lat: lat,
          lng: lng,
          address: readableAddress ?? "-",
          status: "masuk",
        );
      } else {
        await AttendanceAPI.checkOut(
          attendanceDate: date,
          checkOut: time,
          lat: lat,
          lng: lng,
          address: readableAddress ?? "-",
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.success,
          content: Text(
            isCheckIn ? "Check-in berhasil!" : "Check-out berhasil!",
          ),
        ),
      );

      Navigator.pop(context, true); // return to HomeScreen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.error,
          content: Text("Gagal menyimpan absen: $e"),
        ),
      );
    }
  }

  // ========================= BUILD =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Stack(
        children: [
          if (loading)
            const Center(
              child: CircularProgressIndicator(color: AppColor.primary),
            ),

          if (!loading && errorMsg != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 70, color: AppColor.error),
                  const SizedBox(height: 10),
                  Text(errorMsg!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _initGPS,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                    ),
                    child: const Text(
                      "Coba Lagi",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

          if (!loading && errorMsg == null && position != null)
            GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                target: LatLng(position!.latitude, position!.longitude),
                zoom: 16,
              ),
              onMapCreated: (c) => _controller = c,
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FloatingActionButton(
                mini: true,
                backgroundColor: AppColor.card,
                elevation: 1,
                onPressed: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back, color: AppColor.textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
