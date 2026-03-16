import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../db/database_helper.dart';

class VehicleProvider with ChangeNotifier {
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;

  Future<void> loadVehicles() async {
    _isLoading = true;
    notifyListeners();
    _vehicles = await DatabaseHelper.instance.readAllVehicles();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await DatabaseHelper.instance.createVehicle(vehicle);
    await loadVehicles();
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await DatabaseHelper.instance.updateVehicle(vehicle);
    await loadVehicles();
  }

  Future<void> deleteVehicle(int id) async {
    await DatabaseHelper.instance.deleteVehicle(id);
    await loadVehicles();
  }

  // Method to refresh specific vehicle data (useful after adding logs)
  Future<void> refreshVehicle(int id) async {
    // Reload all for simplicity, or just update the specific one in the list
    await loadVehicles();
  }
}
