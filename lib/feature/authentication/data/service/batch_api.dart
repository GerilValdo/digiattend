import 'dart:convert';
import 'package:digiattend/core/constants/endpoint.dart';
import 'package:digiattend/feature/authentication/data/models/batch_model.dart';
import 'package:http/http.dart' as http;

class BatchAPI {
  // Return List<BatchData> sesuai model BatchModel.data
  static Future<List<BatchData>> getBatchList() async {
    final url = Uri.parse(Endpoint.trainingBatches);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // parse wrapper model
      final batchModel = BatchModel.fromJson(decoded);
      return batchModel.data ?? [];
    } else {
      throw Exception("Failed to load batch");
    }
  }
}
