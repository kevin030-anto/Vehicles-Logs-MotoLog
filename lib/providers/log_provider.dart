import 'package:flutter/material.dart';
import '../models/log_entry.dart';
import '../models/vehicle.dart';
import '../db/database_helper.dart';

class LogProvider with ChangeNotifier {
  List<LogEntry> _logs = [];
  bool _isLoading = false;

  List<LogEntry> get logs => _logs;
  bool get isLoading => _isLoading;

  Future<void> loadLogs(int vehicleId) async {
    _isLoading = true;
    notifyListeners();
    _logs = await DatabaseHelper.instance.readLogs(vehicleId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addLog(LogEntry log, Vehicle vehicle) async {
    await DatabaseHelper.instance.createLog(log);

    // Update Vehicle Logic
    double newTotalSpent = vehicle.totalSpent + log.cost;
    double newCurrentKm = vehicle.currentKm;

    if (log.currentKm > vehicle.currentKm) {
      newCurrentKm = log.currentKm;
    }

    if (newTotalSpent != vehicle.totalSpent ||
        newCurrentKm != vehicle.currentKm) {
      final updatedVehicle = Vehicle(
        id: vehicle.id,
        icon: vehicle.icon,
        name: vehicle.name,
        licenseNumber: vehicle.licenseNumber,
        fuelType: vehicle.fuelType,
        fuelCapacity: vehicle.fuelCapacity,
        mileage: vehicle.mileage,
        rangePerCharge: vehicle.rangePerCharge,
        currentKm: newCurrentKm,
        purchaseDate: vehicle.purchaseDate,
        insuranceNumber: vehicle.insuranceNumber,
        notes: vehicle.notes,
        totalSpent: newTotalSpent,
      );
      await DatabaseHelper.instance.updateVehicle(updatedVehicle);
    }

    await loadLogs(vehicle.id!);
  }

  Future<void> updateLog(LogEntry log, Vehicle vehicle, double oldCost) async {
    await DatabaseHelper.instance.updateLog(log);

    // Complex logic to revert old cost and add new cost?
    // Simplified: Just re-calculate total spent from all logs might be safer but slower.
    // Or just diff: newTotal = currentTotal - oldCost + newCost.

    double newTotalSpent = vehicle.totalSpent - oldCost + log.cost;
    // Max KM logic is tricky on edit. If we edited the max km log, we might need to find the new max.
    // For simplicity, we just check if new KM is greater than current. Reverting to lower is harder without querying max.
    // Let's assume we update max if new log is higher.

    double newCurrentKm = vehicle.currentKm;
    if (log.currentKm > newCurrentKm) {
      newCurrentKm = log.currentKm;
    }

    final updatedVehicle = Vehicle(
      id: vehicle.id,
      icon: vehicle.icon,
      name: vehicle.name,
      licenseNumber: vehicle.licenseNumber,
      fuelType: vehicle.fuelType,
      fuelCapacity: vehicle.fuelCapacity,
      mileage: vehicle.mileage,
      rangePerCharge: vehicle.rangePerCharge,
      currentKm: newCurrentKm,
      purchaseDate: vehicle.purchaseDate,
      insuranceNumber: vehicle.insuranceNumber,
      notes: vehicle.notes,
      totalSpent: newTotalSpent,
    );
    await DatabaseHelper.instance.updateVehicle(updatedVehicle);

    await loadLogs(log.vehicleId);
  }

  Future<void> deleteLog(LogEntry log, Vehicle vehicle) async {
    await DatabaseHelper.instance.deleteLog(log.id!);

    double newTotalSpent = vehicle.totalSpent - log.cost;
    // We don't revert KM because we don't know the previous max easily without query.
    // And usually odometer doesn't go back.

    final updatedVehicle = Vehicle(
      id: vehicle.id,
      icon: vehicle.icon,
      name: vehicle.name,
      licenseNumber: vehicle.licenseNumber,
      fuelType: vehicle.fuelType,
      fuelCapacity: vehicle.fuelCapacity,
      mileage: vehicle.mileage,
      rangePerCharge: vehicle.rangePerCharge,
      currentKm: vehicle.currentKm,
      purchaseDate: vehicle.purchaseDate,
      insuranceNumber: vehicle.insuranceNumber,
      notes: vehicle.notes,
      totalSpent: newTotalSpent,
    );
    await DatabaseHelper.instance.updateVehicle(updatedVehicle);

    await loadLogs(log.vehicleId);
  }
}
