import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:digiattend/core/constants/app_color.dart';
import 'package:digiattend/core/service/auth_local_storage.dart';
import 'package:digiattend/core/utils/avatar_helper.dart';

import 'package:digiattend/feature/authentication/data/models/user_model.dart';
import 'package:digiattend/feature/authentication/data/models/training_model.dart';
import 'package:digiattend/feature/authentication/data/service/auth_api.dart';
import 'package:digiattend/feature/authentication/data/service/training_api.dart';
import 'package:digiattend/feature/authentication/presentation/screen/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  String trainingTitle = "";
  bool loading = true;
  Key photoKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // =============================================================
  // LOAD USER DATA
  // =============================================================
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

  // =============================================================
  // UPDATE NAME
  // =============================================================
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
          title: const Text("Ubah Nama"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Nama baru"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) return;

                try {
                  final updated = await AuthAPI.updateProfileName(newName);

                  // WAJIB: simpan user baru
                  await AuthLocalStorage.updateUserModel(updated.toJson());

                  setState(() => user = updated);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nama berhasil diperbarui")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Gagal update: $e")));
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // =============================================================
  // UPDATE PHOTO
  // =============================================================
  Future<void> pickImage(ImageSource source) async {
    final img = await ImagePicker().pickImage(source: source);
    if (img == null) return;

    final bytes = await File(img.path).readAsBytes();
    final base64 = base64Encode(bytes);

    try {
      final updated = await AuthAPI.updateProfilePhoto(base64);

      await AuthLocalStorage.updateUserModel(updated.toJson());

      setState(() {
        user = updated;
        photoKey = UniqueKey();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Foto profil diperbarui")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal upload: $e")));
    }
  }

  void showPhotoPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Ambil dari Kamera"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Pilih dari Galeri"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.red),
                title: const Text("Batal"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // =============================================================
  // LOGOUT DIALOG (UI/UX MODERN)
  // =============================================================
  void showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout, size: 55, color: Colors.red),
                const SizedBox(height: 12),
                const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Apakah kamu yakin ingin keluar dari aplikasi?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColor.subtitleText),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColor.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: AppColor.textColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context); // tutup dialog
                          await logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Logout"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================================================
  // LOGOUT
  // =============================================================
  Future<void> logout() async {
    await AuthLocalStorage.clearUserData();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  // =============================================================
  // UI
  // =============================================================
  @override
  Widget build(BuildContext context) {
    if (loading || user == null) {
      return Scaffold(
        backgroundColor: AppColor.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final photoUrl = getFinalPhoto(user!.profilePhoto);
    final initials = user!.name.isNotEmpty ? user!.name[0].toUpperCase() : "?";

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(title: const Text("Profile"), elevation: 0),
      body: RefreshIndicator(
        onRefresh: loadUser,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // =============================================================
              // AVATAR
              // =============================================================
              GestureDetector(
                onTap: showPhotoPicker,
                child: Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: ClipOval(
                        key: photoKey,
                        child: Container(
                          width: 130,
                          height: 130,
                          color: Colors.grey.shade200,
                          child: (photoUrl != null)
                              ? Image.network(
                                  "$photoUrl?v=${DateTime.now().millisecondsSinceEpoch}",
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _avatarInitial(initials),
                                )
                              : _avatarInitial(initials),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColor.primary,
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

              const SizedBox(height: 20),

              // =============================================================
              // NAME + EDIT BUTTON
              // =============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user!.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: updateName,
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),

              Text(user!.email, style: TextStyle(color: Colors.grey.shade600)),

              const SizedBox(height: 30),

              _detail(Icons.person, "Jenis Kelamin", user!.jenisKelamin),
              _detail(Icons.group, "Batch", "Batch ${user!.batchKe}"),
              _detail(Icons.school, "Training", trainingTitle),

              const SizedBox(height: 20),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: showLogoutDialog,
                  child: const Text("Logout"),
                ),
              ),

              const SizedBox(height: 30),

              Opacity(
                opacity: 0.7,
                child: Text(
                  "Created by Geril Valdo",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.subtitleText,
                    fontWeight: FontWeight.w500,
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

  // =============================================================
  // WIDGETS
  // =============================================================
  Widget _avatarInitial(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 40,
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColor.primaryLight,
            child: Icon(icon, color: AppColor.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600)),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
