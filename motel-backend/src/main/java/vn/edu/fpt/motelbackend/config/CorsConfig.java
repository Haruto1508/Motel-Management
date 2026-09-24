package vn.edu.fpt.motelbackend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

/**
 * Global CORS configuration.
 * - CorsConfigurationSource bean: used by Spring Security's http.cors(withDefaults())
 * - CorsFilter bean:              handles pre-flight OPTIONS at the servlet filter level
 * Both beans share the same permissive settings for development.
 */
@Configuration
public class CorsConfig {

    private UrlBasedCorsConfigurationSource buildSource() {
        CorsConfiguration config = new CorsConfiguration();
        // Allow any origin during development – restrict in production
        config.addAllowedOriginPattern("*");
        // Allow all HTTP methods (GET, POST, PUT, DELETE, OPTIONS, …)
        config.addAllowedMethod("*");
        // Allow all request headers (Authorization, Content-Type, etc.)
        config.addAllowedHeader("*");
        // Expose all response headers to the client
        config.addExposedHeader("*");
        // Enable Authorization header / credentials
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    /** Used by Spring Security filterChain via http.cors(Customizer.withDefaults()) */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        return buildSource();
    }

    /** Handles pre-flight OPTIONS requests at the servlet level */
    @Bean
    public CorsFilter corsFilter() {
        return new CorsFilter(buildSource());
    }
}
