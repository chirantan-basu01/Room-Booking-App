import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/room_model.dart';

abstract class RoomLocalDataSource {
  Future<List<RoomModel>> getRooms();
  Future<RoomModel> getRoomById(String id);
  Future<List<RoomModel>> searchRooms(String query);
  Future<List<RoomModel>> filterRoomsByType(RoomType type);
}

class RoomLocalDataSourceImpl implements RoomLocalDataSource {
  List<RoomModel>? _cachedRooms;

  Future<List<RoomModel>> _loadRooms() async {
    if (_cachedRooms != null) return _cachedRooms!;

    final jsonString = await rootBundle.loadString('assets/mock/rooms.json');
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    final roomsList = jsonData['rooms'] as List;

    _cachedRooms = roomsList
        .map((json) => RoomModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return _cachedRooms!;
  }

  @override
  Future<List<RoomModel>> getRooms() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _loadRooms();
  }

  @override
  Future<RoomModel> getRoomById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final rooms = await _loadRooms();
    final room = rooms.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Room not found'),
    );
    return room;
  }

  @override
  Future<List<RoomModel>> searchRooms(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final rooms = await _loadRooms();
    final lowerQuery = query.toLowerCase();
    return rooms.where((room) {
      return room.name.toLowerCase().contains(lowerQuery) ||
          room.description.toLowerCase().contains(lowerQuery) ||
          room.amenities.any((a) => a.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  @override
  Future<List<RoomModel>> filterRoomsByType(RoomType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final rooms = await _loadRooms();
    return rooms.where((room) => room.type == type).toList();
  }
}