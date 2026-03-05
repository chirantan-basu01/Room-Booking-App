import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'room_model.g.dart';

@HiveType(typeId: 0)
class RoomModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double pricePerNight;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final int capacity;

  @HiveField(6)
  final List<String> amenities;

  @HiveField(7)
  final RoomType type;

  @HiveField(8)
  final double rating;

  @HiveField(9)
  final int reviewCount;

  const RoomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.imageUrl,
    required this.capacity,
    required this.amenities,
    required this.type,
    this.rating = 4.5,
    this.reviewCount = 0,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      capacity: json['capacity'] as int,
      amenities: List<String>.from(json['amenities'] as List),
      type: RoomType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RoomType.standard,
      ),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pricePerNight': pricePerNight,
      'imageUrl': imageUrl,
      'capacity': capacity,
      'amenities': amenities,
      'type': type.name,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  String get typeLabel {
    switch (type) {
      case RoomType.standard:
        return 'Standard';
      case RoomType.deluxe:
        return 'Deluxe';
      case RoomType.suite:
        return 'Suite';
      case RoomType.presidential:
        return 'Presidential';
    }
  }

  String get capacityLabel {
    return '$capacity ${capacity == 1 ? 'Guest' : 'Guests'}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        pricePerNight,
        imageUrl,
        capacity,
        amenities,
        type,
        rating,
        reviewCount,
      ];
}

@HiveType(typeId: 1)
enum RoomType {
  @HiveField(0)
  standard,
  @HiveField(1)
  deluxe,
  @HiveField(2)
  suite,
  @HiveField(3)
  presidential,
}
