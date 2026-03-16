class Vehicle {
  final int? id;
  final String icon; // 'car', 'bike', 'scooty'
  final String name;
  final String licenseNumber;
  final String fuelType; // 'Petrol', 'Diesel', 'EV'
  final double? fuelCapacity;
  final double? mileage;
  final double? rangePerCharge;
  double currentKm;
  final String? purchaseDate;
  final String? insuranceNumber;
  final String? notes;
  double totalSpent;

  Vehicle({
    this.id,
    required this.icon,
    required this.name,
    required this.licenseNumber,
    required this.fuelType,
    this.fuelCapacity,
    this.mileage,
    this.rangePerCharge,
    required this.currentKm,
    this.purchaseDate,
    this.insuranceNumber,
    this.notes,
    this.totalSpent = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icon': icon,
      'name': name,
      'licenseNumber': licenseNumber,
      'fuelType': fuelType,
      'fuelCapacity': fuelCapacity,
      'mileage': mileage,
      'rangePerCharge': rangePerCharge,
      'currentKm': currentKm,
      'purchaseDate': purchaseDate,
      'insuranceNumber': insuranceNumber,
      'notes': notes,
      'totalSpent': totalSpent,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      icon: map['icon'],
      name: map['name'],
      licenseNumber: map['licenseNumber'],
      fuelType: map['fuelType'],
      fuelCapacity: map['fuelCapacity'],
      mileage: map['mileage'],
      rangePerCharge: map['rangePerCharge'],
      currentKm: map['currentKm'],
      purchaseDate: map['purchaseDate'],
      insuranceNumber: map['insuranceNumber'],
      notes: map['notes'],
      totalSpent: map['totalSpent'] ?? 0.0,
    );
  }
}
