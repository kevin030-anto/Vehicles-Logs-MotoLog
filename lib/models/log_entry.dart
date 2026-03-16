class LogEntry {
  final int? id;
  final int vehicleId;
  final String
  category; // 'Services', 'Oil Change', 'Tire Change', 'Battery Services', 'Other Changes'
  final String date;
  final double currentKm;
  final String shopName;
  final double cost;
  final String? notes;

  // Specific fields
  final String? tags; // For Services (comma separated or JSON)
  final double? nextOilChangeKm; // For Oil Change
  final String? customName; // For Other

  LogEntry({
    this.id,
    required this.vehicleId,
    required this.category,
    required this.date,
    required this.currentKm,
    required this.shopName,
    required this.cost,
    this.notes,
    this.tags,
    this.nextOilChangeKm,
    this.customName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'category': category,
      'date': date,
      'currentKm': currentKm,
      'shopName': shopName,
      'cost': cost,
      'notes': notes,
      'tags': tags,
      'nextOilChangeKm': nextOilChangeKm,
      'customName': customName,
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'],
      vehicleId: map['vehicleId'],
      category: map['category'],
      date: map['date'],
      currentKm: map['currentKm'],
      shopName: map['shopName'],
      cost: map['cost'],
      notes: map['notes'],
      tags: map['tags'],
      nextOilChangeKm: map['nextOilChangeKm'],
      customName: map['customName'],
    );
  }
}
