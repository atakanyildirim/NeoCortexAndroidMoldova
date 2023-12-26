import 'dart:convert';
import 'package:neocortexapp/dataaccess/customer_repository.dart';
import 'package:neocortexapp/entities/planogram_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanogramManager {
  static Future<List<PlanogramColors>> getCachedPlanogramCategoryColors() async {
    List<PlanogramColors>? planogramCategoryColors = [];

    final prefs = await SharedPreferences.getInstance();
    var jsonBody = prefs.getString("customerwithvariableplanograms");
    if (jsonBody == null) {
      await CustomerRepository.getAll();
      jsonBody = prefs.getString("customerwithvariableplanograms");
    }

    var customerData = jsonDecode(jsonBody!);

    var maplik = customerData["Content"]['planogram_category_colors'];
    (maplik as Map).forEach((key, value) {
      planogramCategoryColors.add(PlanogramColors(name: key, colorCode: value));
    });

    return planogramCategoryColors;
  }
}
