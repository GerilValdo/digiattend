import 'dart:convert';

BatchModel batchModelFromJson(String str) => BatchModel.fromJson(json.decode(str));

String batchModelToJson(BatchModel data) => json.encode(data.toJson());

class BatchModel {
    final String? message;
    final List<BatchData>? data;

    BatchModel({
        this.message,
        this.data,
    });

    BatchModel copyWith({
        String? message,
        List<BatchData>? data,
    }) => 
        BatchModel(
            message: message ?? this.message,
            data: data ?? this.data,
        );

    factory BatchModel.fromJson(Map<String, dynamic> json) => BatchModel(
        message: json["message"],
        data: json["data"] == null ? [] : List<BatchData>.from(json["data"]!.map((x) => BatchData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class BatchData {
    final int? id;
    final String? batchKe;
    final DateTime? startDate;
    final DateTime? endDate;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final List<Training>? trainings;

    BatchData({
        this.id,
        this.batchKe,
        this.startDate,
        this.endDate,
        this.createdAt,
        this.updatedAt,
        this.trainings,
    });

    BatchData copyWith({
        int? id,
        String? batchKe,
        DateTime? startDate,
        DateTime? endDate,
        DateTime? createdAt,
        DateTime? updatedAt,
        List<Training>? trainings,
    }) => 
        BatchData(
            id: id ?? this.id,
            batchKe: batchKe ?? this.batchKe,
            startDate: startDate ?? this.startDate,
            endDate: endDate ?? this.endDate,
            createdAt: createdAt ?? this.createdAt,
            updatedAt: updatedAt ?? this.updatedAt,
            trainings: trainings ?? this.trainings,
        );

    factory BatchData.fromJson(Map<String, dynamic> json) => BatchData(
        id: json["id"],
        batchKe: json["batch_ke"],
        startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
        endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        trainings: json["trainings"] == null ? [] : List<Training>.from(json["trainings"]!.map((x) => Training.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "batch_ke": batchKe,
        "start_date": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "end_date": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "trainings": trainings == null ? [] : List<dynamic>.from(trainings!.map((x) => x.toJson())),
    };
}

class Training {
    final int? id;
    final String? title;
    final Pivot? pivot;

    Training({
        this.id,
        this.title,
        this.pivot,
    });

    Training copyWith({
        int? id,
        String? title,
        Pivot? pivot,
    }) => 
        Training(
            id: id ?? this.id,
            title: title ?? this.title,
            pivot: pivot ?? this.pivot,
        );

    factory Training.fromJson(Map<String, dynamic> json) => Training(
        id: json["id"],
        title: json["title"],
        pivot: json["pivot"] == null ? null : Pivot.fromJson(json["pivot"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "pivot": pivot?.toJson(),
    };
}

class Pivot {
    final String? trainingBatchId;
    final String? trainingId;

    Pivot({
        this.trainingBatchId,
        this.trainingId,
    });

    Pivot copyWith({
        String? trainingBatchId,
        String? trainingId,
    }) => 
        Pivot(
            trainingBatchId: trainingBatchId ?? this.trainingBatchId,
            trainingId: trainingId ?? this.trainingId,
        );

    factory Pivot.fromJson(Map<String, dynamic> json) => Pivot(
        trainingBatchId: json["training_batch_id"],
        trainingId: json["training_id"],
    );

    Map<String, dynamic> toJson() => {
        "training_batch_id": trainingBatchId,
        "training_id": trainingId,
    };
}
