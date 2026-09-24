You are a senior Flutter/Dart software architect.

Create a production-ready mobile application for RENTAL PROPERTY MANAGEMENT
using Flutter and Dart.

Project name:
rental_management

Main purpose:
The application helps landlords/property managers manage rental rooms,
tenants, room members, electricity, water, internet, contracts,
monthly rental payments, and payment status.

==================================================
1. TECHNOLOGY STACK
==================================================

Use:

- Flutter
- Dart
- Material 3
- Clean Architecture
- Feature-first architecture
- Riverpod for state management
- Dio for HTTP communication
- GoRouter for navigation
- Freezed for immutable models and unions
- json_serializable for JSON serialization
- flutter_secure_storage for authentication tokens
- shared_preferences for local preferences
- intl for date and currency formatting

Use null safety.

Follow Dart official style guidelines.

Use English naming for:
- classes
- methods
- variables
- files
- comments

The UI may display Vietnamese text.

==================================================
2. ARCHITECTURE
==================================================

Use Clean Architecture with:

Presentation
Domain
Data

Organize the project by feature.

Recommended structure:

lib/
├── app/
│   ├── app.dart
│   ├── router/
│   ├── theme/
│   └── config/
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   ├── utils/
│   ├── extensions/
│   └── widgets/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── dashboard/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── rooms/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── tenants/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── contracts/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── utilities/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── invoices/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── payments/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart

Each feature must contain:

data/
├── datasources/
├── models/
└── repositories/

domain/
├── entities/
├── repositories/
└── usecases/

presentation/
├── pages/
├── widgets/
└── providers/

Do not put business logic directly inside Widgets.

==================================================
3. AUTHENTICATION
==================================================

Implement authentication architecture.

Features:

- Login
- Logout
- Access token
- Refresh token
- Persistent authentication
- Current user
- Automatic token refresh
- Unauthorized handling

Create:

AuthRepository
AuthRemoteDataSource
LoginUseCase
LogoutUseCase
GetCurrentUserUseCase

Use Dio interceptor for:

- attaching access token
- refreshing expired token
- retrying failed requests
- logging out when refresh token is invalid

Store tokens using flutter_secure_storage.

==================================================
4. DASHBOARD
==================================================

Create a dashboard for landlords.

Display:

- Total rooms
- Occupied rooms
- Available rooms
- Maintenance rooms
- Total tenants
- Unpaid invoices
- Paid invoices
- Current month's revenue
- Current month's electricity usage
- Current month's water usage

Use cards and simple charts.

Dashboard should be mobile-friendly.

==================================================
5. ROOM MANAGEMENT
==================================================

Implement complete room management.

Room fields:

- id
- roomCode
- name
- floor
- area
- monthlyRent
- capacity
- status
- description
- createdAt
- updatedAt

Room status:

- AVAILABLE
- OCCUPIED
- MAINTENANCE
- INACTIVE

Functions:

- View room list
- Search rooms
- Filter by status
- View room details
- Create room
- Update room
- Delete/deactivate room
- View current members
- View current contract
- View current monthly invoice

Room detail should display:

Room information
+
Current tenants
+
Contract
+
Utility readings
+
Current invoice
+
Payment status

==================================================
6. TENANT / MEMBER MANAGEMENT
==================================================

Implement tenant management.

Tenant fields:

- id
- fullName
- phone
- email
- identityNumber
- dateOfBirth
- gender
- hometown
- occupation
- emergencyContact
- emergencyPhone
- note
- status

Tenant status:

- ACTIVE
- INACTIVE
- LEFT

Functions:

- Tenant list
- Search tenant
- Filter tenant
- Tenant detail
- Create tenant
- Update tenant
- Delete/deactivate tenant
- View tenant's room
- View tenant's contract
- View payment history

==================================================
7. ROOM MEMBERS
==================================================

A room can contain multiple tenants.

Create a RoomMember relationship.

Fields:

- id
- roomId
- tenantId
- role
- moveInDate
- moveOutDate
- isPrimaryTenant

Role:

- PRIMARY
- MEMBER

Functions:

- Add tenant to room
- Remove tenant from room
- Change primary tenant
- View all members
- View member history

