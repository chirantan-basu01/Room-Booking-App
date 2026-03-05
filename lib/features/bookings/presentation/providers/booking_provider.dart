import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../rooms/domain/models/room_model.dart';
import '../../data/datasources/booking_local_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingFormState {
  final RoomModel? selectedRoom;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final bool isLoading;
  final bool isAvailable;
  final String? error;
  final bool isSuccess;
  final BookingModel? createdBooking;

  const BookingFormState({
    this.selectedRoom,
    this.checkIn,
    this.checkOut,
    this.isLoading = false,
    this.isAvailable = true,
    this.error,
    this.isSuccess = false,
    this.createdBooking,
  });

  double get totalPrice {
    if (selectedRoom == null || checkIn == null || checkOut == null) return 0;
    final nights = checkOut!.difference(checkIn!).inDays;
    return selectedRoom!.pricePerNight * nights;
  }

  int get numberOfNights {
    if (checkIn == null || checkOut == null) return 0;
    return checkOut!.difference(checkIn!).inDays;
  }

  bool get isValid {
    return selectedRoom != null &&
        checkIn != null &&
        checkOut != null &&
        numberOfNights > 0 &&
        isAvailable;
  }

  BookingFormState copyWith({
    RoomModel? selectedRoom,
    DateTime? checkIn,
    DateTime? checkOut,
    bool? isLoading,
    bool? isAvailable,
    String? error,
    bool? isSuccess,
    BookingModel? createdBooking,
    bool clearRoom = false,
    bool clearDates = false,
    bool clearError = false,
  }) {
    return BookingFormState(
      selectedRoom: clearRoom ? null : (selectedRoom ?? this.selectedRoom),
      checkIn: clearDates ? null : (checkIn ?? this.checkIn),
      checkOut: clearDates ? null : (checkOut ?? this.checkOut),
      isLoading: isLoading ?? this.isLoading,
      isAvailable: isAvailable ?? this.isAvailable,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
      createdBooking: createdBooking ?? this.createdBooking,
    );
  }
}

class BookingFormNotifier extends StateNotifier<BookingFormState> {
  final BookingRepository _repository;
  final Ref _ref;

  BookingFormNotifier(this._repository, this._ref)
      : super(const BookingFormState());

  void setRoom(RoomModel room) {
    state = BookingFormState(selectedRoom: room);
  }

  void setCheckIn(DateTime date) {
    state = state.copyWith(
      checkIn: date,
      isAvailable: true,
      clearError: true,
    );
    if (state.checkOut != null && state.checkOut!.isBefore(date)) {
      state = state.copyWith(checkOut: null);
    }
    _checkAvailabilityIfNeeded();
  }

  void setCheckOut(DateTime date) {
    state = state.copyWith(
      checkOut: date,
      isAvailable: true,
      clearError: true,
    );
    _checkAvailabilityIfNeeded();
  }

  Future<void> _checkAvailabilityIfNeeded() async {
    if (state.selectedRoom == null ||
        state.checkIn == null ||
        state.checkOut == null) {
      return;
    }

    state = state.copyWith(isLoading: true);

    final result = await _repository.isRoomAvailable(
      roomId: state.selectedRoom!.id,
      checkIn: state.checkIn!,
      checkOut: state.checkOut!,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (isAvailable) => state = state.copyWith(
        isLoading: false,
        isAvailable: isAvailable,
        error: isAvailable ? null : 'Room not available for selected dates',
      ),
    );
  }

  Future<bool> createBooking() async {
    if (!state.isValid) return false;

    final authState = _ref.read(authStateProvider);
    if (authState.user == null) {
      state = state.copyWith(error: 'Please login to continue');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final booking = BookingModel(
      id: const Uuid().v4(),
      roomId: state.selectedRoom!.id,
      userId: authState.user!.id,
      checkIn: state.checkIn!,
      checkOut: state.checkOut!,
      totalPrice: state.totalPrice,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
      roomName: state.selectedRoom!.name,
      roomImageUrl: state.selectedRoom!.imageUrl,
    );

    final result = await _repository.createBooking(booking);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (createdBooking) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          createdBooking: createdBooking,
        );
        _ref.invalidate(userBookingsProvider);
        return true;
      },
    );
  }

  void reset() {
    state = const BookingFormState();
  }
}

final bookingLocalDataSourceProvider = Provider<BookingLocalDataSource>((ref) {
  return BookingLocalDataSourceImpl(ref.watch(hiveProvider));
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(ref.watch(bookingLocalDataSourceProvider));
});

final bookingFormProvider =
    StateNotifierProvider<BookingFormNotifier, BookingFormState>((ref) {
  return BookingFormNotifier(
    ref.watch(bookingRepositoryProvider),
    ref,
  );
});

final userBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(bookingRepositoryProvider);

  if (authState.user == null) return [];

  final result = await repository.getBookingsByUser(authState.user!.id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (bookings) => bookings,
  );
});
