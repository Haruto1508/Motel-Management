import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/features/auth/presentation/screens/login_screen.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_providers.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_state.dart';
import 'package:rental_management/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:rental_management/features/rooms/presentation/screens/room_detail_screen.dart';
import 'package:rental_management/features/rooms/presentation/screens/room_form_screen.dart';
import 'package:rental_management/features/rooms/presentation/screens/rooms_screen.dart';

import 'package:rental_management/features/contracts/presentation/screens/contract_detail_screen.dart';
import 'package:rental_management/features/contracts/presentation/screens/contract_form_screen.dart';
import 'package:rental_management/features/contracts/presentation/screens/contracts_screen.dart';
import 'package:rental_management/features/invoices/presentation/screens/invoice_detail_screen.dart';
import 'package:rental_management/features/invoices/presentation/screens/invoice_form_screen.dart';
import 'package:rental_management/features/invoices/presentation/screens/invoices_screen.dart';
import 'package:rental_management/features/tenants/presentation/screens/tenant_detail_screen.dart';
import 'package:rental_management/features/tenants/presentation/screens/tenant_form_screen.dart';
import 'package:rental_management/features/tenants/presentation/screens/tenants_screen.dart';
import 'package:rental_management/features/utilities/presentation/screens/record_reading_screen.dart';
import 'package:rental_management/features/utilities/presentation/screens/utilities_screen.dart';

/// Centralized route paths
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String rooms = '/rooms';
  static const String roomCreate = '/rooms/create';
  static const String roomDetail = '/rooms/:id';
  static const String roomEdit = '/rooms/:id/edit';
  static const String tenants = '/tenants';
  static const String tenantCreate = '/tenants/create';
  static const String tenantDetail = '/tenants/:id';
  static const String tenantEdit = '/tenants/:id/edit';
  static const String contracts = '/contracts';
  static const String contractCreate = '/contracts/create';
  static const String contractDetail = '/contracts/:id';
  static const String contractEdit = '/contracts/:id/edit';
  static const String utilities = '/utilities';
  static const String utilityRecord = '/utilities/record';
  static const String invoices = '/invoices';
  static const String invoiceCreate = '/invoices/create';
  static const String invoiceDetail = '/invoices/:id';
  static const String payments = '/payments';
}

/// Listenable that triggers GoRouter redirects whenever AuthState changes
class RouterListenable extends ChangeNotifier {
  final Ref _ref;

  RouterListenable(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerListenableProvider = Provider<RouterListenable>((ref) {
  return RouterListenable(ref);
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final listenable = ref.watch(routerListenableProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: listenable,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.rooms,
        name: 'rooms',
        builder: (context, state) => const RoomsScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'room_create',
            builder: (context, state) => const RoomFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'room_detail',
            builder: (context, state) {
              final roomId = state.pathParameters['id'] ?? '';
              return RoomDetailScreen(roomId: roomId);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'room_edit',
                builder: (context, state) {
                  final roomId = state.pathParameters['id'] ?? '';
                  return RoomFormScreen(roomId: roomId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.tenants,
        name: 'tenants',
        builder: (context, state) => const TenantsScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'tenant_create',
            builder: (context, state) => const TenantFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'tenant_detail',
            builder: (context, state) {
              final tenantId = state.pathParameters['id'] ?? '';
              return TenantDetailScreen(tenantId: tenantId);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'tenant_edit',
                builder: (context, state) {
                  final tenantId = state.pathParameters['id'] ?? '';
                  return TenantFormScreen(tenantId: tenantId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.contracts,
        name: 'contracts',
        builder: (context, state) => const ContractsScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'contract_create',
            builder: (context, state) {
              final roomId = state.uri.queryParameters['roomId'];
              return ContractFormScreen(initialRoomId: roomId);
            },
          ),
          GoRoute(
            path: ':id',
            name: 'contract_detail',
            builder: (context, state) {
              final contractId = state.pathParameters['id'] ?? '';
              return ContractDetailScreen(contractId: contractId);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'contract_edit',
                builder: (context, state) {
                  final contractId = state.pathParameters['id'] ?? '';
                  return ContractFormScreen(contractId: contractId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.utilities,
        name: 'utilities',
        builder: (context, state) => const UtilitiesScreen(),
        routes: [
          GoRoute(
            path: 'record',
            name: 'utility_record',
            builder: (context, state) {
              final roomId = state.uri.queryParameters['roomId'];
              return RecordReadingScreen(initialRoomId: roomId);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.invoices,
        name: 'invoices',
        builder: (context, state) => const InvoicesScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'invoice_create',
            builder: (context, state) {
              final roomId = state.uri.queryParameters['roomId'];
              return InvoiceFormScreen(initialRoomId: roomId);
            },
          ),
          GoRoute(
            path: ':id',
            name: 'invoice_detail',
            builder: (context, state) {
              final invoiceId = state.pathParameters['id'] ?? '';
              return InvoiceDetailScreen(invoiceId: invoiceId);
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      // While initial auth check is ongoing, do nothing
      if (authState.status == AuthStatus.initial) {
        return null;
      }

      // If not authenticated and not on login screen, redirect to login
      if (!authState.isAuthenticated && !isLoggingIn) {
        return AppRoutes.login;
      }

      // If authenticated and trying to access login, redirect to dashboard
      if (authState.isAuthenticated && isLoggingIn) {
        return AppRoutes.dashboard;
      }

      return null;
    },
  );
});
