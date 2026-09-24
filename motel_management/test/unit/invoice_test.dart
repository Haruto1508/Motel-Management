import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_entity.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_status.dart';
import 'package:rental_management/features/invoices/domain/entities/payment_entity.dart';
import 'package:rental_management/features/invoices/domain/entities/payment_method.dart';
import 'package:rental_management/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:rental_management/features/invoices/domain/usecases/create_invoice_usecase.dart';
import 'package:rental_management/features/invoices/domain/usecases/get_invoices_usecase.dart';
import 'package:rental_management/features/invoices/domain/usecases/record_payment_usecase.dart';

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

void main() {
  late MockInvoiceRepository mockRepository;
  late GetInvoicesUseCase getInvoicesUseCase;
  late GetInvoiceByIdUseCase getInvoiceByIdUseCase;
  late CreateInvoiceUseCase createInvoiceUseCase;
  late RecordPaymentUseCase recordPaymentUseCase;
  late CancelInvoiceUseCase cancelInvoiceUseCase;

  setUp(() {
    mockRepository = MockInvoiceRepository();
    getInvoicesUseCase = GetInvoicesUseCase(mockRepository);
    getInvoiceByIdUseCase = GetInvoiceByIdUseCase(mockRepository);
    createInvoiceUseCase = CreateInvoiceUseCase(mockRepository);
    recordPaymentUseCase = RecordPaymentUseCase(mockRepository);
    cancelInvoiceUseCase = CancelInvoiceUseCase(mockRepository);
  });

  final tUnpaidInvoice = InvoiceEntity(
    id: 'inv-1',
    invoiceNumber: 'INV-202609-101',
    roomId: 'room-1',
    roomCode: 'P101',
    tenantId: 'tenant-1',
    primaryTenantName: 'Nguyễn Văn A',
    billingMonth: '09/2026',
    rentAmount: 3000000,
    electricityAmount: 150000,
    waterAmount: 75000,
    internetAmount: 100000,
    totalAmount: 3325000,
    paidAmount: 0,
    dueDate: DateTime.now().add(const Duration(days: 5)),
    status: InvoiceStatus.unpaid,
  );

  final tPartiallyPaidInvoice = InvoiceEntity(
    id: 'inv-2',
    invoiceNumber: 'INV-202609-102',
    roomId: 'room-2',
    roomCode: 'P102',
    tenantId: 'tenant-2',
    billingMonth: '09/2026',
    rentAmount: 3500000,
    electricityAmount: 200000,
    totalAmount: 3700000,
    paidAmount: 2000000,
    dueDate: DateTime.now().add(const Duration(days: 3)),
    status: InvoiceStatus.partiallyPaid,
  );

  final tPaidInvoice = InvoiceEntity(
    id: 'inv-3',
    invoiceNumber: 'INV-202609-103',
    roomId: 'room-3',
    roomCode: 'P103',
    tenantId: 'tenant-3',
    billingMonth: '09/2026',
    rentAmount: 2500000,
    totalAmount: 2500000,
    paidAmount: 2500000,
    dueDate: DateTime.now().subtract(const Duration(days: 1)),
    status: InvoiceStatus.paid,
  );

  final tOverdueInvoice = InvoiceEntity(
    id: 'inv-4',
    invoiceNumber: 'INV-202609-104',
    roomId: 'room-4',
    roomCode: 'P104',
    tenantId: 'tenant-4',
    billingMonth: '08/2026',
    rentAmount: 3000000,
    totalAmount: 3000000,
    paidAmount: 0,
    dueDate: DateTime.now().subtract(const Duration(days: 10)),
    status: InvoiceStatus.overdue,
  );

  final tPayment = PaymentEntity(
    id: 'pay-1',
    invoiceId: 'inv-1',
    amount: 1000000,
    paymentMethod: PaymentMethod.bankTransfer,
    paymentDate: DateTime.now(),
    transactionReference: 'FT123456',
  );

  group('InvoiceEntity Financial Logic Tests', () {
    test('Calculates remaining amount correctly', () {
      expect(tUnpaidInvoice.remainingAmount, equals(3325000.0));
      expect(tPartiallyPaidInvoice.remainingAmount, equals(1700000.0));
      expect(tPaidInvoice.remainingAmount, equals(0.0));
    });

    test('Verifies payment status boolean flags', () {
      expect(tUnpaidInvoice.isPaid, isFalse);
      expect(tUnpaidInvoice.isPartiallyPaid, isFalse);
      expect(tUnpaidInvoice.isOverdue, isFalse);

      expect(tPartiallyPaidInvoice.isPaid, isFalse);
      expect(tPartiallyPaidInvoice.isPartiallyPaid, isTrue);

      expect(tPaidInvoice.isPaid, isTrue);
      expect(tPaidInvoice.isOverdue, isFalse);

      expect(tOverdueInvoice.isOverdue, isTrue);
    });

    test('InvoiceStatus.fromString and PaymentMethod.fromString parse correctly', () {
      expect(InvoiceStatus.fromString('UNPAID'), equals(InvoiceStatus.unpaid));
      expect(InvoiceStatus.fromString('PAID'), equals(InvoiceStatus.paid));
      expect(InvoiceStatus.fromString('PARTIALLY_PAID'), equals(InvoiceStatus.partiallyPaid));
      expect(InvoiceStatus.fromString('OVERDUE'), equals(InvoiceStatus.overdue));

      expect(PaymentMethod.fromString('CASH'), equals(PaymentMethod.cash));
      expect(PaymentMethod.fromString('BANK_TRANSFER'), equals(PaymentMethod.bankTransfer));
      expect(PaymentMethod.fromString('E_WALLET'), equals(PaymentMethod.eWallet));
    });
  });

  group('Invoice & Payment UseCases Tests', () {
    test('CreateInvoiceParams calculates totalAmount accurately with discounts', () {
      final params = CreateInvoiceParams(
        invoiceNumber: 'INV-001',
        roomId: 'room-1',
        tenantId: 'tenant-1',
        billingMonth: '09/2026',
        rentAmount: 3000000,
        electricityAmount: 150000,
        waterAmount: 75000,
        internetAmount: 100000,
        discountAmount: 125000,
        dueDate: DateTime.now().add(const Duration(days: 5)),
      );

      // (3000000 + 150000 + 75000 + 100000) - 125000 = 3,200,000
      expect(params.calculatedTotal, equals(3200000.0));
    });

    test('CreateInvoiceUseCase delegates to repository on valid params', () async {
      when(() => mockRepository.createInvoice(any()))
          .thenAnswer((_) async => tUnpaidInvoice);

      final params = CreateInvoiceParams(
        invoiceNumber: 'INV-202609-101',
        roomId: 'room-1',
        tenantId: 'tenant-1',
        billingMonth: '09/2026',
        rentAmount: 3000000,
        electricityAmount: 150000,
        waterAmount: 75000,
        internetAmount: 100000,
        dueDate: DateTime.now().add(const Duration(days: 5)),
      );

      final result = await createInvoiceUseCase.call(params);

      expect(result.id, equals('inv-1'));
      expect(result.totalAmount, equals(3325000.0));
      verify(() => mockRepository.createInvoice(any())).called(1);
    });

    test('RecordPaymentUseCase validates positive amount and records payment', () async {
      when(() => mockRepository.recordPayment(any()))
          .thenAnswer((_) async => tPayment);

      final params = RecordPaymentParams(
        invoiceId: 'inv-1',
        amount: 1000000,
        paymentMethod: PaymentMethod.bankTransfer,
        paymentDate: DateTime.now(),
      );

      final result = await recordPaymentUseCase.call(params);

      expect(result.id, equals('pay-1'));
      expect(result.amount, equals(1000000.0));
      verify(() => mockRepository.recordPayment(any())).called(1);
    });

    test('RecordPaymentUseCase throws ArgumentError when amount is zero or negative', () async {
      final invalidParams = RecordPaymentParams(
        invoiceId: 'inv-1',
        amount: -50000,
        paymentDate: DateTime.now(),
      );

      expect(() => recordPaymentUseCase.call(invalidParams), throwsArgumentError);
    });

    test('GetInvoicesUseCase returns list from repository', () async {
      when(() => mockRepository.getInvoices(
            roomId: any(named: 'roomId'),
            billingMonth: any(named: 'billingMonth'),
            status: any(named: 'status'),
            query: any(named: 'query'),
          )).thenAnswer((_) async => [tUnpaidInvoice, tPaidInvoice]);

      final result = await getInvoicesUseCase.call();

      expect(result.length, equals(2));
      verify(() => mockRepository.getInvoices()).called(1);
    });

    test('GetInvoiceByIdUseCase returns invoice from repository', () async {
      when(() => mockRepository.getInvoiceById('inv-1'))
          .thenAnswer((_) async => tUnpaidInvoice);

      final result = await getInvoiceByIdUseCase.call('inv-1');

      expect(result.id, equals('inv-1'));
      verify(() => mockRepository.getInvoiceById('inv-1')).called(1);
    });

    test('CancelInvoiceUseCase calls repository.cancelInvoice', () async {
      when(() => mockRepository.cancelInvoice('inv-1')).thenAnswer((_) async => {});

      await cancelInvoiceUseCase.call('inv-1');

      verify(() => mockRepository.cancelInvoice('inv-1')).called(1);
    });
  });
}
