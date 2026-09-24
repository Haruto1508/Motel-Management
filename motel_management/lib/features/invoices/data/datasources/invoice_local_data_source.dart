import 'package:rental_management/core/database/sqlite_database_service.dart';
import 'package:rental_management/features/invoices/data/models/invoice_model.dart';
import 'package:rental_management/features/invoices/data/models/payment_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class InvoiceLocalDataSource {
  Future<List<InvoiceModel>> getCachedInvoices({
    String? roomId,
    String? billingMonth,
    String? status,
    String? query,
  });

  Future<InvoiceModel?> getCachedInvoiceById(String id);

  Future<void> cacheInvoices(List<InvoiceModel> invoices);

  Future<void> saveInvoice(InvoiceModel invoice);

  Future<void> deleteCachedInvoice(String id);

  Future<List<PaymentModel>> getCachedPaymentsByInvoiceId(String invoiceId);

  Future<void> savePayment(PaymentModel payment);
}

class InvoiceLocalDataSourceImpl implements InvoiceLocalDataSource {
  final SqliteDatabaseService _dbService;

  InvoiceLocalDataSourceImpl(this._dbService);

  @override
  Future<List<InvoiceModel>> getCachedInvoices({
    String? roomId,
    String? billingMonth,
    String? status,
    String? query,
  }) async {
    final db = await _dbService.database;
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

    if (status != null && status.isNotEmpty) {
      whereClauses.add('status = ?');
      whereArgs.add(status.toUpperCase());
    }

    if (query != null && query.trim().isNotEmpty) {
      whereClauses.add('(invoiceNumber LIKE ? OR roomCode LIKE ? OR primaryTenantName LIKE ?)');
      final pattern = '%${query.trim()}%';
      whereArgs.addAll([pattern, pattern, pattern]);
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final results = await db.query(
      'cached_invoices',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'createdAt DESC',
    );

    final invoices = <InvoiceModel>[];
    for (final row in results) {
      final payments = await getCachedPaymentsByInvoiceId(row['id'] as String);
      final map = Map<String, dynamic>.from(row);
      map['payments'] = payments.map((p) => p.toJson()).toList();
      invoices.add(InvoiceModel.fromJson(map));
    }

    return invoices;
  }

  @override
  Future<InvoiceModel?> getCachedInvoiceById(String id) async {
    final db = await _dbService.database;
    final results = await db.query(
      'cached_invoices',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    final payments = await getCachedPaymentsByInvoiceId(id);
    final map = Map<String, dynamic>.from(results.first);
    map['payments'] = payments.map((p) => p.toJson()).toList();
    return InvoiceModel.fromJson(map);
  }

  @override
  Future<void> cacheInvoices(List<InvoiceModel> invoices) async {
    final db = await _dbService.database;
    final batch = db.batch();

    for (final inv in invoices) {
      final json = inv.toJson();
      json.remove('payments');
      json['cachedAt'] = DateTime.now().toIso8601String();

      batch.insert(
        'cached_invoices',
        json,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final p in inv.payments) {
        final pJson = p.toJson();
        pJson['cachedAt'] = DateTime.now().toIso8601String();
        batch.insert(
          'cached_payments',
          pJson,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> saveInvoice(InvoiceModel invoice) async {
    final db = await _dbService.database;
    final json = invoice.toJson();
    json.remove('payments');
    json['cachedAt'] = DateTime.now().toIso8601String();

    await db.insert(
      'cached_invoices',
      json,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (final p in invoice.payments) {
      await savePayment(p);
    }
  }

  @override
  Future<void> deleteCachedInvoice(String id) async {
    final db = await _dbService.database;
    await db.delete('cached_invoices', where: 'id = ?', whereArgs: [id]);
    await db.delete('cached_payments', where: 'invoiceId = ?', whereArgs: [id]);
  }

  @override
  Future<List<PaymentModel>> getCachedPaymentsByInvoiceId(String invoiceId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'cached_payments',
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
      orderBy: 'paymentDate DESC',
    );

    return results.map((row) => PaymentModel.fromJson(row)).toList();
  }

  @override
  Future<void> savePayment(PaymentModel payment) async {
    final db = await _dbService.database;
    final json = payment.toJson();
    json['cachedAt'] = DateTime.now().toIso8601String();

    await db.insert(
      'cached_payments',
      json,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
