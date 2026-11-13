import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/dashboard.dart';
import 'api_config.dart';

class DashboardService {
  // GET /dashboard?adminId=1
  Future<Dashboard> buscar(int adminId) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/dashboard?adminId=$adminId'))
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return Dashboard.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    }

    // 403: usuário sem perfil ADMIN
    throw Exception(utf8.decode(response.bodyBytes));
  }
}