Business rules:

- A room cannot exceed capacity.
- A tenant cannot be assigned to multiple active rooms.
- A room must have at most one primary tenant.
- Removing a tenant must not delete historical records.

==================================================
8. CONTRACT MANAGEMENT
==================================================

Implement rental contracts.

Contract fields:

- id
- contractNumber
- roomId
- primaryTenantId
- startDate
- endDate
- monthlyRent
- depositAmount
- paymentDueDay
- status
- terms
- createdAt
- updatedAt

Contract status:

- DRAFT
- ACTIVE
- EXPIRED
- TERMINATED
- CANCELLED

Functions:

- Create contract
- View contract
- Update contract
- Renew contract
- Terminate contract
- View contract history

Business rules:

- Only one ACTIVE contract per room.
- Contract must belong to an existing room.
- Contract must have a primary tenant.
- End date must be after start date.
- Monthly rent must be greater than zero.

==================================================
9. ELECTRICITY MANAGEMENT
==================================================

Track electricity meter readings.

Fields:

- id
- roomId
- readingDate
- previousReading
- currentReading
- consumption
- pricePerUnit
- totalAmount
- note

Formula:

consumption =
currentReading - previousReading

electricityAmount =
consumption * pricePerUnit

Business rules:

- Current reading cannot be lower than previous reading.
- Reading belongs to a room.
- Prevent duplicate readings for the same billing period.

Functions:

- Add meter reading
- Edit reading
- View reading history
- View monthly consumption
- Calculate electricity charge

==================================================
10. WATER MANAGEMENT
==================================================

Implement water meter management.

Fields:

- id
- roomId
- readingDate
- previousReading
- currentReading
- consumption
- pricePerUnit
- totalAmount
- note

Formula:

consumption =
currentReading - previousReading

waterAmount =
consumption * pricePerUnit

Functions:

- Add reading
- Edit reading
- View history
- Monthly consumption
- Calculate water charge

Support both:

1. Per-room water meter
2. Fixed water fee

==================================================
11. INTERNET MANAGEMENT
==================================================

Manage internet fees.

Internet configuration:

- id
- roomId
- provider
- packageName
- monthlyFee
- status
- startDate
- endDate

Status:

- ACTIVE
- INACTIVE

Support:

- Fixed monthly internet fee
- Room-specific internet fee
- Shared internet fee

==================================================
12. MONTHLY BILL / INVOICE
==================================================

Create monthly rental invoices.

Invoice fields:

- id
- invoiceNumber
- roomId
- tenantId
- billingMonth
- rentAmount
- electricityAmount
- waterAmount
- internetAmount
- otherAmount
- discountAmount
- totalAmount
- dueDate
- paidAt
- status

Status:

- DRAFT
- UNPAID
- PARTIALLY_PAID
- PAID
- OVERDUE
- CANCELLED

Formula:

totalAmount =
rentAmount
+ electricityAmount
+ waterAmount
+ internetAmount
+ otherAmount
- discountAmount

Display invoice breakdown clearly.

==================================================
13. PAYMENT MANAGEMENT
==================================================

Implement payment tracking.

Payment fields:

- id
- invoiceId
- amount
- paymentMethod
- paymentDate
- transactionReference
- note

Payment methods:

- CASH
- BANK_TRANSFER
- E_WALLET
- OTHER

Functions:

- Record payment
- View payment history
- View unpaid invoices
- View overdue invoices
- View monthly revenue
- View payment details

Business rules:

- Payment amount cannot be negative.
- Payment cannot exceed outstanding amount unless explicitly supported.
- Invoice becomes PAID when outstanding amount reaches zero.
- Partial payment changes invoice status to PARTIALLY_PAID.

==================================================
14. MONTHLY BILLING FLOW
==================================================

Create a clear monthly billing workflow.

Example:

1. Select billing month.
2. Load active rooms.
3. Load active contracts.
4. Load electricity readings.
5. Load water readings.
6. Calculate electricity usage.
7. Calculate water usage.
8. Add internet fee.
9. Add room rent.
10. Add other fees.
11. Apply discounts.
12. Calculate total.
13. Generate invoice.
14. Show payment status.

