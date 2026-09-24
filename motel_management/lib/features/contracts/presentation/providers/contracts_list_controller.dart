import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_entity.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_status.dart';
import 'package:rental_management/features/contracts/presentation/providers/contract_providers.dart';

class ContractsListState {
  final List<ContractEntity> contracts;
  final String searchQuery;
  final ContractStatus? selectedStatus;

  const ContractsListState({
    this.contracts = const [],
    this.searchQuery = '',
    this.selectedStatus,
  });

  ContractsListState copyWith({
    List<ContractEntity>? contracts,
    String? searchQuery,
    ContractStatus? selectedStatus,
    bool clearStatus = false,
  }) {
    return ContractsListState(
      contracts: contracts ?? this.contracts,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
    );
  }
}

class ContractsListController extends AutoDisposeAsyncNotifier<ContractsListState> {
  @override
  Future<ContractsListState> build() async {
    final contracts = await _fetchContracts(null, null);
    return ContractsListState(contracts: contracts);
  }

  Future<List<ContractEntity>> _fetchContracts(String? query, ContractStatus? status) async {
    final useCase = ref.read(getContractsUseCaseProvider);
    return useCase(query: query, status: status);
  }

  Future<void> search(String query) async {
    final current = state.value ?? const ContractsListState();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final list = await _fetchContracts(query, current.selectedStatus);
      return current.copyWith(contracts: list, searchQuery: query);
    });
  }

  Future<void> filterByStatus(ContractStatus? status) async {
    final current = state.value ?? const ContractsListState();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final list = await _fetchContracts(current.searchQuery, status);
      return current.copyWith(
        contracts: list,
        selectedStatus: status,
        clearStatus: status == null,
      );
    });
  }

  Future<void> refresh() async {
    final current = state.value ?? const ContractsListState();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final list = await _fetchContracts(current.searchQuery, current.selectedStatus);
      return current.copyWith(contracts: list);
    });
  }

  Future<bool> terminateContract(String id, {String? reason}) async {
    try {
      final useCase = ref.read(terminateContractUseCaseProvider);
      await useCase(id, reason: reason);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final AutoDisposeAsyncNotifierProvider<ContractsListController, ContractsListState>
    contractsListControllerProvider =
    AsyncNotifierProvider.autoDispose<ContractsListController, ContractsListState>(
  ContractsListController.new,
);
