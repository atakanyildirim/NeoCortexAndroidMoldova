import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/app/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductRepository {
  static Future<List<String>> getPifList() async {
    AuthenticateManager authenticateManager = AuthenticateManager();
    await authenticateManager.init();
    final prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse("${AppConfig.baseApiUrl}/getpiflist"), headers: <String, String>{
      "token": authenticateManager.getToken()!,
      "project_id": authenticateManager.getProjectId()!
    });

    var imageData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      List<String> pifList = List<String>.from(imageData["Content"]);
      prefs.setStringList("pifList", pifList);
      return pifList;
    } else {
      throw Exception('Ürün Listesi Hatası ${imageData["Content"]}');
    }
  }
}