Allow the landlord to review the invoice before confirming.

==================================================
15. PAYMENT STATUS UI
==================================================

Use clear status indicators.

UNPAID:
"Chưa thanh toán"

PARTIALLY_PAID:
"Đã thanh toán một phần"

PAID:
"Đã thanh toán"

OVERDUE:
"Quá hạn"

Use suitable visual indicators but do not hard-code colors throughout widgets.

Create reusable:

PaymentStatusBadge

==================================================
16. SEARCH / FILTER / SORT
==================================================

Implement reusable search/filter components.

Room:

- Search by room code/name
- Filter status
- Filter floor

Tenant:

- Search name
- Search phone
- Search identity number

Invoice:

- Filter billing month
- Filter payment status
- Filter room

Contract:

- Filter active/expired/terminated

==================================================
17. NAVIGATION
==================================================

Use GoRouter.

Main navigation:

Dashboard
Rooms
Tenants
Contracts
Invoices
Payments
Settings

Room detail navigation:

Room
 ├── Overview
 ├── Members
 ├── Contract
 ├── Electricity
 ├── Water
 ├── Internet
 └── Invoice

==================================================
18. UI/UX
==================================================

Design for mobile first.

Use Material 3.

Use reusable components:

- AppScaffold
- AppButton
- AppTextField
- AppDropdown
- AppDatePicker
- AppCard
- EmptyState
- LoadingView
- ErrorView
- ConfirmDialog
- StatusBadge
- CurrencyText

Support:

- Loading state
- Empty state
- Error state
- Success feedback
- Confirmation dialogs
- Form validation

Use Vietnamese UI text.

Examples:

"Quản lý phòng"
"Thành viên"
"Hợp đồng"
"Điện"
"Nước"
"Mạng"
"Hóa đơn"
"Thanh toán"
"Chưa thanh toán"
"Đã thanh toán"
"Quá hạn"

==================================================
19. FORM VALIDATION
==================================================

Validate:

- Required fields
- Phone number
- Email
- Identity number
- Positive money values
- Positive meter readings
- Date ranges
- Room capacity
- Contract dates

Display user-friendly Vietnamese validation messages.

==================================================
20. ERROR HANDLING
==================================================

Create centralized error handling.

Handle:

- Network error
- Timeout
- Unauthorized
- Forbidden
- Not found
- Validation error
- Server error

Create:

AppException
NetworkException
UnauthorizedException
ValidationException

Map backend errors into user-friendly Vietnamese messages.

==================================================
21. API LAYER
==================================================

Assume REST API backend.

Base URL must be configurable.

Example:

API_BASE_URL

Do not hard-code localhost throughout the application.

Use:

Dio
ApiClient
Interceptors

Example endpoints:

POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout

GET    /api/v1/rooms
POST   /api/v1/rooms
GET    /api/v1/rooms/{id}
PUT    /api/v1/rooms/{id}
DELETE /api/v1/rooms/{id}

GET    /api/v1/tenants
POST   /api/v1/tenants
GET    /api/v1/tenants/{id}
PUT    /api/v1/tenants/{id}

GET    /api/v1/contracts
POST   /api/v1/contracts
PUT    /api/v1/contracts/{id}

GET    /api/v1/rooms/{roomId}/members
POST   /api/v1/rooms/{roomId}/members
DELETE /api/v1/rooms/{roomId}/members/{tenantId}

GET    /api/v1/electricity/readings
POST   /api/v1/electricity/readings

GET    /api/v1/water/readings
POST   /api/v1/water/readings

GET    /api/v1/invoices
POST   /api/v1/invoices
GET    /api/v1/invoices/{id}

GET    /api/v1/payments
POST   /api/v1/payments

==================================================
22. STATE MANAGEMENT
==================================================

Use Riverpod.

Create providers for:

- Authentication
- Dashboard
- Rooms
- Room detail
- Tenants
- Contracts
- Electricity
- Water
- Internet
- Invoices
- Payments

Separate:

- UI state
- server state
- form state

Do not put business logic inside widgets.

==================================================
23. DOMAIN LAYER
==================================================

Domain entities should not depend on Flutter,
Dio, JSON, or UI.

