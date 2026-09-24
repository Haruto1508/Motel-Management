# Hệ Thống Quản Lý Nhà Trọ (Rental Management) - Flutter Client

Ứng dụng di động và desktop hoàn chỉnh phục vụ quản lý nhà trọ, căn hộ dịch vụ và phòng trọ chuyên nghiệp, được xây dựng bằng **Flutter & Dart** theo chuẩn **Clean Architecture** và hỗ trợ **Offline-first với SQLite**.

Backend được thiết kế tách biệt và viết bằng **Java (Spring Boot)**. Bản đặc tả chi tiết REST API và DDL PostgreSQL được lưu trữ tại [API_CONTRACT_FOR_JAVA_BACKEND.md](./API_CONTRACT_FOR_JAVA_BACKEND.md).

---

## 🚀 Công Nghệ Sử Dụng (Technology Stack)

- **UI Framework:** Flutter (Material 3)
- **Kiến trúc:** Clean Architecture (Domain, Data, Presentation) + Feature-First
- **Quản lý trạng thái:** Flutter Riverpod
- **Điều hướng (Routing):** GoRouter
- **Giao tiếp mạng:** Dio (tự động đính kèm token, xử lý refresh token và lỗi mạng)
- **Lưu trữ bảo mật:** Flutter Secure Storage (lưu JWT Access & Refresh Token)
- **Lưu trữ cục bộ / Offline-first:** SQLite (`sqflite`, `sqflite_common_ffi`, `path`)
- **Formatting & Tiện ích:** `intl` (Định dạng tiền tệ VNĐ và thời gian Việt Nam)
- **Testing:** `flutter_test`, `mocktail`

---

## 📁 Cấu Trúc Dự Án (Project Structure)

```
lib/
├── app/
│   ├── app.dart                   # Root MaterialApp widget & Riverpod listener
│   ├── config/                    # Cấu hình môi trường (API Base URL, dev/prod)
│   ├── router/                    # GoRouter định tuyến toàn bộ ứng dụng
│   └── theme/                     # Material 3 theme & color schemes
│
├── core/
│   ├── constants/                 # Hằng số toàn cục, endpoints, storage keys
│   ├── database/                  # SqliteDatabaseService (SQLite offline cache)
│   ├── errors/                    # AppFailure, Dio error interceptor
│   ├── network/                   # ApiClient, AuthInterceptor
│   ├── storage/                   # SecureStorageService
│   ├── utils/                     # CurrencyFormatter, DateFormatter, Validators
│   └── widgets/                   # AppButton, AppCard, AppScaffold, EmptyState, StatusBadge...
│
└── features/                      # 7 Feature Modules chuẩn Clean Architecture
    ├── auth/                      # Đăng nhập, xác thực, refresh token, lưu phiên
    ├── dashboard/                 # Bảng điều khiển, thống kê doanh thu, tỷ lệ lấp đầy
    ├── rooms/                     # Quản lý danh sách phòng, chi tiết phòng (5 tabs)
    ├── tenants/                   # Quản lý khách thuê, hồ sơ cá nhân, thành viên phòng
    ├── contracts/                 # Quản lý hợp đồng thuê, thời hạn, cọc, thanh lý
    ├── utilities/                 # Quản lý điện, nước (theo đồng hồ/khoán), bảng giá dịch vụ
    └── invoices/                  # Lập hóa đơn hàng tháng, ghi nhận thanh toán, gạch nợ
```

---

## 🌟 Các Tính Năng Đã Triển Khai (Features)

1. **Xác Thực (Authentication):**
   - Đăng nhập JWT, tự động refresh token khi hết hạn, lưu phiên đăng nhập an toàn với Flutter Secure Storage.
2. **Bảng Điều Khiển (Dashboard):**
   - Thống kê tổng số phòng, số phòng đang có khách, tổng số người thuê, điện nước trong tháng.
   - Thống kê tài chính doanh thu, thanh tiến độ tỷ lệ lấp đầy, điều hướng nhanh các nghiệp vụ.
3. **Quản Lý Phòng Trọ (Rooms):**
   - Danh sách phòng với lọc tầng, trạng thái (`Trống`, `Đang thuê`, `Bảo trì`).
   - Màn hình chi tiết phòng tổng hợp 5 tab: **Thông tin**, **Thành viên phòng**, **Hợp đồng**, **Điện & Nước**, **Hóa đơn**.
   - Hỗ trợ cache SQLite cục bộ hiển thị tức thì khi mất kết nối mạng.
4. **Quản Lý Khách Thuê & Thành Viên (Tenants & Members):**
   - Danh sách khách thuê với tìm kiếm thời gian thực (tên, SĐT, CCCD), lọc theo trạng thái.
   - Hồ sơ cá nhân chi tiết, liên hệ khẩn cấp, thêm/xóa thành viên trực tiếp vào từng phòng trọ.
5. **Hợp Đồng Thuê Phòng (Contracts):**
   - Quản lý thời hạn, tiền đặt cọc, tiền thuê, ngày đóng tiền định kỳ.
   - Tự động kiểm tra trạng thái (`Đang hiệu lực`, `Hết hạn`, `Đã thanh lý`).
   - Tích hợp nút "Tạo hợp đồng ngay" khi xem phòng trống.
6. **Quản Lý Điện, Nước & Dịch Vụ (Utilities):**
   - Ghi chỉ số điện: Tự động tính số kWh tiêu thụ, áp dụng đơn giá điện, validation số mới $\ge$ số cũ.
   - Ghi chỉ số nước: Hỗ trợ tính theo đồng hồ khối ($m^3$) hoặc tính khoán (theo phòng / đầu người).
   - Xem trước realtime số tiền tạm tính khi nhập số.
   - Quản lý bảng giá các dịch vụ dùng chung (Internet WiFi, Rác sinh hoạt...).
7. **Hóa Đơn & Thanh Toán (Invoices & Payments):**
   - **Quy trình lập hóa đơn tự động (Monthly Billing Flow):** Tự động tải tiền thuê từ hợp đồng, tiền điện nước từ chỉ số đã chốt, tiền dịch vụ cố định và hỗ trợ chiết khấu/giảm giá.
   - Bảng kê chiết tính chi tiết 6 mục rõ ràng, minh bạch.
   - Ghi nhận thanh toán đa phương thức (`Tiền mặt`, `Chuyển khoản`, `Ví điện tử`).
   - Gạch nợ tự động cập nhật số dư và trạng thái hóa đơn (`Chưa thanh toán`, `Đã trả một phần`, `Đã thanh toán`, `Quá hạn`).

---

## 🧪 Kiểm Thử & Đảm Bảo Chất Lượng (Testing)

Dự án được viết unit test bao phủ toàn bộ Business Logic, công thức tính toán và Use Cases:

```bash
# Kiểm tra phân tích tĩnh toàn dự án (0 errors, 0 warnings)
flutter analyze

# Chạy toàn bộ 51 unit tests (100% tests passed)
flutter test
```

---

## 🔗 Liên Kết API Backend
- Đặc tả API và DDL PostgreSQL cho dự án Backend Java: [API_CONTRACT_FOR_JAVA_BACKEND.md](./API_CONTRACT_FOR_JAVA_BACKEND.md).
