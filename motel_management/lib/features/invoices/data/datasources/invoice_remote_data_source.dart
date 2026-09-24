import 'package:rental_management/core/constants/app_constants.dart';
import 'package:rental_management/core/network/api_client.dart';
import 'package:rental_management/features/invoices/data/models/invoice_model.dart';
import 'package:rental_management/features/invoices/data/models/payment_model.dart';

abstract class InvoiceRemoteDataSource {
  Future<List<InvoiceModel>> getInvoices({
    String? roomId,
    String? billingMonth,
    String? status,
    String? query,
  });

  Future<InvoiceModel> getInvoiceById(String id);

  Future<InvoiceModel> createInvoice(Map<String, dynamic> data);

  Future<InvoiceModel> updateInvoice(String id, Map<String, dynamic> data);

  Future<void> cancelInvoice(String id);

  Future<PaymentModel> recordPayment(Map<String, dynamic> data);

  Future<List<PaymentModel>> getPaymentsByInvoiceId(String invoiceId);
}

class InvoiceRemoteDataSourceImpl implements InvoiceRemoteDataSource {
  final ApiClient _apiClient;

  InvoiceRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<InvoiceModel>> getInvoices({
    String? roomId,
    String? billingMonth,
    String? status,
    String? query,
  }) async {
    final queryParams = <String, dynamic>{};
    if (roomId != null && roomId.isNotEmpty) queryParams['roomId'] = roomId;
    if (billingMonth != null && billingMonth.isNotEmpty) queryParams['billingMonth'] = billingMonth;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (query != null && query.isNotEmpty) queryParams['query'] = query;

    final response = await _apiClient.get(
      AppConstants.endpointInvoices,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final rawData = response.data;
    final List<dynamic> list = rawData is Map<String, dynamic>
        ? (rawData['data'] as List<dynamic>? ?? [])
        : (rawData is List ? rawData : []);

    return list
        .map((item) => InvoiceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InvoiceModel> getInvoiceById(String id) async {
    final response = await _apiClient.get('${AppConstants.endpointInvoices}/$id');

    final rawData = response.data;
    final Map<String, dynamic> data = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return InvoiceModel.fromJson(data);
  }

  @override
  Future<InvoiceModel> createInvoice(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      AppConstants.endpointInvoices,
      data: data,
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return InvoiceModel.fromJson(resData);
  }

  @override
  Future<InvoiceModel> updateInvoice(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${AppConstants.endpointInvoices}/$id',
      data: data,
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return InvoiceModel.fromJson(resData);
  }

  @override
  Future<void> cancelInvoice(String id) async {
    await _apiClient.put('${AppConstants.endpointInvoices}/$id/cancel');
  }

  @override
  Future<PaymentModel> recordPayment(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      AppConstants.endpointPayments,
      data: data,
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return PaymentModel.fromJson(resData);
  }

  @override
  Future<List<PaymentModel>> getPaymentsByInvoiceId(String invoiceId) async {
    final response = await _apiClient.get(
      AppConstants.endpointPayments,
      queryParameters: {'invoiceId': invoiceId},
    );

    final rawData = response.data;
    final List<dynamic> list = rawData is Map<String, dynamic>
        ? (rawData['data'] as List<dynamic>? ?? [])
        : (rawData is List ? rawData : []);

    return list
        .map((item) => PaymentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
