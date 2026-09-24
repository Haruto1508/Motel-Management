import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/features/auth/presentation/pages/login_page.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_providers.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_state.dart';
import 'package:rental_management/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:rental_management/features/rooms/presentation/pages/room_detail_page.dart';
import 'package:rental_management/features/rooms/presentation/pages/room_form_page.dart';
import 'package:rental_management/features/rooms/presentation/pages/rooms_page.dart';

import 'package:rental_management/features/contracts/presentation/pages/contract_detail_page.dart';
import 'package:rental_management/features/contracts/presentation/pages/contract_form_page.dart';
import 'package:rental_management/features/contracts/presentation/pages/contracts_page.dart';
import 'package:rental_management/features/invoices/presentation/pages/invoice_detail_page.dart';
import 'package:rental_management/features/invoices/presentation/pages/invoice_form_page.dart';
import 'package:rental_management/features/invoices/presentation/pages/invoices_page.dart';
import 'package:rental_management/features/tenants/presentation/pages/tenant_detail_page.dart';
import 'package:rental_management/features/tenants/presentation/pages/tenant_form_page.dart';
import 'package:rental_management/features/tenants/presentation/pages/tenants_page.dart';
import 'package:rental_management/features/utilities/presentation/pages/record_reading_page.dart';
import 'package:rental_management/features/utilities/presentation/pages/utilities_page.dart';

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
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.rooms,
        name: 'rooms',
        builder: (context, state) => const RoomsPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'room_create',
            builder: (context, state) => const RoomFormPage(),
          ),
          GoRoute(
            path: ':id',
            name: 'room_detail',
            builder: (context, state) {
              final roomId = state.pathParameters['id'] ?? '';
              return RoomDetailPage(roomId: roomId);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'room_edit',
                builder: (context, state) {
                  final roomId = state.pathParameters['id'] ?? '';
                  return RoomFormPage(roomId: roomId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.tenants,
        name: 'tenants',
        builder: (context, state) => const TenantsPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'tenant_create',
            builder: (context, state) => const TenantFormPage(),
          ),
          GoRoute(
            path: ':id',
            name: 'tenant_detail',
            builder: (context, state) {
              final tenantId = state.pathParameters['id'] ?? '';
              return TenantDetailPage(tenantId: tenantId);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'tenant_edit',
                builder: (context, state) {
                  final tenantId = state.pathParameters['id'] ?? '';
                  return TenantFormPage(tenantId: tenantId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.contracts,
        name: 'contracts',
        builder: (context, state) => const ContractsPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'contract_create',
            builder: (context, state) {
              final roomId = state.uri.queryParameters['roomId'];
              return ContractFormPage(initialRoomId: roomId);
            },
          ),
          GoRoute(
            path: ':id',
            name: 'contract_detail',
            builder: (context, state) {
              final contractId = state.pathParameters['id'] ?? '';
              return ContractDetailPage(contractId: contractId);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'contract_edit',
                builder: (context, state) {
                  final contractId = state.pathParameters['id'] ?? '';
                  return ContractFormPage(contractId: contractId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.utilities,
        name: 'utilities',
        builder: (context, state) => const UtilitiesPage(),
        routes: [
          GoRoute(
            path: 'record',
            name: 'utility_record',
            builder: (context, state) {
              final roomId = state.uri.queryParameters['roomId'];
              return RecordReadingPage(initialRoomId: roomId);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.invoices,
        name: 'invoices',
        builder: (context, state) => const InvoicesPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'invoice_create',
            builder: (context, state) {
              final roomId = state.uri.queryParameters['roomId'];
              return InvoiceFormPage(initialRoomId: roomId);
            },
          ),
          GoRoute(
            path: ':id',
            name: 'invoice_detail',
            builder: (context, state) {
              final invoiceId = state.pathParameters['id'] ?? '';
              return InvoiceDetailPage(invoiceId: invoiceId);
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
