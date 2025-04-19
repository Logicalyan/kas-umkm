import 'package:flutter/material.dart';
import 'package:kas_umkm/models/category.dart';
import 'package:uuid/uuid.dart';

class CategoryProvider with ChangeNotifier {
  final List<Category> _categories = [];

  List<Category> get categories => _categories;

  void addCategory(String name) {
    final newCategory = Category(
      id: const Uuid().v4(),
      name: name,
    );
    _categories.add(newCategory);
    notifyListeners();
  }

  void deleteCategory(String id) {
    _categories.removeWhere((cat) => cat.id == id);
    notifyListeners();
  }
}
