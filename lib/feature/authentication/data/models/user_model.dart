class UserModel {
  final int id;
  final String name;
  final String email;
  final String jenisKelamin;
  final String? profilePhoto;
  final int batchId;
  final int trainingId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.jenisKelamin,
    required this.profilePhoto,
    required this.batchId,
    required this.trainingId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      jenisKelamin: json["jenis_kelamin"],
      profilePhoto: json["profile_photo"],
      batchId: int.parse(json["batch_id"]),
      trainingId: int.parse(json["training_id"]),
    );
  }
}
