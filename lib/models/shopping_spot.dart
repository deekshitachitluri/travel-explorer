class ShoppingSpot {
  final String id;
  final String destinationId;
  final String name;
  final String locality;
  final String knownFor;
  final List<String> specialities;
  final double latitude;
  final double longitude;
  final String openingHours;
  final String? bestTimeToVisit;
  final String? tips;

  const ShoppingSpot({
    required this.id,
    required this.destinationId,
    required this.name,
    required this.locality,
    required this.knownFor,
    required this.specialities,
    required this.latitude,
    required this.longitude,
    this.openingHours = '10:00 AM - 8:30 PM',
    this.bestTimeToVisit,
    this.tips,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'destinationId': destinationId,
    'name': name,
    'locality': locality,
    'knownFor': knownFor,
    'specialities': specialities,
    'latitude': latitude,
    'longitude': longitude,
    'openingHours': openingHours,
    'bestTimeToVisit': bestTimeToVisit,
    'tips': tips,
  };

  factory ShoppingSpot.fromJson(Map<String, dynamic> json) => ShoppingSpot(
    id: json['id'] as String,
    destinationId: json['destinationId'] as String,
    name: json['name'] as String,
    locality: json['locality'] as String,
    knownFor: json['knownFor'] as String,
    specialities:
        (json['specialities'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    openingHours: json['openingHours'] as String? ?? '10:00 AM - 8:30 PM',
    bestTimeToVisit: json['bestTimeToVisit'] as String?,
    tips: json['tips'] as String?,
  );
}
