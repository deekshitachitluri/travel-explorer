class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final List<String> preferredCategories;
  final String travelStyle;
  final bool isGuest;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.preferredCategories = const ['Beaches', 'Mountains'],
    this.travelStyle = 'Explorer',
    this.isGuest = false,
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    List<String>? preferredCategories,
    String? travelStyle,
    bool? isGuest,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      travelStyle: travelStyle ?? this.travelStyle,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'bio': bio,
    'preferredCategories': preferredCategories,
    'travelStyle': travelStyle,
    'isGuest': isGuest,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String,
    photoUrl: json['photoUrl'] as String?,
    bio: json['bio'] as String?,
    preferredCategories: List<String>.from(json['preferredCategories'] ?? []),
    travelStyle: json['travelStyle'] as String? ?? 'Explorer',
    isGuest: json['isGuest'] as bool? ?? false,
  );

  static UserProfile guest() => const UserProfile(
    id: 'guest_user',
    email: 'guest@travelexplorer.app',
    displayName: 'Guest Traveler',
    bio: 'Exploring incredible destinations in guest mode.',
    isGuest: true,
  );
}
