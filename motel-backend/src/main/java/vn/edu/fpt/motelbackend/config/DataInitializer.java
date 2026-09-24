package vn.edu.fpt.motelbackend.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import vn.edu.fpt.motelbackend.entity.*;
import vn.edu.fpt.motelbackend.enums.RoomStatus;
import vn.edu.fpt.motelbackend.repository.*;

import java.time.LocalDateTime;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final ServiceConfigRepository serviceConfigRepository;
    private final RoomRepository roomRepository;
    private final TenantRepository tenantRepository;
    private final RoomMemberRepository roomMemberRepository;
    private final ContractRepository contractRepository;
    private final UtilityReadingRepository utilityReadingRepository;
    private final InvoiceRepository invoiceRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        seedUsers();
        seedServices();
        seedSampleDataIfEmpty();
    }

    private void seedUsers() {
        if (userRepository.findByEmail("admin@motel.com").isEmpty()) {
            User admin = User.builder()
                    .email("admin@motel.com")
                    .password(passwordEncoder.encode("password123"))
                    .fullName("Nguyễn Văn Quản Lý")
                    .phone("0901234567")
                    .role("LANDLORD")
                    .build();
            userRepository.save(admin);
            log.info("Initialized default admin user: admin@motel.com / password123");
        }
    }

    private void seedServices() {
        if (serviceConfigRepository.count() == 0) {
            serviceConfigRepository.save(ServiceConfig.builder()
                    .serviceName("Điện sinh hoạt")
                    .unitPrice(3500.0)
                    .unit("kWh")
                    .calcMethod("METER")
                    .build());

            serviceConfigRepository.save(ServiceConfig.builder()
                    .serviceName("Nước sinh hoạt")
                    .unitPrice(25000.0)
                    .unit("m³")
                    .calcMethod("METER")
                    .build());

            serviceConfigRepository.save(ServiceConfig.builder()
                    .serviceName("Internet & WiFi")
                    .unitPrice(100000.0)
                    .unit("phòng/tháng")
                    .calcMethod("PER_ROOM")
                    .build());

            serviceConfigRepository.save(ServiceConfig.builder()
                    .serviceName("Rác sinh hoạt")
                    .unitPrice(30000.0)
                    .unit("phòng/tháng")
                    .calcMethod("PER_ROOM")
                    .build());

            log.info("Initialized standard service configs");
        }
    }

    private void seedSampleDataIfEmpty() {
        if (roomRepository.count() == 0) {
            // Seed Rooms
            Room p101 = roomRepository.save(Room.builder()
                    .roomCode("P101")
                    .name("Phòng 101 - Ban công")
                    .floor(1)
                    .area(25.0)
                    .monthlyRent(3500000.0)
                    .capacity(2)
                    .status(RoomStatus.OCCUPIED)
                    .description("Phòng thoáng mát, có ban công riêng")
                    .currentOccupancy(1)
                    .build());

            Room p102 = roomRepository.save(Room.builder()
                    .roomCode("P102")
                    .name("Phòng 102 - Tiêu chuẩn")
                    .floor(1)
                    .area(20.0)
                    .monthlyRent(3000000.0)
                    .capacity(2)
                    .status(RoomStatus.AVAILABLE)
                    .description("Phòng sạch sẽ, vệ sinh khép kín")
                    .currentOccupancy(0)
                    .build());

            Room p201 = roomRepository.save(Room.builder()
                    .roomCode("P201")
                    .name("Phòng 201 - View phố")
                    .floor(2)
                    .area(28.0)
                    .monthlyRent(3800000.0)
                    .capacity(3)
                    .status(RoomStatus.OCCUPIED)
                    .description("Phòng lớn tầng 2, đầy đủ nội thất")
                    .currentOccupancy(2)
                    .build());

            Room p202 = roomRepository.save(Room.builder()
                    .roomCode("P202")
                    .name("Phòng 202 - Cửa sổ lớn")
                    .floor(2)
                    .area(22.0)
                    .monthlyRent(3200000.0)
                    .capacity(2)
                    .status(RoomStatus.MAINTENANCE)
                    .description("Đang sơn sửa lại tường")
                    .currentOccupancy(0)
                    .build());

            // Seed Tenants
            Tenant t1 = tenantRepository.save(Tenant.builder()
                    .fullName("Trần Thị Thu Hà")
                    .phone("0912345678")
                    .identityCard("001198000123")
                    .email("ha.tran@gmail.com")
                    .hometown("Hải Phòng")
                    .status("ACTIVE")
                    .build());

            Tenant t2 = tenantRepository.save(Tenant.builder()
                    .fullName("Lê Hoàng Nam")
                    .phone("0988776655")
                    .identityCard("001199000456")
                    .email("nam.le@gmail.com")
                    .hometown("Nam Định")
                    .status("ACTIVE")
                    .build());

            Tenant t3 = tenantRepository.save(Tenant.builder()
                    .fullName("Nguyễn Minh Anh")
                    .phone("0933221100")
                    .identityCard("001200000789")
                    .email("anh.nguyen@gmail.com")
                    .hometown("Quảng Ninh")
                    .status("ACTIVE")
                    .build());

            // Seed Room Members
            roomMemberRepository.save(RoomMember.builder()
                    .room(p101)
                    .tenant(t1)
                    .role("PRIMARY")
                    .moveInDate(LocalDateTime.now().minusMonths(6))
                    .build());

            roomMemberRepository.save(RoomMember.builder()
                    .room(p201)
                    .tenant(t2)
                    .role("PRIMARY")
                    .moveInDate(LocalDateTime.now().minusMonths(3))
                    .build());

            roomMemberRepository.save(RoomMember.builder()
                    .room(p201)
                    .tenant(t3)
                    .role("MEMBER")
                    .moveInDate(LocalDateTime.now().minusMonths(3))
                    .build());

            // Seed Contracts
            contractRepository.save(Contract.builder()
                    .contractNumber("HD-2026-P101")
                    .room(p101)
                    .primaryTenant(t1)
                    .startDate(LocalDateTime.now().minusMonths(6))
                    .endDate(LocalDateTime.now().plusMonths(6))
                    .depositAmount(3500000.0)
                    .monthlyRent(3500000.0)
                    .status("ACTIVE")
                    .build());

            contractRepository.save(Contract.builder()
                    .contractNumber("HD-2026-P201")
                    .room(p201)
                    .primaryTenant(t2)
                    .startDate(LocalDateTime.now().minusMonths(3))
                    .endDate(LocalDateTime.now().plusMonths(9))
                    .depositAmount(3800000.0)
                    .monthlyRent(3800000.0)
                    .status("ACTIVE")
                    .build());

            // Seed Utility Readings
            utilityReadingRepository.save(UtilityReading.builder()
                    .room(p101)
                    .billingMonth("09/2026")
                    .previousElectricity(1250.0)
                    .currentElectricity(1380.0)
                    .previousWater(54.0)
                    .currentWater(62.0)
                    .readingDate(LocalDateTime.now().minusDays(5))
                    .build());

            utilityReadingRepository.save(UtilityReading.builder()
                    .room(p201)
                    .billingMonth("09/2026")
                    .previousElectricity(820.0)
                    .currentElectricity(970.0)
                    .previousWater(30.0)
                    .currentWater(41.0)
                    .readingDate(LocalDateTime.now().minusDays(5))
                    .build());

            // Seed Invoices
            invoiceRepository.save(Invoice.builder()
                    .invoiceNumber("INV-202609-P101")
                    .room(p101)
                    .billingMonth("09/2026")
                    .tenantName(t1.getFullName())
                    .roomAmount(3500000.0)
                    .electricityAmount(455000.0)
                    .waterAmount(200000.0)
                    .serviceAmount(130000.0)
                    .totalAmount(4285000.0)
                    .paidAmount(4285000.0)
                    .status("PAID")
                    .dueDate(LocalDateTime.now().plusDays(2))
                    .build());

            invoiceRepository.save(Invoice.builder()
                    .invoiceNumber("INV-202609-P201")
                    .room(p201)
                    .billingMonth("09/2026")
                    .tenantName(t2.getFullName())
                    .roomAmount(3800000.0)
                    .electricityAmount(525000.0)
                    .waterAmount(275000.0)
                    .serviceAmount(160000.0)
                    .totalAmount(4760000.0)
                    .paidAmount(0.0)
                    .status("UNPAID")
                    .dueDate(LocalDateTime.now().plusDays(5))
                    .build());

            log.info("Initialized complete sample data (rooms, tenants, contracts, utilities, invoices)");
        }
    }
}
