import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_local_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingLocalDataSource _localDataSource;

  BookingRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<BookingModel>>> getBookingsByUser(
    String userId,
  ) async {
    try {
      final bookings = await _localDataSource.getBookingsByUser(userId);
      return Right(bookings);
    } catch (e) {
      return Left(BookingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingModel>> createBooking(
    BookingModel booking,
  ) async {
    try {
      final isAvailable = await _checkAvailability(
        roomId: booking.roomId,
        checkIn: booking.checkIn,
        checkOut: booking.checkOut,
      );

      if (!isAvailable) {
        return const Left(
          BookingFailure('Room is not available for selected dates'),
        );
      }

      final createdBooking = await _localDataSource.createBooking(booking);
      return Right(createdBooking);
    } catch (e) {
      return Left(BookingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    try {
      await _localDataSource.cancelBooking(bookingId);
      return const Right(null);
    } catch (e) {
      return Left(BookingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isRoomAvailable({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    try {
      final isAvailable = await _checkAvailability(
        roomId: roomId,
        checkIn: checkIn,
        checkOut: checkOut,
      );
      return Right(isAvailable);
    } catch (e) {
      return Left(BookingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingModel>>> getBookingsForRoom(
    String roomId,
  ) async {
    try {
      final bookings = await _localDataSource.getBookingsForRoom(roomId);
      return Right(bookings);
    } catch (e) {
      return Left(BookingFailure(e.toString()));
    }
  }

  Future<bool> _checkAvailability({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    final existingBookings =
        await _localDataSource.getBookingsForRoom(roomId);

    for (final booking in existingBookings) {
      if (booking.status == BookingStatus.cancelled) continue;

      final hasOverlap =
          checkIn.isBefore(booking.checkOut) && checkOut.isAfter(booking.checkIn);

      if (hasOverlap) {
        return false;
      }
    }

    return true;
  }
}
