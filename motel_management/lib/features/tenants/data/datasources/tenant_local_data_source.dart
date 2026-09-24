import 'package:rental_management/core/database/sqlite_database_service.dart';
import 'package:rental_management/features/tenants/data/models/tenant_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class TenantLocalDataSource {
  Future<void> cacheTenants(List<TenantModel> tenants);
  Future<List<TenantModel>> getCachedTenants({String? query, String? status});
  Future<TenantModel?> getCachedTenantById(String id);
  Future<void> deleteCachedTenant(String id);
}

class TenantLocalDataSourceImpl implements TenantLocalDataSource {
  final SqliteDatabaseService _dbService;

  TenantLocalDataSourceImpl(this._dbService);

  @override
  Future<void> cacheTenants(List<TenantModel> tenants) async {
    final db = await _dbService.database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (final tenant in tenants) {
      batch.insert(
        'cached_tenants',
        {
          'id': tenant.id,
          'fullName': tenant.fullName,
          'phone': tenant.phone,
          'email': tenant.email,
          'identityNumber': tenant.identityNumber,
          'dateOfBirth': tenant.dateOfBirth,
          'gender': tenant.gender,
          'hometown': tenant.hometown,
          'occupation': tenant.occupation,
          'emergencyContact': tenant.emergencyContact,
          'emergencyPhone': tenant.emergencyPhone,
          'note': tenant.note,
          'status': tenant.status,
          'currentRoomCode': tenant.currentRoomCode,
          'currentRoomId': tenant.currentRoomId,
          'createdAt': tenant.createdAt,
          'updatedAt': tenant.updatedAt,
          'cachedAt': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<TenantModel>> getCachedTenants({String? query, String? status}) async {
    final db = await _dbService.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (query != null && query.trim().isNotEmpty) {
      whereClauses.add('(fullName LIKE ? OR phone LIKE ? OR identityNumber LIKE ?)');
      whereArgs.add('%${query.trim()}%');
      whereArgs.add('%${query.trim()}%');
      whereArgs.add('%${query.trim()}%');
    }

    if (status != null && status.trim().isNotEmpty) {
      whereClauses.add('status = ?');
      whereArgs.add(status.trim().toUpperCase());
    }

    final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final rows = await db.query(
      'cached_tenants',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'fullName ASC',
    );

    return rows.map((row) {
      return TenantModel(
        id: row['id'] as String,
        fullName: row['fullName'] as String,
        phone: row['phone'] as String,
        email: row['email'] as String?,
        identityNumber: row['identityNumber'] as String?,
        dateOfBirth: row['dateOfBirth'] as String?,
        gender: row['gender'] as String?,
        hometown: row['hometown'] as String?,
        occupation: row['occupation'] as String?,
        emergencyContact: row['emergencyContact'] as String?,
        emergencyPhone: row['emergencyPhone'] as String?,
        note: row['note'] as String?,
        status: row['status'] as String? ?? 'ACTIVE',
        currentRoomCode: row['currentRoomCode'] as String?,
        currentRoomId: row['currentRoomId'] as String?,
        createdAt: row['createdAt'] as String?,
        updatedAt: row['updatedAt'] as String?,
      );
    }).toList();
  }

  @override
  Future<TenantModel?> getCachedTenantById(String id) async {
    final db = await _dbService.database;
    final rows = await db.query(
      'cached_tenants',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final row = rows.first;
    return TenantModel(
      id: row['id'] as String,
      fullName: row['fullName'] as String,
      phone: row['phone'] as String,
      email: row['email'] as String?,
      identityNumber: row['identityNumber'] as String?,
      dateOfBirth: row['dateOfBirth'] as String?,
      gender: row['gender'] as String?,
      hometown: row['hometown'] as String?,
      occupation: row['occupation'] as String?,
      emergencyContact: row['emergencyContact'] as String?,
      emergencyPhone: row['emergencyPhone'] as String?,
      note: row['note'] as String?,
      status: row['status'] as String? ?? 'ACTIVE',
      currentRoomCode: row['currentRoomCode'] as String?,
      currentRoomId: row['currentRoomId'] as String?,
      createdAt: row['createdAt'] as String?,
      updatedAt: row['updatedAt'] as String?,
    );
  }

  @override
  Future<void> deleteCachedTenant(String id) async {
    final db = await _dbService.database;
    await db.delete('cached_tenants', where: 'id = ?', whereArgs: [id]);
  }
}
