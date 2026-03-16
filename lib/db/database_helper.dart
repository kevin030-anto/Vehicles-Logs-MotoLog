import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vehicle.dart';
import '../models/log_entry.dart';
import '../models/checklist_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('vehicle_log.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const realType = 'REAL NOT NULL';
    const realNullable = 'REAL';
    const currencyType = 'REAL NOT NULL DEFAULT 0.0';
    const intType = 'INTEGER NOT NULL DEFAULT 0'; // For boolean

    await db.execute('''
CREATE TABLE vehicles (
  id $idType,
  icon $textType,
  name $textType,
  licenseNumber $textType,
  fuelType $textType,
  fuelCapacity $realNullable,
  mileage $realNullable,
  rangePerCharge $realNullable,
  currentKm $realType,
  purchaseDate $textNullable,
  insuranceNumber $textNullable,
  notes $textNullable,
  totalSpent $currencyType
)
    ''');

    await db.execute('''
CREATE TABLE logs (
  id $idType,
  vehicleId INTEGER NOT NULL,
  category $textType,
  date $textType,
  currentKm $realType,
  shopName $textType,
  cost $realType,
  notes $textNullable,
  tags $textNullable,
  nextOilChangeKm $realNullable,
  customName $textNullable,
  FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
)
    ''');

    await db.execute('''
CREATE TABLE checklist (
  id $idType,
  vehicleId INTEGER NOT NULL,
  title $textType,
  dateAdded $textType,
  targetDate $textNullable,
  dateCompleted $textNullable,
  isCompleted $intType,
  FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
)
    ''');
  }

  // Vehicles
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    final db = await instance.database;
    final id = await db.insert('vehicles', vehicle.toMap());
    return Vehicle(
      id: id,
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
      totalSpent: vehicle.totalSpent,
    );
  }

  Future<Vehicle?> readVehicle(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'vehicles',
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Vehicle.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Vehicle>> readAllVehicles() async {
    final db = await instance.database;
    final result = await db.query('vehicles');
    return result.map((json) => Vehicle.fromMap(json)).toList();
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    final db = await instance.database;
    return db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(int id) async {
    final db = await instance.database;
    return await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  // Logs
  Future<LogEntry> createLog(LogEntry log) async {
    final db = await instance.database;
    final id = await db.insert('logs', log.toMap());

    // Update Vehicle totals automatically? The requirement says "When a log is saved...".
    // Better to do this in the Provider to keep DB simple, or transaction here?
    // Let's keep logic in Provider for flexibility, but update DB strictly.
    // Actually, transaction here ensures consistency.

    // However, the requirement is specific about logic:
    // "Current Kilometer Range must update the vehicle's main kilometer range (if it's higher...)"
    // "Cost must be added to the vehicle's total spending"

    // I'll implement explicit helper methods for updating vehicle stats so the provider can call them in a transaction if needed,
    // or just call updateVehicle.

    return LogEntry(
      id: id,
      vehicleId: log.vehicleId,
      category: log.category,
      date: log.date,
      currentKm: log.currentKm,
      shopName: log.shopName,
      cost: log.cost,
      notes: log.notes,
      tags: log.tags,
      nextOilChangeKm: log.nextOilChangeKm,
      customName: log.customName,
    );
  }

  Future<List<LogEntry>> readLogs(int vehicleId) async {
    final db = await instance.database;
    final result = await db.query(
      'logs',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC', // Newest first
    );
    return result.map((json) => LogEntry.fromMap(json)).toList();
  }

  Future<int> updateLog(LogEntry log) async {
    final db = await instance.database;
    return db.update('logs', log.toMap(), where: 'id = ?', whereArgs: [log.id]);
  }

  Future<int> deleteLog(int id) async {
    final db = await instance.database;
    return await db.delete('logs', where: 'id = ?', whereArgs: [id]);
  }

  // Checklist
  Future<ChecklistItem> createChecklist(ChecklistItem item) async {
    final db = await instance.database;
    final id = await db.insert('checklist', item.toMap());
    return ChecklistItem(
      id: id,
      vehicleId: item.vehicleId,
      title: item.title,
      dateAdded: item.dateAdded,
      targetDate: item.targetDate,
      dateCompleted: item.dateCompleted,
      isCompleted: item.isCompleted,
    );
  }

  Future<List<ChecklistItem>> readChecklist(int vehicleId) async {
    final db = await instance.database;
    final result = await db.query(
      'checklist',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'isCompleted ASC, targetDate ASC', // Uncompleted first
    );
    return result.map((json) => ChecklistItem.fromMap(json)).toList();
  }

  Future<int> updateChecklist(ChecklistItem item) async {
    final db = await instance.database;
    return db.update(
      'checklist',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteChecklist(int id) async {
    final db = await instance.database;
    return await db.delete('checklist', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
