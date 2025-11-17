import 'dart:convert';
import 'package:digiattend/core/constants/endpoint.dart';
import 'package:digiattend/feature/authentication/data/models/training_model.dart';
import 'package:http/http.dart' as http;

class TrainingAPI {
  // Return List<TrainingData> sesuai model TrainingModel.data
  static Future<List<TrainingData>> getTrainingList() async {
    final url = Uri.parse(Endpoint.trainings);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final trainingModel = TrainingModel.fromJson(decoded);
      return trainingModel.data ?? [];
    } else {
      throw Exception("Failed to load training");
    }
  }
}
