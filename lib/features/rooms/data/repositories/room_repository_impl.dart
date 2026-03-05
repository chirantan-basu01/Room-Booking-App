import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/models/room_model.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_local_datasource.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomLocalDataSource _localDataSource;

  RoomRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<RoomModel>>> getRooms() async {
    try {
      final rooms = await _localDataSource.getRooms();
      return Right(rooms);
    } catch (e) {
      return Left(RoomFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoomModel>> getRoomById(String id) async {
    try {
      final room = await _localDataSource.getRoomById(id);
      return Right(room);
    } catch (e) {
      return Left(RoomFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RoomModel>>> searchRooms(String query) async {
    try {
      final rooms = await _localDataSource.searchRooms(query);
      return Right(rooms);
    } catch (e) {
      return Left(RoomFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RoomModel>>> filterRoomsByType(
    RoomType type,
  ) async {
    try {
      final rooms = await _localDataSource.filterRoomsByType(type);
      return Right(rooms);
    } catch (e) {
      return Left(RoomFailure(e.toString()));
    }
  }
}
