// To parse this JSON data, do
//
//     final trainingModel = trainingModelFromJson(jsonString);

import 'dart:convert';

TrainingModel trainingModelFromJson(String str) => TrainingModel.fromJson(json.decode(str));

String trainingModelToJson(TrainingModel data) => json.encode(data.toJson());

class TrainingModel {
    final String? message;
    final List<TrainingData>? data;

    TrainingModel({
        this.message,
        this.data,
    });

    TrainingModel copyWith({
        String? message,
        List<TrainingData>? data,
    }) => 
        TrainingModel(
            message: message ?? this.message,
            data: data ?? this.data,
        );

    factory TrainingModel.fromJson(Map<String, dynamic> json) => TrainingModel(
        message: json["message"],
        data: json["data"] == null ? [] : List<TrainingData>.from(json["data"]!.map((x) => TrainingData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class TrainingData {
    final int? id;
    final String? title;

    TrainingData({
        this.id,
        this.title,
    });

    TrainingData copyWith({
        int? id,
        String? title,
    }) => 
        TrainingData(
            id: id ?? this.id,
            title: title ?? this.title,
        );

    factory TrainingData.fromJson(Map<String, dynamic> json) => TrainingData(
        id: json["id"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
    };
}
