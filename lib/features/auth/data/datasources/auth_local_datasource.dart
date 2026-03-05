import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> saveUser(UserModel user);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final HiveInterface _hive;
  List<Map<String, dynamic>>? _cachedUsers;

  AuthLocalDataSourceImpl(this._hive);

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    if (_cachedUsers != null) return _cachedUsers!;

    final jsonString = await rootBundle.loadString('assets/mock/users.json');
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    final usersList = jsonData['users'] as List;

    _cachedUsers = usersList.cast<Map<String, dynamic>>();
    return _cachedUsers!;
  }

  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final users = await _loadUsers();
    final userMatch = users.where(
      (u) => u['email'] == email && u['password'] == password,
    );

    if (userMatch.isEmpty) {
      throw Exception('Invalid email or password');
    }

    final userData = userMatch.first;
    final user = UserModel(
      id: userData['id'] as String,
      email: userData['email'] as String,
      name: userData['name'] as String,
      avatarUrl: userData['avatarUrl'] as String?,
    );

    await saveUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    final box = _hive.box(AppConstants.hiveUserBox);
    await box.delete(AppConstants.userKey);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final box = _hive.box(AppConstants.hiveUserBox);
    final userJson = box.get(AppConstants.userKey);

    if (userJson == null) return null;

    final Map<String, dynamic> userData = jsonDecode(userJson);
    return UserModel.fromJson(userData);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final box = _hive.box(AppConstants.hiveUserBox);
    await box.put(AppConstants.userKey, jsonEncode(user.toJson()));
  }
}
