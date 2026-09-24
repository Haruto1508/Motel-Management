package vn.edu.fpt.motelbackend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.motelbackend.entity.ServiceConfig;

import java.util.Optional;

@Repository
public interface ServiceConfigRepository extends JpaRepository<ServiceConfig, String> {
    Optional<ServiceConfig> findByServiceName(String serviceName);
}
