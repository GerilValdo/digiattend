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
      batchId: int.parse(json["batch_id"].toString()),
      trainingId: int.parse(json["training_id"].toString()),
    );
  }

  /// ========================= COPYWITH =========================
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? jenisKelamin,
    String? profilePhoto,
    int? batchId,
    int? trainingId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      batchId: batchId ?? this.batchId,
      trainingId: trainingId ?? this.trainingId,
    );
  }

  /// ========================= TO JSON =========================
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "jenis_kelamin": jenisKelamin,
      "profile_photo": profilePhoto,
      "batch_id": batchId.toString(),
      "training_id": trainingId.toString(),
    };
  }
}