Example:

RoomEntity
TenantEntity
RoomMemberEntity
ContractEntity
ElectricityReadingEntity
WaterReadingEntity
InternetEntity
InvoiceEntity
PaymentEntity

Repositories should be interfaces in domain:

abstract class RoomRepository {
    Future<List<RoomEntity>> getRooms();
    Future<RoomEntity> getRoomById(String id);
    Future<RoomEntity> createRoom(CreateRoomParams params);
    Future<RoomEntity> updateRoom(...);
}

Implement repositories inside data layer.

==================================================
24. DATA LAYER
==================================================

Create:

DTO / Model classes
RemoteDataSource
Repository implementations

Example:

RoomModel
RoomRemoteDataSource
RoomRepositoryImpl

Mapping:

RoomModel
    ↓
RoomEntity

Do not expose API models directly to presentation.

==================================================
25. OFFLINE / LOCAL CACHE
==================================================

Prepare the architecture for offline support.

Initially support:

- Cached current user
- Cached room list
- Cached tenant list
- Cached recent invoices

The application should gracefully handle temporary network failure.

Do not implement complicated synchronization unless necessary.

==================================================
26. SECURITY
==================================================

Never store access tokens in SharedPreferences.

Use flutter_secure_storage.

Never log:

- access token
- refresh token
- passwords
- sensitive identity information

Avoid exposing sensitive tenant information unnecessarily.

==================================================
27. TESTING
==================================================

Create tests for:

Domain use cases
Repository
State providers
Important UI logic

Especially test:

- Room creation
- Room capacity validation
- Tenant assignment
- Contract validation
- Electricity calculation
- Water calculation
- Invoice calculation
- Partial payment
- Full payment
- Overdue invoice
- Authentication

Example:

electricity:
previous = 100
current = 150
price = 3000

expected:
consumption = 50
amount = 150000

Water:

previous = 20
current = 25
price = 15000

expected:
consumption = 5
amount = 75000

Invoice:

rent = 3,000,000
electricity = 150,000
water = 75,000
internet = 100,000

expected total:
3,325,000

==================================================
28. CODE QUALITY
==================================================

Follow SOLID principles.

Avoid:

- God classes
- Massive widgets
- Business logic in UI
- Direct API calls from widgets
- Global mutable state
- Hard-coded strings
- Hard-coded API URLs
- Duplicate calculation logic

Use:

- Dependency injection
- Repository pattern
- Use case pattern
- Immutable state
- Reusable widgets
- Centralized error handling

==================================================
29. DEVELOPMENT ORDER
==================================================

Do not generate everything blindly at once.

Build incrementally in this order:

PHASE 1:
Project setup
Clean Architecture
Riverpod
GoRouter
Dio
Theme
Core utilities

PHASE 2:
Authentication

PHASE 3:
Dashboard

PHASE 4:
Room management

PHASE 5:
Tenant management

PHASE 6:
Room members

PHASE 7:
Contracts

PHASE 8:
Electricity

PHASE 9:
Water

PHASE 10:
Internet

PHASE 11:
Invoices

PHASE 12:
Payments

PHASE 13:
Testing

PHASE 14:
Polishing and error handling

For each phase:

1. Explain the architecture.
2. Create the required folders.
3. Create entities.
4. Create repository interfaces.
5. Create use cases.
6. Create data models.
7. Create data sources.
8. Create repository implementations.
9. Create Riverpod providers.
10. Create pages.
11. Create reusable widgets.
12. Add validation.
13. Add tests.
14. Explain how to run the feature.

Do not skip architectural layers.

==================================================
30. IMPORTANT
==================================================

Generate production-quality code rather than a toy demo.

Do not put everything into main.dart.

Do not create one giant service.

Keep features independent.

Keep domain independent from Flutter.

Use dependency injection.

Use meaningful naming.

Use Vietnamese UI but English code.

Start by generating:

1. Flutter project structure
2. pubspec.yaml dependencies
3. main.dart
4. app.dart
5. GoRouter configuration
6. Theme
7. Core network layer
8. Core error handling
9. Authentication feature skeleton

Then stop and explain the generated structure before proceeding to the next phase.