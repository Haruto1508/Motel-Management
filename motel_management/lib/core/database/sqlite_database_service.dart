import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Dịch vụ quản lý SQLite Database cục bộ phục vụ Offline-first
class SqliteDatabaseService {
  static const String _dbName = 'motel_offline.db';
  static const int _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase(
        _dbName,
        options: OpenDatabaseOptions(
          version: _dbVersion,
          onCreate: (db, version) async {
            await _createTables(db);
          },
        ),
      );
    }

    // Khởi tạo ffi databaseFactory cho Desktop (Windows, macOS, Linux)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // 1. Bảng lưu cache danh sách phòng
    await db.execute('''
      CREATE TABLE cached_rooms (
            id TEXT PRIMARY KEY,
            roomCode TEXT NOT NULL,
            name TEXT NOT NULL,
            floor INTEGER NOT NULL,
            area REAL NOT NULL,
            monthlyRent REAL NOT NULL,
            capacity INTEGER NOT NULL,
            status TEXT NOT NULL,
            description TEXT,
            currentOccupancy INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT,
            updatedAt TEXT,
            cachedAt TEXT NOT NULL
          )
        ''');

        // 2. Bảng lưu cache chi tiết phòng dạng JSON để hiển thị offline đầy đủ
        await db.execute('''
          CREATE TABLE cached_room_details (
            roomId TEXT PRIMARY KEY,
            jsonData TEXT NOT NULL,
            cachedAt TEXT NOT NULL
          )
        ''');

        // 3. Bảng lưu cache danh sách khách thuê
        await db.execute('''
          CREATE TABLE IF NOT EXISTS cached_tenants (
            id TEXT PRIMARY KEY,
            fullName TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT,
            identityNumber TEXT,
            dateOfBirth TEXT,
            gender TEXT,
            hometown TEXT,
            occupation TEXT,
            emergencyContact TEXT,
            emergencyPhone TEXT,
            note TEXT,
            status TEXT NOT NULL DEFAULT 'ACTIVE',
            currentRoomCode TEXT,
            currentRoomId TEXT,
            createdAt TEXT,
            updatedAt TEXT,
            cachedAt TEXT NOT NULL
          )
        ''');

        // 4. Bảng lưu cache danh sách hợp đồng
        await db.execute('''
          CREATE TABLE IF NOT EXISTS cached_contracts (
            id TEXT PRIMARY KEY,
            contractNumber TEXT NOT NULL,
            roomId TEXT NOT NULL,
            roomCode TEXT,
            primaryTenantId TEXT NOT NULL,
            primaryTenantName TEXT,
            primaryTenantPhone TEXT,
            startDate TEXT NOT NULL,
            endDate TEXT NOT NULL,
            monthlyRent REAL NOT NULL,
            depositAmount REAL NOT NULL,
            paymentDueDay INTEGER NOT NULL DEFAULT 5,
            status TEXT NOT NULL DEFAULT 'ACTIVE',
            terms TEXT,
            createdAt TEXT,
            updatedAt TEXT,
            cachedAt TEXT NOT NULL
          )
        ''');

        // 5. Bảng lưu cache lịch sử ghi số điện nước
        await db.execute('''
          CREATE TABLE IF NOT EXISTS cached_utility_readings (
            id TEXT PRIMARY KEY,
            roomId TEXT NOT NULL,
            roomCode TEXT,
            billingMonth TEXT NOT NULL,
            readingDate TEXT NOT NULL,
            previousElectricity REAL,
            currentElectricity REAL NOT NULL,
            electricityPrice REAL NOT NULL,
            previousWater REAL,
            currentWater REAL NOT NULL,
            waterPrice REAL NOT NULL,
            waterCalcMethod TEXT NOT NULL DEFAULT 'METER',
            note TEXT,
            createdAt TEXT,
            cachedAt TEXT NOT NULL
          )
        ''');

        // 6. Bảng lưu cache cấu hình dịch vụ (Internet, Rác, Đơn giá điện nước)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS cached_service_configs (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            unitPrice REAL NOT NULL,
            unitName TEXT NOT NULL,
            isActive INTEGER NOT NULL DEFAULT 1,
            cachedAt TEXT NOT NULL
          )
        ''');

        // 7. Bảng lưu cache danh sách hóa đơn
        await db.execute('''
          CREATE TABLE IF NOT EXISTS cached_invoices (
            id TEXT PRIMARY KEY,
            invoiceNumber TEXT NOT NULL,
            roomId TEXT NOT NULL,
            roomCode TEXT,
            tenantId TEXT NOT NULL,
            primaryTenantName TEXT,
            primaryTenantPhone TEXT,
            billingMonth TEXT NOT NULL,
            rentAmount REAL NOT NULL,
            electricityAmount REAL NOT NULL DEFAULT 0,
            waterAmount REAL NOT NULL DEFAULT 0,
            internetAmount REAL NOT NULL DEFAULT 0,
            otherAmount REAL NOT NULL DEFAULT 0,
            discountAmount REAL NOT NULL DEFAULT 0,
            totalAmount REAL NOT NULL,
            paidAmount REAL NOT NULL DEFAULT 0,
            dueDate TEXT NOT NULL,
            paidAt TEXT,
            status TEXT NOT NULL DEFAULT 'UNPAID',
            note TEXT,
            createdAt TEXT,
            cachedAt TEXT NOT NULL
          )
        ''');

        // 8. Bảng lưu cache lịch sử thanh toán
        await db.execute('''
          CREATE TABLE IF NOT EXISTS cached_payments (
            id TEXT PRIMARY KEY,
            invoiceId TEXT NOT NULL,
            amount REAL NOT NULL,
            paymentMethod TEXT NOT NULL,
            paymentDate TEXT NOT NULL,
            transactionReference TEXT,
            note TEXT,
            cachedAt TEXT NOT NULL
          )
        ''');

        // 9. Hàng đợi đồng bộ thao tác khi offline (Sync Queue)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS offline_sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT NOT NULL,       -- CREATE, UPDATE, DELETE
            entityType TEXT NOT NULL,   -- ROOM, TENANT, CONTRACT, UTILITY, INVOICE, PAYMENT
            entityId TEXT,
            payload TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'PENDING'
          )
        ''');
  }

  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('cached_rooms');
    await db.delete('cached_room_details');
    await db.delete('cached_tenants');
    await db.delete('cached_contracts');
    await db.delete('cached_utility_readings');
    await db.delete('cached_service_configs');
    await db.delete('cached_invoices');
    await db.delete('cached_payments');
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
