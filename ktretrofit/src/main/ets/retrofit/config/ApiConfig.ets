/**
 * Configuration interfaces for Retrofit
 */
import { HttpMethod } from '../http/method/HttpMethod';
import { HttpParameterType } from '../http/param/HttpParameterType';

/**
 * Configuration interface for API service methods (for HarmonyOS compatibility)
 */
export interface ApiServiceConfig<S> {
  /**
   * Map of method names to method configurations
   */
  methods: Record<string, ApiMethodConfig>;
  
  /**
   * Required service name for logging and error messages
   * Must be provided and cannot be empty or contain only whitespace characters
   */
  serviceName?: string;

}

/**
 * Configuration interface for individual API methods
 */
export interface ApiMethodConfig {
  /**
   * HTTP method type
   */
  method: HttpMethod;
  
  /**
   * Request path
   */
  path: string;
  
  /**
   * Whether the method uses form URL encoding
   */
  isFormEncoded?: boolean;
  
  /**
   * Whether the method uses multipart encoding
   */
  isMultipart?: boolean;
  
  /**
   * Map of parameter indices to parameter configurations
   */
  parameters?: Record<number, ApiParameterConfig>;
}

/**
 * Configuration interface for API parameters
 */
export interface ApiParameterConfig {
  /**
   * Parameter type
   */
  type: HttpParameterType;
  
  /**
   * Parameter name (for path, query, header, field types)
   */
  name?: string;
}