-- =======================================================
-- HỆ THỐNG QUẢN LÝ NHÀ TRỌ (MOTEL MANAGEMENT)
-- POSTGRESQL DATABASE SCHEMA & INITIAL DATA
-- =======================================================

-- 1. Bật Extension tạo UUID nếu cần
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Bảng Users (Tài khoản người dùng / Chủ trọ)
CREATE TABLE IF NOT EXISTS users (
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

-- 3. Bảng Rooms (Phòng trọ)
CREATE TABLE IF NOT EXISTS rooms (
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

-- 4. Bảng Tenants (Khách thuê trọ)
CREATE TABLE IF NOT EXISTS tenants (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    identity_card VARCHAR(50),
    email VARCHAR(255),
    hometown VARCHAR(255),
    status VARCHAR(50) DEFAULT 'ACTIVE', -- ACTIVE, INACTIVE
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Bảng Room Members (Liên kết khách ở trong phòng)
CREATE TABLE IF NOT EXISTS room_members (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    room_id VARCHAR(36) REFERENCES rooms(id) ON DELETE CASCADE,
    tenant_id VARCHAR(36) REFERENCES tenants(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'MEMBER', -- PRIMARY, MEMBER
    move_in_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Bảng Contracts (Hợp đồng thuê phòng)
CREATE TABLE IF NOT EXISTS contracts (
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

-- 7. Bảng Utility Readings (Chỉ số điện nước định kỳ)
CREATE TABLE IF NOT EXISTS utility_readings (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    room_id VARCHAR(36) REFERENCES rooms(id) ON DELETE CASCADE,
    billing_month VARCHAR(20),
    previous_electricity DOUBLE PRECISION,
    current_electricity DOUBLE PRECISION NOT NULL,
    previous_water DOUBLE PRECISION,
    current_water DOUBLE PRECISION NOT NULL,
    reading_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Bảng Service Configs (Bảng giá dịch vụ dùng chung)
CREATE TABLE IF NOT EXISTS service_configs (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    service_name VARCHAR(100) NOT NULL,
    unit_price DOUBLE PRECISION NOT NULL,
    unit VARCHAR(50),
    calc_method VARCHAR(50) DEFAULT 'PER_ROOM', -- METER, PER_ROOM, PER_PERSON
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. Bảng Invoices (Hóa đơn thu tiền)
CREATE TABLE IF NOT EXISTS invoices (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    invoice_number VARCHAR(100) UNIQUE NOT NULL,
    room_id VARCHAR(36) REFERENCES rooms(id) ON DELETE CASCADE,
    billing_month VARCHAR(20) NOT NULL, -- Ví dụ: '09/2026'
    tenant_name VARCHAR(255),
    room_amount DOUBLE PRECISION NOT NULL,
    electricity_amount DOUBLE PRECISION DEFAULT 0,
    water_amount DOUBLE PRECISION DEFAULT 0,
    service_amount DOUBLE PRECISION DEFAULT 0,
    discount_amount DOUBLE PRECISION DEFAULT 0,
    other_amount DOUBLE PRECISION DEFAULT 0,
    total_amount DOUBLE PRECISION NOT NULL,
    paid_amount DOUBLE PRECISION DEFAULT 0,
    status VARCHAR(50) DEFAULT 'UNPAID', -- PAID, UNPAID, PARTIAL, OVERDUE, CANCELLED
    due_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. Bảng Invoice Payments (Lịch sử thanh toán hóa đơn)
CREATE TABLE IF NOT EXISTS invoice_payments (
    id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    invoice_id VARCHAR(36) REFERENCES invoices(id) ON DELETE CASCADE,
    amount DOUBLE PRECISION NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'CASH', -- CASH, BANK_TRANSFER, EWALLET
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
