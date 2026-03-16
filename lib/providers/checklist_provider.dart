import 'package:flutter/material.dart';
import '../models/checklist_item.dart';
import '../db/database_helper.dart';

class ChecklistProvider with ChangeNotifier {
  List<ChecklistItem> _items = [];
  bool _isLoading = false;

  List<ChecklistItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadChecklist(int vehicleId) async {
    _isLoading = true;
    notifyListeners();
    _items = await DatabaseHelper.instance.readChecklist(vehicleId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addChecklist(ChecklistItem item) async {
    await DatabaseHelper.instance.createChecklist(item);
    await loadChecklist(item.vehicleId);
  }

  Future<void> updateChecklist(ChecklistItem item) async {
    await DatabaseHelper.instance.updateChecklist(item);
    await loadChecklist(item.vehicleId);
  }

  Future<void> deleteChecklist(int id, int vehicleId) async {
    await DatabaseHelper.instance.deleteChecklist(id);
    await loadChecklist(vehicleId);
  }

  Future<void> toggleComplete(ChecklistItem item, bool isCompleted) async {
    final updatedItem = ChecklistItem(
      id: item.id,
      vehicleId: item.vehicleId,
      title: item.title,
      dateAdded: item.dateAdded,
      targetDate: item.targetDate,
      dateCompleted: isCompleted
          ? DateTime.now().toString().split(' ')[0]
          : null,
      isCompleted: isCompleted ? 1 : 0,
    );
    await updateChecklist(updatedItem);
  }
}
