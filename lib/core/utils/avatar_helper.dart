import 'package:digiattend/core/constants/endpoint.dart';


String? getFinalPhoto(String? raw) {
if (raw == null || raw.isEmpty) return null;
if (raw.startsWith('http')) return raw;
return '${Endpoint.baseUrl}/public/$raw';
}