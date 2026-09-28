import 'package:rental_management/core/database/sqlite_database_service.dart';
import 'package:rental_management/features/utilities/data/models/service_config_model.dart';
import 'package:rental_management/features/utilities/data/models/utility_reading_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class UtilityLocalDataSource {
  Future<List<UtilityReadingModel>> getCachedReadings({String? roomId, String? billingMonth});

  Future<UtilityReadingModel?> getLatestCachedReading(String roomId);

  Future<void> cacheReadings(List<UtilityReadingModel> readings);

  Future<void> saveReading(UtilityReadingModel reading);

  Future<void> deleteCachedReading(String id);

  Future<List<ServiceConfigModel>> getCachedServices();

  Future<void> cacheServices(List<ServiceConfigModel> services);

  Future<void> saveService(ServiceConfigModel service);
}

class UtilityLocalDataSourceImpl implements UtilityLocalDataSource {
  final SqliteDatabaseService _dbService;

  UtilityLocalDataSourceImpl(this._dbService);

  @override
  Future<List<UtilityReadingModel>> getCachedReadings({String? roomId, String? billingMonth}) async {
    try {
      final db = await _dbService.database;
      if (db == null) return [];
      final whereClauses = <String>[];
      final whereArgs = <dynamic>[];

      if (roomId != null && roomId.isNotEmpty) {
        whereClauses.add('roomId = ?');
        whereArgs.add(roomId);
      }

      if (billingMonth != null && billingMonth.isNotEmpty) {
        whereClauses.add('billingMonth = ?');
        whereArgs.add(billingMonth);
      }

      final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

      final results = await db.query(
        'cached_utility_readings',
        where: whereString,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'readingDate DESC',
      );

      return results.map((row) => UtilityReadingModel.fromJson(row)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<UtilityReadingModel?> getLatestCachedReading(String roomId) async {
    try {
      final db = await _dbService.database;
      if (db == null) return null;
      final results = await db.query(
        'cached_utility_readings',
        where: 'roomId = ?',
        whereArgs: [roomId],
        orderBy: 'readingDate DESC',
        limit: 1,
      );

      if (results.isEmpty) return null;
      return UtilityReadingModel.fromJson(results.first);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheReadings(List<UtilityReadingModel> readings) async {
    try {
      final db = await _dbService.database;
      if (db == null) return;
      final batch = db.batch();

      for (final reading in readings) {
        final json = reading.toJson();
        json['cachedAt'] = DateTime.now().toIso8601String();
        batch.insert(
          'cached_utility_readings',
          json,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (_) {}
  }

  @override
  Future<void> saveReading(UtilityReadingModel reading) async {
    try {
      final db = await _dbService.database;
      if (db == null) return;
      final json = reading.toJson();
      json['cachedAt'] = DateTime.now().toIso8601String();

      await db.insert(
        'cached_utility_readings',
        json,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  @override
  Future<void> deleteCachedReading(String id) async {
    try {
      final db = await _dbService.database;
      if (db == null) return;
      await db.delete(
        'cached_utility_readings',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {}
  }

  @override
  Future<List<ServiceConfigModel>> getCachedServices() async {
    final defaultServices = [
      const ServiceConfigModel(id: 'svc-elec', name: 'Điện sinh hoạt', type: 'METER', unitPrice: 3500, unitName: 'kWh'),
      const ServiceConfigModel(id: 'svc-water', name: 'Nước sinh hoạt', type: 'METER', unitPrice: 25000, unitName: 'm³'),
      const ServiceConfigModel(id: 'svc-net', name: 'Internet WiFi', type: 'FIXED_ROOM', unitPrice: 100000, unitName: 'phòng/tháng'),
      const ServiceConfigModel(id: 'svc-trash', name: 'Rác sinh hoạt & Vệ sinh', type: 'FIXED_ROOM', unitPrice: 30000, unitName: 'phòng/tháng'),
    ];

    try {
      final db = await _dbService.database;
      if (db == null) return defaultServices;
      final results = await db.query(
        'cached_service_configs',
        orderBy: 'name ASC',
      );

      if (results.isEmpty) {
        await cacheServices(defaultServices);
        return defaultServices;
      }

      return results.map((row) => ServiceConfigModel.fromJson(row)).toList();
    } catch (_) {
      return defaultServices;
    }
  }

  @override
  Future<void> cacheServices(List<ServiceConfigModel> services) async {
    try {
      final db = await _dbService.database;
      if (db == null) return;
      final batch = db.batch();

      for (final svc in services) {
        final json = svc.toJson();
        json['cachedAt'] = DateTime.now().toIso8601String();
        batch.insert(
          'cached_service_configs',
          json,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (_) {}
  }

  @override
  Future<void> saveService(ServiceConfigModel service) async {
    try {
      final db = await _dbService.database;
      if (db == null) return;
      final json = service.toJson();
      json['cachedAt'] = DateTime.now().toIso8601String();

      await db.insert(
        'cached_service_configs',
        json,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }
}
