import 'package:flutter/material.dart';
import 'package:kas_umkm/models/category.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  final List<Category> _categories = [];

  List<Transaction> get transactions => _transactions;
  List<Category> get categories => _categories;

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void updateTransaction(String id, Transaction newTx) {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index >= 0) {
      _transactions[index] = newTx;
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  List<Transaction> get income =>
      _transactions.where((tx) => tx.type == 'income').toList();

  List<Transaction> get expense =>
      _transactions.where((tx) => tx.type == 'expense').toList();


}
