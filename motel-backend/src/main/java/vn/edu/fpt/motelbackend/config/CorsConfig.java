package vn.edu.fpt.motelbackend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;
import java.util.List;

@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        // Allow any origin during development
        config.addAllowedOriginPattern("*");
        // Allow all HTTP methods
        config.addAllowedMethod("*");
        // Allow any headers (including Authorization, Content-Type, etc.)
        config.addAllowedHeader("*");
        // Expose all headers to the client
        config.addExposedHeader("*");
        // Enable sending cookies / Authorization header
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}
