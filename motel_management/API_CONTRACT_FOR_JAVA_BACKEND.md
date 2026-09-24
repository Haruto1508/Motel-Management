# TÀI LIỆU ĐẶC TẢ API & POSTGRESQL CHO BACKEND JAVA (SPRING BOOT)

Tài liệu này cung cấp đầy đủ thông số kỹ thuật (REST API Endpoints, DTO Request/Response, PostgreSQL DDL) để bạn phát triển dự án backend độc lập bằng **Java (Spring Boot + Spring Data JPA / Hibernate + PostgreSQL)** tương thích hoàn toàn với Flutter frontend.

---

## 1. Cấu Hình Cơ Bản
- **Base URL:** `http://localhost:8080/api/v1`
- **Mã hóa:** `UTF-8`
- **Content-Type:** `application/json`
- **Xác thực:** JWT Bearer Token gửi trong Header:
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Cấu trúc Response tiêu chuẩn:**
  ```json
  {
    "success": true,
    "data": { ... },
    "message": "Thông báo (tùy chọn)"
  }
  ```

---

## 2. PostgreSQL DDL (Database Schema)

Bạn có thể chạy các câu lệnh DDL sau trong PostgreSQL để tạo các bảng:

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Bảng Users (Chủ trọ / Quản lý)
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    role VARCHAR(50) DEFAULT 'LANDLORD',
    avatar_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng Rooms (Phòng trọ)
