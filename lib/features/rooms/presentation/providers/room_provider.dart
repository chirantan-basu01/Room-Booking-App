import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/room_local_datasource.dart';
import '../../data/repositories/room_repository_impl.dart';
import '../../domain/models/room_model.dart';
import '../../domain/repositories/room_repository.dart';

final roomLocalDataSourceProvider = Provider<RoomLocalDataSource>((ref) {
  return RoomLocalDataSourceImpl();
});

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepositoryImpl(ref.watch(roomLocalDataSourceProvider));
});

final roomsProvider = FutureProvider<List<RoomModel>>((ref) async {
  final repository = ref.watch(roomRepositoryProvider);
  final result = await repository.getRooms();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (rooms) => rooms,
  );
});

final roomByIdProvider =
    FutureProvider.family<RoomModel, String>((ref, id) async {
  final repository = ref.watch(roomRepositoryProvider);
  final result = await repository.getRoomById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (room) => room,
  );
});

final selectedRoomTypeProvider = StateProvider<RoomType?>((ref) => null);

final filteredRoomsProvider = FutureProvider<List<RoomModel>>((ref) async {
  final selectedType = ref.watch(selectedRoomTypeProvider);
  final repository = ref.watch(roomRepositoryProvider);

  if (selectedType == null) {
    final result = await repository.getRooms();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (rooms) => rooms,
    );
  }

  final result = await repository.filterRoomsByType(selectedType);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (rooms) => rooms,
  );
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchedRoomsProvider = FutureProvider<List<RoomModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final repository = ref.watch(roomRepositoryProvider);

  if (query.isEmpty) {
    return ref.watch(filteredRoomsProvider.future);
  }

  final result = await repository.searchRooms(query);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (rooms) => rooms,
  );
});
