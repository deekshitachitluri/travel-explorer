class Trip {
  final String id;
  final String title;
  final String? destinationId;
  final String destinationName;
  final String? destinationImage;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfTravelers;
  final double plannedBudget;
  final String travelStyle;
  final String? notes;
  final DateTime createdAt;

  const Trip({
    required this.id,
    required this.title,
    this.destinationId,
    required this.destinationName,
    this.destinationImage,
    required this.startDate,
    required this.endDate,
    this.numberOfTravelers = 1,
    required this.plannedBudget,
    this.travelStyle = 'Leisure',
    this.notes,
    required this.createdAt,
  });

  int get totalDays {
    final s = DateTime(startDate.year, startDate.month, startDate.day);
    final e = DateTime(endDate.year, endDate.month, endDate.day);
    return e.difference(s).inDays + 1;
  }

  int get durationDays => totalDays;

  bool get isUpcoming {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    return start.isAfter(today);
  }

  bool get isOngoing {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return !start.isAfter(today) && !end.isBefore(today);
  }

  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return end.isBefore(today);
  }

  Trip copyWith({
    String? id,
    String? title,
    String? destinationId,
    String? destinationName,
    String? destinationImage,
    DateTime? startDate,
    DateTime? endDate,
    int? numberOfTravelers,
    double? plannedBudget,
    String? travelStyle,
    String? notes,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      destinationId: destinationId ?? this.destinationId,
      destinationName: destinationName ?? this.destinationName,
      destinationImage: destinationImage ?? this.destinationImage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numberOfTravelers: numberOfTravelers ?? this.numberOfTravelers,
      plannedBudget: plannedBudget ?? this.plannedBudget,
      travelStyle: travelStyle ?? this.travelStyle,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'destinationId': destinationId,
    'destinationName': destinationName,
    'destinationImage': destinationImage,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'numberOfTravelers': numberOfTravelers,
    'plannedBudget': plannedBudget,
    'travelStyle': travelStyle,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'] as String,
    title: json['title'] as String,
    destinationId: json['destinationId'] as String?,
    destinationName: json['destinationName'] as String,
    destinationImage: json['destinationImage'] as String?,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    numberOfTravelers: (json['numberOfTravelers'] as num?)?.toInt() ?? 1,
    plannedBudget: (json['plannedBudget'] as num).toDouble(),
    travelStyle: json['travelStyle'] as String? ?? 'Leisure',
    notes: json['notes'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );
}
