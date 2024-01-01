import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neocortexapp/business/authenticate_manager.dart';
import 'package:neocortexapp/config/app/app_config.dart';
import 'package:neocortexapp/entities/transaction.dart';

class TransactionsRepository {
  static Future<List<Transactions>> getTransactions(BuildContext context) async {
    List<Transactions> transactions = [];
    AuthenticateManager authenticateManager = AuthenticateManager();
    await authenticateManager.init();
    var now = DateTime.now();
    var lastDate = DateTime(now.year, now.month + 1, 0);

    final response = await http.get(
        Uri.parse(
            "${AppConfig.baseApiUrl}/getcoolertransactionsnew?start_date=${now.year}${now.month}01&end_date=${now.year}${now.month}${lastDate.day}"),
        headers: <String, String>{
          "token": authenticateManager.getToken()!,
          "project_id": authenticateManager.getProjectId()!
        });

    var bodyDecoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      int count = bodyDecoded["Content"]["1"]["transaction_records"].length;
      for (var i = 1; i <= count; i++) {
        var dataTransaction = bodyDecoded["Content"]["1"]["transaction_records"]["$i"];
        transactions.add(Transactions.fromJson(dataTransaction));
      }
      return transactions;
    } else if (response.statusCode == 401) {
      // ignore: use_build_context_synchronously
      await AuthenticateManager.logout(context);
    } else {
      throw Exception('Ziyaret Listesi Hatası ${bodyDecoded["Content"]}');
    }
    return transactions;
  }
}
