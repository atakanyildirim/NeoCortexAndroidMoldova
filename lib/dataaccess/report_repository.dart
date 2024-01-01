import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/app/app_config.dart';
import 'package:neocortexapp/entities/report.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportRepository {
  static Future<Report?> getReport() async {
    Report? report;
    AuthenticateManager authenticateManager = AuthenticateManager();
    await authenticateManager.init();
    final prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse("${AppConfig.baseApiUrl}/mobreportnew"), headers: <String, String>{
      "token": authenticateManager.getToken()!,
      "project_id": authenticateManager.getProjectId()!
    });
    var reportData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      var dataCustomer = reportData["Content"]["1"];
      report = Report.fromJson(dataCustomer);
      prefs.setString("reports", response.body);
      return report;
    } else {
      throw Exception('Rapor Listesi Hatası ${reportData["Content"]}');
    }
  }
}
