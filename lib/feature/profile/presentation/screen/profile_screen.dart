import 'dart:io';
import 'package:digiattend/core/constants/app_color.dart';
import 'package:digiattend/core/constants/endpoint.dart';
import 'package:digiattend/core/service/auth_local_storage.dart';
import 'package:digiattend/feature/authentication/data/models/user_model.dart';
import 'package:digiattend/feature/authentication/data/models/training_model.dart';
import 'package:digiattend/feature/authentication/data/service/auth_api.dart';
import 'package:digiattend/feature/authentication/data/service/training_api.dart';
import 'package:digiattend/feature/authentication/presentation/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  String trainingTitle = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final json = await AuthLocalStorage.getUser();
    if (json == null) return;

    final model = UserModel.fromJson(json);
    final trainings = await TrainingAPI.getTrainingList();

    final matched = trainings.firstWhere(
      (t) => t.id == model.trainingId,
      orElse: () => TrainingData(title: "Unknown"),
    );

    setState(() {
      user = model;
      trainingTitle = matched.title ?? "-";
      loading = false;
    });
  }

  // ========================= UPDATE NAME =========================
  Future<void> updateName() async {
    final controller = TextEditingController(text: user?.name);

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColor.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Ubah Nama", style: TextStyle(color: AppColor.textColor)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "Nama baru",
              labelStyle: TextStyle(color: AppColor.subtitleText),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.primary),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.border),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "Batal",
                style: TextStyle(color: AppColor.subtitleText),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) return;

                try {
                  final updated = await AuthAPI.updateProfileName(newName);
                  await AuthLocalStorage.updateUserModel(updated.toJson());
                  setState(() => user = updated);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColor.success,
                      content: const Text("Nama diperbarui"),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColor.error,
                      content: Text("Gagal update: $e"),
                    ),
                  );
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // ========================= UPDATE PHOTO =========================
  Future<void> updatePhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    final file = File(img.path);

    try {
      final updated = await AuthAPI.updateProfilePhoto(file);
      await AuthLocalStorage.updateUserModel(updated.toJson());
      setState(() => user = updated);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.success,
          content: const Text("Foto profil diperbarui"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.error,
          content: Text("Gagal upload foto: $e"),
        ),
      );
    }
  }

  // ========================= LOGOUT DIALOG =========================
  Future<void> confirmLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColor.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Konfirmasi Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          content: Text(
            "Apakah kamu yakin ingin keluar dari akun ini?",
            style: TextStyle(color: AppColor.subtitleText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: TextStyle(color: AppColor.subtitleText),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthLocalStorage.clearUserData();
                if (!mounted) return;

                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColor.danger),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ========================= BUILD UI =========================
  @override
  Widget build(BuildContext context) {
    if (loading || user == null) {
      return const Scaffold(
        backgroundColor: AppColor.background,
        body: Center(child: CircularProgressIndicator(color: AppColor.primary)),
      );
    }

    final photoUrl =
        (user!.profilePhoto != null && user!.profilePhoto!.trim().isNotEmpty)
        ? "${Endpoint.baseUrl}/public/${user!.profilePhoto}"
        : null;

    final initials = user!.name.trim().isNotEmpty
        ? user!.name.trim()[0].toUpperCase()
        : "?";

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
            color: AppColor.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: AppColor.textColor),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ================= AVATAR =================
            GestureDetector(
              onTap: updatePhoto,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: AppColor.primaryLight,
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null
                        ? Text(
                            initials,
                            style: TextStyle(
                              fontSize: 40,
                              color: AppColor.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),

                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ================= NAME =================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user!.name,
                  style: TextStyle(
                    color: AppColor.textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: updateName,
                  child: Icon(Icons.edit, color: AppColor.primary),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Text(user!.email, style: TextStyle(color: AppColor.subtitleText)),

            const SizedBox(height: 30),

            // ================= DETAIL =================
            detailItem(Icons.person, "Jenis Kelamin", user!.jenisKelamin),
            detailItem(Icons.group, "Batch", "Batch ${user!.batchId}"),
            detailItem(Icons.school, "Training", trainingTitle),

            const SizedBox(height: 40),

            // ================= LOGOUT BUTTON =================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: confirmLogout,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColor.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColor.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColor.primaryLight,
            child: Icon(icon, color: AppColor.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: AppColor.subtitleText, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: AppColor.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
