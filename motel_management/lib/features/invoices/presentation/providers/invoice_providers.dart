import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_providers.dart';
import 'package:rental_management/features/invoices/data/datasources/invoice_local_data_source.dart';
import 'package:rental_management/features/invoices/data/datasources/invoice_remote_data_source.dart';
import 'package:rental_management/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_entity.dart';
import 'package:rental_management/features/invoices/domain/entities/payment_entity.dart';
import 'package:rental_management/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:rental_management/features/invoices/domain/usecases/create_invoice_usecase.dart';
import 'package:rental_management/features/invoices/domain/usecases/get_invoices_usecase.dart';
import 'package:rental_management/features/invoices/domain/usecases/record_payment_usecase.dart';
import 'package:rental_management/features/rooms/presentation/providers/rooms_providers.dart';

final Provider<InvoiceRemoteDataSource> invoiceRemoteDataSourceProvider =
    Provider<InvoiceRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InvoiceRemoteDataSourceImpl(apiClient);
});

final Provider<InvoiceLocalDataSource> invoiceLocalDataSourceProvider =
    Provider<InvoiceLocalDataSource>((ref) {
  final dbService = ref.watch(sqliteDatabaseServiceProvider);
  return InvoiceLocalDataSourceImpl(dbService);
});

final Provider<InvoiceRepository> invoiceRepositoryProvider =
    Provider<InvoiceRepository>((ref) {
  final remote = ref.watch(invoiceRemoteDataSourceProvider);
  final local = ref.watch(invoiceLocalDataSourceProvider);

  return InvoiceRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: local,
  );
});

final Provider<GetInvoicesUseCase> getInvoicesUseCaseProvider =
    Provider<GetInvoicesUseCase>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return GetInvoicesUseCase(repository);
});

final Provider<GetInvoiceByIdUseCase> getInvoiceByIdUseCaseProvider =
    Provider<GetInvoiceByIdUseCase>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return GetInvoiceByIdUseCase(repository);
});

final Provider<CreateInvoiceUseCase> createInvoiceUseCaseProvider =
    Provider<CreateInvoiceUseCase>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return CreateInvoiceUseCase(repository);
});

final Provider<RecordPaymentUseCase> recordPaymentUseCaseProvider =
    Provider<RecordPaymentUseCase>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return RecordPaymentUseCase(repository);
});

final Provider<CancelInvoiceUseCase> cancelInvoiceUseCaseProvider =
    Provider<CancelInvoiceUseCase>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return CancelInvoiceUseCase(repository);
});

final invoiceDetailProvider =
    FutureProvider.family<InvoiceEntity, String>((ref, id) async {
  final useCase = ref.watch(getInvoiceByIdUseCaseProvider);
  return useCase.call(id);
});

final invoicePaymentsProvider =
    FutureProvider.family<List<PaymentEntity>, String>((ref, invoiceId) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getPaymentsByInvoiceId(invoiceId);
});
