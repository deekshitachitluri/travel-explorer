class UserReview {
  final String id;
  final String destinationId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const UserReview({
    required this.id,
    required this.destinationId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'destinationId': destinationId,
    'userId': userId,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserReview.fromJson(Map<String, dynamic> json) => UserReview(
    id: json['id'] as String,
    destinationId: json['destinationId'] as String,
    userId: json['userId'] as String? ?? 'guest',
    userName: json['userName'] as String? ?? 'Traveler',
    rating: (json['rating'] as num).toDouble(),
    comment: json['comment'] as String? ?? '',
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
  );
}
