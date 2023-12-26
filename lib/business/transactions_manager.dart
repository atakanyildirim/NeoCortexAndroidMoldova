import 'package:flutter/material.dart';
import 'package:neocortexapp/dataaccess/transactions_repository.dart';
import 'package:neocortexapp/entities/transaction.dart';

class TransactionsManager {
  static Future<List<Transactions>> getCachedTransactionsData(BuildContext context) async {
    return TransactionsRepository.getTransactions(context);
  }
}
