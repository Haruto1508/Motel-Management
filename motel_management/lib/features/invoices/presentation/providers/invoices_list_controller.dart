import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_entity.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_status.dart';
import 'package:rental_management/features/invoices/presentation/providers/invoice_providers.dart';

class InvoicesListState {
  final bool isLoading;
  final String? errorMessage;
  final List<InvoiceEntity> invoices;
  final InvoiceStatus? selectedStatus;
  final String? selectedMonth;
  final String searchQuery;

  const InvoicesListState({
    this.isLoading = false,
    this.errorMessage,
    this.invoices = const [],
    this.selectedStatus,
    this.selectedMonth,
    this.searchQuery = '',
  });

  InvoicesListState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<InvoiceEntity>? invoices,
    InvoiceStatus? selectedStatus,
    bool clearStatus = false,
    String? selectedMonth,
    bool clearMonth = false,
    String? searchQuery,
  }) {
    return InvoicesListState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      invoices: invoices ?? this.invoices,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      selectedMonth: clearMonth ? null : (selectedMonth ?? this.selectedMonth),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  // --- Financial Summary Getters ---
  double get totalBilledAmount =>
      invoices.fold(0.0, (sum, inv) => sum + inv.totalAmount);

  double get totalCollectedAmount =>
      invoices.fold(0.0, (sum, inv) => sum + inv.paidAmount);

  double get totalPendingAmount =>
      invoices.fold(0.0, (sum, inv) => sum + inv.remainingAmount);
}

class InvoicesListController extends StateNotifier<InvoicesListState> {
  final Ref _ref;

  InvoicesListController(this._ref) : super(const InvoicesListState()) {
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final useCase = _ref.read(getInvoicesUseCaseProvider);
      final list = await useCase.call(
        billingMonth: state.selectedMonth,
        status: state.selectedStatus,
        query: state.searchQuery.isEmpty ? null : state.searchQuery,
      );

      state = state.copyWith(
        isLoading: false,
        invoices: list,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setStatusFilter(InvoiceStatus? status) {
    if (state.selectedStatus == status) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
    loadInvoices();
  }

  void setMonthFilter(String? month) {
    if (month == null || month.isEmpty) {
      state = state.copyWith(clearMonth: true);
    } else {
      state = state.copyWith(selectedMonth: month);
    }
    loadInvoices();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    loadInvoices();
  }

  Future<void> refresh() async {
    await loadInvoices();
  }
}

final invoicesListControllerProvider =
    StateNotifierProvider<InvoicesListController, InvoicesListState>((ref) {
  return InvoicesListController(ref);
});
