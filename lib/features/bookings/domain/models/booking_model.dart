import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'booking_model.g.dart';

@HiveType(typeId: 2)
class BookingModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String roomId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final DateTime checkIn;

  @HiveField(4)
  final DateTime checkOut;

  @HiveField(5)
  final double totalPrice;

  @HiveField(6)
  final BookingStatus status;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final String roomName;

  @HiveField(9)
  final String roomImageUrl;

  const BookingModel({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.roomName,
    required this.roomImageUrl,
  });

  int get numberOfNights => checkOut.difference(checkIn).inDays;

  bool get isUpcoming =>
      status == BookingStatus.confirmed &&
      checkIn.isAfter(DateTime.now());

  bool get isOngoing =>
      status == BookingStatus.confirmed &&
      checkIn.isBefore(DateTime.now()) &&
      checkOut.isAfter(DateTime.now());

  bool get isPast =>
      status == BookingStatus.completed ||
      (status == BookingStatus.confirmed && checkOut.isBefore(DateTime.now()));

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      userId: json['userId'] as String,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      roomName: json['roomName'] as String,
      roomImageUrl: json['roomImageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'userId': userId,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'roomName': roomName,
      'roomImageUrl': roomImageUrl,
    };
  }

  BookingModel copyWith({
    String? id,
    String? roomId,
    String? userId,
    DateTime? checkIn,
    DateTime? checkOut,
    double? totalPrice,
    BookingStatus? status,
    DateTime? createdAt,
    String? roomName,
    String? roomImageUrl,
  }) {
    return BookingModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      roomName: roomName ?? this.roomName,
      roomImageUrl: roomImageUrl ?? this.roomImageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        userId,
        checkIn,
        checkOut,
        totalPrice,
        status,
        createdAt,
        roomName,
        roomImageUrl,
      ];
}

@HiveType(typeId: 3)
enum BookingStatus {
  @HiveField(0)
  confirmed,
  @HiveField(1)
  cancelled,
  @HiveField(2)
  completed,
}
