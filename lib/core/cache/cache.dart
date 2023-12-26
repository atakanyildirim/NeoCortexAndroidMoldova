import 'dart:convert';

import 'package:neocortexapp/entities/customer.dart';
import 'package:neocortexapp/entities/report.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheData {
  static Future<List<Customer>> getCachedCustomersWithPlanograms() async {
    List<Customer> customers = [];
    final prefs = await SharedPreferences.getInstance();
    var body = prefs.getString("customerwithvariableplanograms");
    var cacheData = body != null ? jsonDecode(prefs.getString("customerwithvariableplanograms")!) : null;
    if (cacheData != null) {
      int count = cacheData["Content"]["customers"].length;
      for (var i = 1; i <= count; i++) {
        var dataCustomer = cacheData["Content"]["customers"]["$i"];
        customers.add(Customer.fromJson(dataCustomer));
      }
    }
    return customers;
  }

  static Future<Report?> getCachedReport() async {
    Report? report;
    final prefs = await SharedPreferences.getInstance();
    var body = prefs.getString("reports");
    var cacheData = body != null ? jsonDecode(body) : null;
    if (cacheData != null) {
      var dataReport = cacheData["Content"]["1"];
      report = Report.fromJson(dataReport);
    }
    return report;
  }

  static Future<List<String>?> getCachedPifList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? pifList = prefs.getStringList("pifList");
    return pifList;
  }
}
