import 'package:rental_management/core/database/sqlite_database_service.dart';
import 'package:rental_management/features/contracts/data/models/contract_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class ContractLocalDataSource {
  Future<void> cacheContracts(List<ContractModel> contracts);
  Future<List<ContractModel>> getCachedContracts({String? query, String? status});
  Future<ContractModel?> getCachedContractById(String id);
  Future<void> deleteCachedContract(String id);
}

class ContractLocalDataSourceImpl implements ContractLocalDataSource {
  final SqliteDatabaseService _dbService;

  ContractLocalDataSourceImpl(this._dbService);

  @override
  Future<void> cacheContracts(List<ContractModel> contracts) async {
    final db = await _dbService.database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (final contract in contracts) {
      batch.insert(
        'cached_contracts',
        {
          'id': contract.id,
          'contractNumber': contract.contractNumber,
          'roomId': contract.roomId,
          'roomCode': contract.roomCode,
          'primaryTenantId': contract.primaryTenantId,
          'primaryTenantName': contract.primaryTenantName,
          'primaryTenantPhone': contract.primaryTenantPhone,
          'startDate': contract.startDate,
          'endDate': contract.endDate,
          'monthlyRent': contract.monthlyRent,
          'depositAmount': contract.depositAmount,
          'paymentDueDay': contract.paymentDueDay,
          'status': contract.status,
          'terms': contract.terms,
          'createdAt': contract.createdAt,
          'updatedAt': contract.updatedAt,
          'cachedAt': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<ContractModel>> getCachedContracts({String? query, String? status}) async {
    final db = await _dbService.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (query != null && query.trim().isNotEmpty) {
      whereClauses.add('(contractNumber LIKE ? OR roomCode LIKE ? OR primaryTenantName LIKE ?)');
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
      'cached_contracts',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'startDate DESC',
    );

    return rows.map((row) {
      return ContractModel(
        id: row['id'] as String,
        contractNumber: row['contractNumber'] as String,
        roomId: row['roomId'] as String,
        roomCode: row['roomCode'] as String?,
        primaryTenantId: row['primaryTenantId'] as String,
        primaryTenantName: row['primaryTenantName'] as String?,
        primaryTenantPhone: row['primaryTenantPhone'] as String?,
        startDate: row['startDate'] as String,
        endDate: row['endDate'] as String,
        monthlyRent: (row['monthlyRent'] as num).toDouble(),
        depositAmount: (row['depositAmount'] as num).toDouble(),
        paymentDueDay: row['paymentDueDay'] as int? ?? 5,
        status: row['status'] as String? ?? 'ACTIVE',
        terms: row['terms'] as String?,
        createdAt: row['createdAt'] as String?,
        updatedAt: row['updatedAt'] as String?,
      );
    }).toList();
  }

  @override
  Future<ContractModel?> getCachedContractById(String id) async {
    final db = await _dbService.database;
    final rows = await db.query(
      'cached_contracts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final row = rows.first;
    return ContractModel(
      id: row['id'] as String,
      contractNumber: row['contractNumber'] as String,
      roomId: row['roomId'] as String,
      roomCode: row['roomCode'] as String?,
      primaryTenantId: row['primaryTenantId'] as String,
      primaryTenantName: row['primaryTenantName'] as String?,
      primaryTenantPhone: row['primaryTenantPhone'] as String?,
      startDate: row['startDate'] as String,
      endDate: row['endDate'] as String,
      monthlyRent: (row['monthlyRent'] as num).toDouble(),
      depositAmount: (row['depositAmount'] as num).toDouble(),
      paymentDueDay: row['paymentDueDay'] as int? ?? 5,
      status: row['status'] as String? ?? 'ACTIVE',
      terms: row['terms'] as String?,
      createdAt: row['createdAt'] as String?,
      updatedAt: row['updatedAt'] as String?,
    );
  }

  @override
  Future<void> deleteCachedContract(String id) async {
    final db = await _dbService.database;
    await db.delete('cached_contracts', where: 'id = ?', whereArgs: [id]);
  }
}
