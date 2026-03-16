class ChecklistItem {
  final int? id;
  final int vehicleId;
  final String title;
  final String dateAdded;
  final String? targetDate;
  final String? dateCompleted;
  final int isCompleted; // SQLite stores booleans as 0 or 1

  ChecklistItem({
    this.id,
    required this.vehicleId,
    required this.title,
    required this.dateAdded,
    this.targetDate,
    this.dateCompleted,
    this.isCompleted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'title': title,
      'dateAdded': dateAdded,
      'targetDate': targetDate,
      'dateCompleted': dateCompleted,
      'isCompleted': isCompleted,
    };
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'],
      vehicleId: map['vehicleId'],
      title: map['title'],
      dateAdded: map['dateAdded'],
      targetDate: map['targetDate'],
      dateCompleted: map['dateCompleted'],
      isCompleted: map['isCompleted'] ?? 0,
    );
  }
}
