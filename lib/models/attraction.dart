class Attraction {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String openingHours;
  final String entryFee;

  const Attraction({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.openingHours = 'Open daily: 9:00 AM - 6:00 PM',
    this.entryFee = 'Free entry',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'latitude': latitude,
    'longitude': longitude,
    'openingHours': openingHours,
    'entryFee': entryFee,
  };

  factory Attraction.fromJson(Map<String, dynamic> json) => Attraction(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    imageUrl: json['imageUrl'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    openingHours:
        json['openingHours'] as String? ?? 'Open daily: 9:00 AM - 6:00 PM',
    entryFee: json['entryFee'] as String? ?? 'Free entry',
  );
}
