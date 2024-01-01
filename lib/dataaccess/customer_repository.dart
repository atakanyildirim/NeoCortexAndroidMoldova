import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/app/app_config.dart';
import 'package:neocortexapp/entities/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerRepository {
  static Future<List<Customer>> getAll() async {
    List<Customer> customers = [];
    AuthenticateManager authenticateManager = AuthenticateManager();
    await authenticateManager.init();
    final prefs = await SharedPreferences.getInstance();

    final response = await http.get(Uri.parse("${AppConfig.baseApiUrl}/webcustomerwithvariableplanograms"),
        headers: <String, String>{
          "token": authenticateManager.getToken()!,
          "project_id": authenticateManager.getProjectId()!
        });

    var customerData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      int count = customerData["Content"]["customers"].length;
      for (var i = 1; i <= count; i++) {
        var dataCustomer = customerData["Content"]["customers"]["$i"];
        customers.add(Customer.fromJson(dataCustomer));
      }
      prefs.setString("customerwithvariableplanograms", response.body);
      return customers;
    } else {
      throw Exception('Müşteri Listesi Hatası ${customerData["Content"]}');
    }
  }
}