CREATE TABLE rooms (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    room_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    floor INT NOT NULL DEFAULT 1,
    area DOUBLE PRECISION NOT NULL DEFAULT 20.0,
    monthly_rent DOUBLE PRECISION NOT NULL DEFAULT 2000000,
    capacity INT NOT NULL DEFAULT 2,
    status VARCHAR(50) NOT NULL DEFAULT 'AVAILABLE', -- AVAILABLE, OCCUPIED, MAINTENANCE, RESERVED
    description TEXT,
    current_occupancy INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Bảng Tenants (Khách thuê)
CREATE TABLE tenants (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    identity_card VARCHAR(50),
    email VARCHAR(255),
    hometown VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Bảng Room Members (Khách đang ở trong phòng)
CREATE TABLE room_members (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    room_id VARCHAR(36) REFERENCES rooms(id) ON DELETE CASCADE,
    tenant_id VARCHAR(36) REFERENCES tenants(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'MEMBER', -- PRIMARY, MEMBER
    move_in_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Bảng Contracts (Hợp đồng thuê)
CREATE TABLE contracts (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    contract_number VARCHAR(100) UNIQUE NOT NULL,
    room_id VARCHAR(36) REFERENCES rooms(id) ON DELETE CASCADE,
    primary_tenant_id VARCHAR(36) REFERENCES tenants(id) ON DELETE CASCADE,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    deposit_amount DOUBLE PRECISION DEFAULT 0,
    monthly_rent DOUBLE PRECISION NOT NULL,
    status VARCHAR(50) DEFAULT 'ACTIVE', -- ACTIVE, EXPIRED, TERMINATED
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Bảng Utility Readings (Chỉ số điện nước)
CREATE TABLE utility_readings (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    room_id VARCHAR(36) REFERENCES rooms(id) ON DELETE CASCADE,
    previous_electricity DOUBLE PRECISION,
    current_electricity DOUBLE PRECISION NOT NULL,
    previous_water DOUBLE PRECISION,
    current_water DOUBLE PRECISION NOT NULL,
    reading_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Bảng Invoices (Hóa đơn tiền phòng & dịch vụ)
CREATE TABLE invoices (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    invoice_number VARCHAR(100) UNIQUE NOT NULL,
    room_id VARCHAR(36) REFERENCES rooms(id) ON DELETE CASCADE,
    billing_month VARCHAR(20) NOT NULL, -- Ví dụ "09/2026"
    room_amount DOUBLE PRECISION NOT NULL,
    electricity_amount DOUBLE PRECISION DEFAULT 0,
    water_amount DOUBLE PRECISION DEFAULT 0,
    service_amount DOUBLE PRECISION DEFAULT 0,
    total_amount DOUBLE PRECISION NOT NULL,
    paid_amount DOUBLE PRECISION DEFAULT 0,
    status VARCHAR(50) DEFAULT 'UNPAID', -- PAID, UNPAID, PARTIAL, OVERDUE
    due_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 3. Danh Sách REST Endpoints Cho Java Backend

### A. Nhóm Authentication (`/api/v1/auth`)

#### 1. Đăng nhập
- **Method:** `POST /api/v1/auth/login`
- **Request Body:**
  ```json
  {
    "email": "admin@motel.com",
    "password": "password123"
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": {
      "accessToken": "eyJhbGciOi...",
      "refreshToken": "eyJhbGciOi...",
      "tokenType": "Bearer",
      "expiresIn": 604800
    }
  }
  ```

#### 2. Cấp mới token
- **Method:** `POST /api/v1/auth/refresh`
- **Request Body:**
  ```json
  {
    "refreshToken": "eyJhbGciOi..."
  }
  ```

#### 3. Thông tin người dùng hiện tại
- **Method:** `GET /api/v1/auth/me`
- **Headers:** `Authorization: Bearer <accessToken>`
- **Response:**
  ```json
  {
    "success": true,
    "data": {
      "id": "user-uuid",
      "email": "admin@motel.com",
      "fullName": "Nguyễn Văn Quản Lý",
      "phone": "0901234567",
      "role": "LANDLORD",
      "avatarUrl": null
    }
  }
  ```

#### 4. Đăng xuất
- **Method:** `POST /api/v1/auth/logout`

---

### B. Nhóm Phòng Trọ (`/api/v1/rooms`)

#### 1. Danh sách phòng (Có bộ lọc)
- **Method:** `GET /api/v1/rooms`
- **Query Parameters:**
  - `query` (String, tùy chọn): Tìm kiếm theo tên hoặc mã phòng
  - `status` (String, tùy chọn): `AVAILABLE`, `OCCUPIED`, `MAINTENANCE`, `RESERVED`
  - `floor` (Integer, tùy chọn): Lọc theo tầng
- **Response:**
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "room-uuid-1",
        "roomCode": "P101",
        "name": "Phòng 101 - Ban công",
        "floor": 1,
        "area": 25.0,
        "monthlyRent": 3500000,
        "capacity": 2,
        "status": "OCCUPIED",
        "description": "Đầy đủ tiện nghi",
        "currentOccupancy": 1,
        "createdAt": "2026-09-23T10:00:00Z",
        "updatedAt": "2026-09-23T10:00:00Z"
      }
    ]
  }
  ```

#### 2. Chi tiết phòng
- **Method:** `GET /api/v1/rooms/{id}`
- **Response:**
  ```json
  {
    "success": true,
    "data": {
      "room": {
        "id": "room-uuid-1",
        "roomCode": "P101",
        "name": "Phòng 101",
        "floor": 1,
        "area": 25.0,
        "monthlyRent": 3500000,
        "capacity": 2,
        "status": "OCCUPIED",
        "description": "Đầy đủ tiện nghi",
        "currentOccupancy": 1
      },
      "members": [
        {
          "id": "mem-1",
          "tenantId": "tenant-1",
          "fullName": "Trần Thị Thu Hà",
          "phone": "0912345678",
          "role": "PRIMARY",
          "moveInDate": "2026-01-15T00:00:00Z"
        }
      ],
      "activeContract": {
        "id": "ct-1",
        "contractNumber": "HD-2026-101",
        "primaryTenantName": "Trần Thị Thu Hà",
        "startDate": "2026-01-15T00:00:00Z",
        "endDate": "2027-01-15T00:00:00Z",
        "depositAmount": 3500000,
        "monthlyRent": 3500000,
        "status": "ACTIVE"
      },
      "latestUtilities": {
        "previousElectricity": 1250,
        "currentElectricity": 1380,
        "previousWater": 54,
        "currentWater": 62,
        "readingDate": "2026-09-20T00:00:00Z"
      },
      "currentInvoice": {
        "id": "inv-1",
        "invoiceNumber": "INV-202609-101",
        "billingMonth": "09/2026",
        "totalAmount": 4255000,
        "paidAmount": 4255000,
        "status": "PAID",
        "dueDate": "2026-09-25T00:00:00Z"
      }
    }
  }
  ```

#### 3. Tạo mới phòng
- **Method:** `POST /api/v1/rooms`
- **Request Body:**
  ```json
  {
    "roomCode": "P103",
    "name": "Phòng 103",
    "floor": 1,
    "area": 22.0,
    "monthlyRent": 3000000,
    "capacity": 2,
    "status": "AVAILABLE",
    "description": "Phòng mới trống"
  }
  ```

#### 4. Cập nhật phòng
- **Method:** `PUT /api/v1/rooms/{id}`
- **Request Body:** Tương tự `POST`

#### 5. Xóa phòng
- **Method:** `DELETE /api/v1/rooms/{id}`

---

### C. Nhóm Dashboard (`/api/v1/dashboard/stats`)
- **Method:** `GET /api/v1/dashboard/stats?billingMonth=09/2026`
- **Response:**
  ```json
  {
    "success": true,
    "data": {
      "totalRooms": 10,
      "occupiedRooms": 7,
      "availableRooms": 2,
      "maintenanceRooms": 1,
      "occupancyRate": 70.0,
      "totalTenants": 15,
      "totalRevenue": 25500000,
      "collectedRevenue": 21000000,
      "pendingRevenue": 4500000,
      "billingMonth": "09/2026"
    }
  }
  ```

---

## 4. Cơ Chế SQLite Offline Của Frontend
- Frontend đã được trang bị **SQLite** thông qua `SqliteDatabaseService` và `RoomLocalDataSource`.
- Khi online: App tự động đồng bộ và lưu cache dữ liệu phòng và chi tiết phòng vào SQLite cục bộ.
- Khi offline (hoặc backend chưa khởi động): App tự động đọc dữ liệu từ SQLite để người dùng có thể duyệt phòng và chi tiết phòng mà không gặp lỗi.
