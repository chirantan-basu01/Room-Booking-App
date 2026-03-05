import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/room_model.dart';

abstract class RoomRepository {
  Future<Either<Failure, List<RoomModel>>> getRooms();
  Future<Either<Failure, RoomModel>> getRoomById(String id);
  Future<Either<Failure, List<RoomModel>>> searchRooms(String query);
  Future<Either<Failure, List<RoomModel>>> filterRoomsByType(RoomType type);
}
