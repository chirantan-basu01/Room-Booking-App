import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/booking_model.dart';

abstract class BookingLocalDataSource {
  Future<List<BookingModel>> getBookingsByUser(String userId);
  Future<BookingModel> createBooking(BookingModel booking);
  Future<void> cancelBooking(String bookingId);
  Future<List<BookingModel>> getBookingsForRoom(String roomId);
  Future<List<BookingModel>> getAllBookings();
}

class BookingLocalDataSourceImpl implements BookingLocalDataSource {
  final HiveInterface _hive;

  BookingLocalDataSourceImpl(this._hive);

  Box get _box => _hive.box(AppConstants.hiveBookingsBox);

  @override
  Future<List<BookingModel>> getAllBookings() async {
    final bookingsJson = _box.get('bookings', defaultValue: '[]') as String;
    final List<dynamic> bookingsList = jsonDecode(bookingsJson);
    return bookingsList
        .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveBookings(List<BookingModel> bookings) async {
    final bookingsJson =
        jsonEncode(bookings.map((b) => b.toJson()).toList());
    await _box.put('bookings', bookingsJson);
  }

  @override
  Future<List<BookingModel>> getBookingsByUser(String userId) async {
    final allBookings = await getAllBookings();
    return allBookings
        .where((b) => b.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    final allBookings = await getAllBookings();
    allBookings.add(booking);
    await _saveBookings(allBookings);
    return booking;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    final allBookings = await getAllBookings();
    final index = allBookings.indexWhere((b) => b.id == bookingId);

    if (index == -1) {
      throw Exception('Booking not found');
    }

    allBookings[index] = allBookings[index].copyWith(
      status: BookingStatus.cancelled,
    );

    await _saveBookings(allBookings);
  }

  @override
  Future<List<BookingModel>> getBookingsForRoom(String roomId) async {
    final allBookings = await getAllBookings();
    return allBookings
        .where((b) =>
            b.roomId == roomId && b.status != BookingStatus.cancelled)
        .toList();
  }
}
