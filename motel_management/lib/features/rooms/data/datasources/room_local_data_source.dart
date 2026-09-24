import 'dart:convert';
import 'package:rental_management/core/database/sqlite_database_service.dart';
import 'package:rental_management/features/rooms/data/models/room_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class RoomLocalDataSource {
  Future<void> cacheRooms(List<RoomModel> rooms);
  Future<List<RoomModel>> getCachedRooms({String? query, String? status, int? floor});
  Future<void> cacheRoomDetail(String roomId, RoomDetailModel detail);
  Future<RoomDetailModel?> getCachedRoomDetail(String roomId);
  Future<void> deleteCachedRoom(String roomId);
  Future<void> enqueueOfflineAction({
    required String action,
    required String entityType,
    String? entityId,
    required Map<String, dynamic> payload,
  });
}

class RoomLocalDataSourceImpl implements RoomLocalDataSource {
  final SqliteDatabaseService _dbService;

  RoomLocalDataSourceImpl(this._dbService);

  @override
  Future<void> cacheRooms(List<RoomModel> rooms) async {
    final db = await _dbService.database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (final room in rooms) {
      batch.insert(
        'cached_rooms',
        {
          'id': room.id,
          'roomCode': room.roomCode,
          'name': room.name,
          'floor': room.floor,
          'area': room.area,
          'monthlyRent': room.monthlyRent,
          'capacity': room.capacity,
          'status': room.status,
          'description': room.description,
          'currentOccupancy': room.currentOccupancy,
          'createdAt': room.createdAt,
          'updatedAt': room.updatedAt,
          'cachedAt': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<RoomModel>> getCachedRooms({String? query, String? status, int? floor}) async {
    final db = await _dbService.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (query != null && query.trim().isNotEmpty) {
      whereClauses.add('(roomCode LIKE ? OR name LIKE ?)');
      whereArgs.add('%${query.trim()}%');
      whereArgs.add('%${query.trim()}%');
    }

    if (status != null && status.trim().isNotEmpty) {
      whereClauses.add('status = ?');
      whereArgs.add(status.trim().toUpperCase());
    }

    if (floor != null) {
      whereClauses.add('floor = ?');
      whereArgs.add(floor);
    }

    final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final rows = await db.query(
      'cached_rooms',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'floor ASC, roomCode ASC',
    );

    return rows.map((row) {
      return RoomModel(
        id: row['id'] as String,
        roomCode: row['roomCode'] as String,
        name: row['name'] as String,
        floor: row['floor'] as int,
        area: (row['area'] as num).toDouble(),
        monthlyRent: (row['monthlyRent'] as num).toDouble(),
        capacity: row['capacity'] as int,
        status: row['status'] as String,
        description: row['description'] as String?,
        currentOccupancy: (row['currentOccupancy'] as int?) ?? 0,
        createdAt: row['createdAt'] as String?,
        updatedAt: row['updatedAt'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> cacheRoomDetail(String roomId, RoomDetailModel detail) async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();

    await db.insert(
      'cached_room_details',
      {
        'roomId': roomId,
        'jsonData': jsonEncode(detail.toJson()),
        'cachedAt': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<RoomDetailModel?> getCachedRoomDetail(String roomId) async {
    final db = await _dbService.database;
    final rows = await db.query(
      'cached_room_details',
      where: 'roomId = ?',
      whereArgs: [roomId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final jsonData = rows.first['jsonData'] as String;
    final map = jsonDecode(jsonData) as Map<String, dynamic>;
    return RoomDetailModel.fromJson(map);
  }

  @override
  Future<void> deleteCachedRoom(String roomId) async {
    final db = await _dbService.database;
    await db.delete('cached_rooms', where: 'id = ?', whereArgs: [roomId]);
    await db.delete('cached_room_details', where: 'roomId = ?', whereArgs: [roomId]);
  }

  @override
  Future<void> enqueueOfflineAction({
    required String action,
    required String entityType,
    String? entityId,
    required Map<String, dynamic> payload,
  }) async {
    final db = await _dbService.database;
    await db.insert('offline_sync_queue', {
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'payload': jsonEncode(payload),
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'PENDING',
    });
  }
}
