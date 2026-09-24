import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/features/utilities/domain/usecases/record_utility_reading_usecase.dart';
import 'package:rental_management/features/utilities/presentation/providers/utility_providers.dart';

class UtilitiesState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String selectedMonth; // "MM/yyyy"

  const UtilitiesState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    required this.selectedMonth,
  });

  UtilitiesState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? selectedMonth,
  }) {
    return UtilitiesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

class UtilitiesController extends StateNotifier<UtilitiesState> {
  final Ref _ref;

  UtilitiesController(this._ref)
      : super(UtilitiesState(
          selectedMonth: _getCurrentMonthString(),
        ));

  static String _getCurrentMonthString() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    return '$month/${now.year}';
  }

  void setSelectedMonth(String month) {
    state = state.copyWith(selectedMonth: month);
  }

  Future<bool> recordReading(RecordUtilityParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final useCase = _ref.read(recordUtilityReadingUseCaseProvider);
      await useCase.call(params);

      // Invalidate relevant providers to refresh data
      _ref.invalidate(utilityReadingsProvider);
      _ref.invalidate(latestReadingProvider(params.roomId));

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Ghi chỉ số điện nước thành công',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateServicePrice(String serviceId, double newPrice) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final useCase = _ref.read(updateServiceConfigUseCaseProvider);
      await useCase.call(serviceId, newPrice);

      _ref.invalidate(serviceConfigsProvider);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Cập nhật đơn giá thành công',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

final utilitiesControllerProvider =
    StateNotifierProvider<UtilitiesController, UtilitiesState>((ref) {
  return UtilitiesController(ref);
});
