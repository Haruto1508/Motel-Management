import 'package:rental_management/features/invoices/data/datasources/invoice_local_data_source.dart';
import 'package:rental_management/features/invoices/data/datasources/invoice_remote_data_source.dart';
import 'package:rental_management/features/invoices/data/models/invoice_model.dart';
import 'package:rental_management/features/invoices/data/models/payment_model.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_entity.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_status.dart';
import 'package:rental_management/features/invoices/domain/entities/payment_entity.dart';
import 'package:rental_management/features/invoices/domain/repositories/invoice_repository.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource remoteDataSource;
  final InvoiceLocalDataSource localDataSource;

  InvoiceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<InvoiceEntity>> getInvoices({
    String? roomId,
    String? billingMonth,
    InvoiceStatus? status,
    String? query,
  }) async {
    try {
      final remoteList = await remoteDataSource.getInvoices(
        roomId: roomId,
        billingMonth: billingMonth,
        status: status?.code,
        query: query,
      );
      await localDataSource.cacheInvoices(remoteList);
      return remoteList.map((m) => m.toEntity()).toList();
    } catch (_) {
      final cachedList = await localDataSource.getCachedInvoices(
        roomId: roomId,
        billingMonth: billingMonth,
        status: status?.code,
        query: query,
      );
      return cachedList.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Future<InvoiceEntity> getInvoiceById(String id) async {
    try {
      final remote = await remoteDataSource.getInvoiceById(id);
      await localDataSource.saveInvoice(remote);
      return remote.toEntity();
    } catch (_) {
      final cached = await localDataSource.getCachedInvoiceById(id);
      if (cached != null) return cached.toEntity();
      throw Exception('Không tìm thấy hóa đơn');
    }
  }

  @override
  Future<InvoiceEntity> createInvoice(Map<String, dynamic> data) async {
    try {
      final model = await remoteDataSource.createInvoice(data);
      await localDataSource.saveInvoice(model);
      return model.toEntity();
    } catch (_) {
      final offlineId = 'offline_inv_${DateTime.now().millisecondsSinceEpoch}';
      final offlineMap = Map<String, dynamic>.from(data);
      offlineMap['id'] = offlineId;
      offlineMap['createdAt'] = DateTime.now().toIso8601String();

      final model = InvoiceModel.fromJson(offlineMap);
      await localDataSource.saveInvoice(model);
      return model.toEntity();
    }
  }

  @override
  Future<InvoiceEntity> updateInvoice(String id, Map<String, dynamic> data) async {
    try {
      final model = await remoteDataSource.updateInvoice(id, data);
      await localDataSource.saveInvoice(model);
      return model.toEntity();
    } catch (_) {
      final offlineMap = Map<String, dynamic>.from(data);
      offlineMap['id'] = id;
      final model = InvoiceModel.fromJson(offlineMap);
      await localDataSource.saveInvoice(model);
      return model.toEntity();
    }
  }

  @override
  Future<void> cancelInvoice(String id) async {
    try {
      await remoteDataSource.cancelInvoice(id);
    } catch (_) {}

    final cached = await localDataSource.getCachedInvoiceById(id);
    if (cached != null) {
      final updatedMap = cached.toJson();
      updatedMap['status'] = 'CANCELLED';
      await localDataSource.saveInvoice(InvoiceModel.fromJson(updatedMap));
    }
  }

  @override
  Future<PaymentEntity> recordPayment(Map<String, dynamic> data) async {
    try {
      final model = await remoteDataSource.recordPayment(data);
      await localDataSource.savePayment(model);
      await _updateCachedInvoiceAfterPayment(model.invoiceId, model.amount);
      return model.toEntity();
    } catch (_) {
      final offlineId = 'offline_pay_${DateTime.now().millisecondsSinceEpoch}';
      final offlineMap = Map<String, dynamic>.from(data);
      offlineMap['id'] = offlineId;

      final model = PaymentModel.fromJson(offlineMap);
      await localDataSource.savePayment(model);
      await _updateCachedInvoiceAfterPayment(model.invoiceId, model.amount);
      return model.toEntity();
    }
  }

  Future<void> _updateCachedInvoiceAfterPayment(String invoiceId, double paymentAmount) async {
    final cached = await localDataSource.getCachedInvoiceById(invoiceId);
    if (cached != null) {
      final newPaidAmount = cached.paidAmount + paymentAmount;
      String newStatus = cached.status;
      if (newPaidAmount >= cached.totalAmount) {
        newStatus = 'PAID';
      } else if (newPaidAmount > 0) {
        newStatus = 'PARTIALLY_PAID';
      }

      final updatedMap = cached.toJson();
      updatedMap['paidAmount'] = newPaidAmount;
      updatedMap['status'] = newStatus;
      if (newStatus == 'PAID') {
        updatedMap['paidAt'] = DateTime.now().toIso8601String();
      }

      await localDataSource.saveInvoice(InvoiceModel.fromJson(updatedMap));
    }
  }

  @override
  Future<List<PaymentEntity>> getPaymentsByInvoiceId(String invoiceId) async {
    try {
      final remote = await remoteDataSource.getPaymentsByInvoiceId(invoiceId);
      for (final p in remote) {
        await localDataSource.savePayment(p);
      }
      return remote.map((m) => m.toEntity()).toList();
    } catch (_) {
      final cached = await localDataSource.getCachedPaymentsByInvoiceId(invoiceId);
      return cached.map((m) => m.toEntity()).toList();
    }
  }
}
