import 'dart:convert';
import 'dart:io';

import 'package:digiattend/feature/authentication/data/models/batch_model.dart';
import 'package:digiattend/feature/authentication/data/models/training_model.dart';
import 'package:digiattend/feature/authentication/data/service/auth_api.dart';
import 'package:digiattend/feature/authentication/data/service/batch_api.dart';
import 'package:digiattend/feature/authentication/data/service/training_api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final confirmPassC = TextEditingController();

  // Dropdown values (note types)
  String? selectedGender;
  BatchData? selectedBatch;
  TrainingData? selectedTraining;

  // Data list (note types)
  List<BatchData> batchList = [];
  List<TrainingData> trainingList = [];

  // Base64 photo
  String base64Photo = "";

  bool obscure = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadDropdownData();
  }

  Future loadDropdownData() async {
    try {
      final batches =
          await BatchAPI.getBatchList(); // now returns List<BatchData>
      final trainings =
          await TrainingAPI.getTrainingList(); // returns List<TrainingData>

      setState(() {
        batchList = batches;
        trainingList = trainings;
      });
    } catch (e) {
      // show friendly error (optional)
      debugPrint("Error load dropdown: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal ambil data: $e")));
    }
  }

  // IMAGE PICKER
  Future pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;

    final bytes = await File(img.path).readAsBytes();

    setState(() {
      base64Photo = "data:image/png;base64,${base64Encode(bytes)}";
    });
  }

  // REGISTER
  Future doRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedGender == null ||
        selectedBatch == null ||
        selectedTraining == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua pilihan dropdown")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await AuthAPI.registerUser(
        name: nameC.text.trim(),
        email: emailC.text.trim(),
        password: passwordC.text.trim(),
        jenisKelamin: selectedGender!,
        profilePhoto: base64Photo,
        batchId: selectedBatch!.id!, // BatchData.id
        trainingId: selectedTraining!.id!, // TrainingData.id
      );

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Registrasi berhasil")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3349),
      body: Stack(
        children: [
          // yellow background
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.45,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE7ED00),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(70),
                  topRight: Radius.circular(70),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Welcome",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Register your account",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildField("Nama", nameC),
                        const SizedBox(height: 14),
                        _buildField("Email", emailC, validator: emailValidator),
                        const SizedBox(height: 14),
                        _buildPasswordField(),
                        const SizedBox(height: 14),
                        _buildConfirmPasswordField(),
                        const SizedBox(height: 14),
                        _buildGenderDropdown(),
                        const SizedBox(height: 14),
                        _buildBatchDropdown(),
                        const SizedBox(height: 14),
                        _buildTrainingDropdown(),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: pickImage,
                              child: const Text("Upload Foto"),
                            ),
                            const SizedBox(width: 12),
                            base64Photo.isEmpty
                                ? const Text("Belum ada foto")
                                : const Icon(Icons.check, color: Colors.green),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : doRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A74FF),
                              foregroundColor: Colors.white,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text("Register"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FIELD HELPERS (sama seperti sebelumnya)
  Widget _buildField(
    String label,
    TextEditingController c, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          validator:
              validator ??
              (v) =>
                  v == null || v.isEmpty ? "$label tidak boleh kosong" : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE5E5E5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Password"),
        const SizedBox(height: 6),
        TextFormField(
          controller: passwordC,
          obscureText: obscure,
          validator: passwordValidator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE5E5E5),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => obscure = !obscure),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Confirm Password"),
        const SizedBox(height: 6),
        TextFormField(
          controller: confirmPassC,
          obscureText: obscure,
          validator: (v) {
            if (v == null || v.isEmpty) return "Confirm password wajib diisi";
            if (v != passwordC.text) return "Password tidak sama!";
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE5E5E5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFE5E5E5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      hint: const Text("Pilih Jenis Kelamin"),
      items: const [
        DropdownMenuItem(value: "L", child: Text("Laki-Laki")),
        DropdownMenuItem(value: "P", child: Text("Perempuan")),
      ],
      initialValue: selectedGender,
      onChanged: (v) => setState(() => selectedGender = v),
      validator: (v) => v == null ? "Pilih gender" : null,
    );
  }

  Widget _buildBatchDropdown() {
    return DropdownButtonFormField<BatchData>(
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFE5E5E5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      hint: const Text("Pilih Batch"),
      initialValue: selectedBatch,
      items: batchList
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text("Batch ${e.batchKe ?? '-'}"),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => selectedBatch = v),
      validator: (v) => v == null ? "Pilih batch" : null,
    );
  }

  Widget _buildTrainingDropdown() {
    return DropdownButtonFormField<TrainingData>(
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFE5E5E5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      hint: const Text("Pilih Training"),
      initialValue: selectedTraining,
      items: trainingList
          .map((e) => DropdownMenuItem(value: e, child: Text(e.title ?? '-')))
          .toList(),
      onChanged: (v) => setState(() => selectedTraining = v),
      validator: (v) => v == null ? "Pilih training" : null,
    );
  }

  // VALIDATORS
  String? emailValidator(String? v) {
    if (v == null || v.isEmpty) return "Email wajib diisi";
    if (!v.contains("@")) return "Format email tidak valid";
    return null;
  }

  String? passwordValidator(String? v) {
    if (v == null || v.isEmpty) return "Password wajib diisi";
    if (v.length < 6) return "Minimal 6 karakter";
    return null;
  }
}
