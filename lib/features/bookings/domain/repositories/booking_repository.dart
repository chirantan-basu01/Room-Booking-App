import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/booking_model.dart';

abstract class BookingRepository {
  Future<Either<Failure, List<BookingModel>>> getBookingsByUser(String userId);
  Future<Either<Failure, BookingModel>> createBooking(BookingModel booking);
  Future<Either<Failure, void>> cancelBooking(String bookingId);
  Future<Either<Failure, bool>> isRoomAvailable({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
  });
  Future<Either<Failure, List<BookingModel>>> getBookingsForRoom(String roomId);
}
