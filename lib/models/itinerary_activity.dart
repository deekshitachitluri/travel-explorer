class ItineraryActivity {
  final String id;
  final String tripId;
  final int dayNumber;
  final DateTime date;
  final String title;
  final String locationName;
  final String? time;
  final String? notes;
  final bool isCompleted;
  final double? latitude;
  final double? longitude;

  const ItineraryActivity({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    required this.date,
    required this.title,
    required this.locationName,
    this.time,
    this.notes,
    this.isCompleted = false,
    this.latitude,
    this.longitude,
  });

  ItineraryActivity copyWith({
    String? id,
    String? tripId,
    int? dayNumber,
    DateTime? date,
    String? title,
    String? locationName,
    String? time,
    String? notes,
    bool? isCompleted,
    double? latitude,
    double? longitude,
  }) {
    return ItineraryActivity(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      title: title ?? this.title,
      locationName: locationName ?? this.locationName,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tripId': tripId,
    'dayNumber': dayNumber,
    'date': date.toIso8601String(),
    'title': title,
    'locationName': locationName,
    'time': time,
    'notes': notes,
    'isCompleted': isCompleted,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) =>
      ItineraryActivity(
        id: json['id'] as String,
        tripId: json['tripId'] as String,
        dayNumber: (json['dayNumber'] as num).toInt(),
        date: DateTime.parse(json['date'] as String),
        title: json['title'] as String,
        locationName: json['locationName'] as String,
        time: json['time'] as String?,
        notes: json['notes'] as String?,
        isCompleted: json['isCompleted'] as bool? ?? false,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}
