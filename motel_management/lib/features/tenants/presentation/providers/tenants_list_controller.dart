import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_entity.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_status.dart';
import 'package:rental_management/features/tenants/presentation/providers/tenant_providers.dart';

class TenantsListState {
  final List<TenantEntity> tenants;
  final String searchQuery;
  final TenantStatus? selectedStatus;

  const TenantsListState({
    this.tenants = const [],
    this.searchQuery = '',
    this.selectedStatus,
  });

  TenantsListState copyWith({
    List<TenantEntity>? tenants,
    String? searchQuery,
    TenantStatus? selectedStatus,
    bool clearStatus = false,
  }) {
    return TenantsListState(
      tenants: tenants ?? this.tenants,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
    );
  }
}

class TenantsListController extends AutoDisposeAsyncNotifier<TenantsListState> {
  @override
  Future<TenantsListState> build() async {
    final tenants = await _fetchTenants(null, null);
    return TenantsListState(tenants: tenants);
  }

  Future<List<TenantEntity>> _fetchTenants(String? query, TenantStatus? status) async {
    final useCase = ref.read(getTenantsUseCaseProvider);
    return useCase(query: query, status: status);
  }

  Future<void> search(String query) async {
    final current = state.value ?? const TenantsListState();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final list = await _fetchTenants(query, current.selectedStatus);
      return current.copyWith(tenants: list, searchQuery: query);
    });
  }

  Future<void> filterByStatus(TenantStatus? status) async {
    final current = state.value ?? const TenantsListState();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final list = await _fetchTenants(current.searchQuery, status);
      return current.copyWith(
        tenants: list,
        selectedStatus: status,
        clearStatus: status == null,
      );
    });
  }

  Future<void> refresh() async {
    final current = state.value ?? const TenantsListState();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final list = await _fetchTenants(current.searchQuery, current.selectedStatus);
      return current.copyWith(tenants: list);
    });
  }

  Future<bool> deleteTenant(String id) async {
    try {
      final useCase = ref.read(deleteTenantUseCaseProvider);
      await useCase(id);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final AutoDisposeAsyncNotifierProvider<TenantsListController, TenantsListState>
    tenantsListControllerProvider =
    AsyncNotifierProvider.autoDispose<TenantsListController, TenantsListState>(
  TenantsListController.new,
);
