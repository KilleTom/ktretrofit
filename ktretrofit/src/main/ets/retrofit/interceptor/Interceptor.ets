import { HttpRequestConfig, Response } from '../client/HttpClient';

/**
 * Represents an interceptor that can intercept HTTP requests and responses.
 * Interceptors can modify requests before they are sent and responses before they are returned.
 */
export interface Interceptor {
  /**
   * Intercept a request and return a response.
   * @param chain The interceptor chain to proceed with.
   * @returns A Promise that resolves to the response.
   */
  intercept(chain: Interceptor.Chain): Promise<Response<any>>;
}

/**
 * Static members for the Interceptor interface.
 */
export namespace Interceptor {
  /**
   * Represents the interceptor chain for processing requests and responses.
   */
export interface Chain {
    /**
     * Proceed with the intercepted request.
     * @param config The request configuration to use for proceeding.
     * @returns A Promise that resolves to the response.
     */
    proceed(config: HttpRequestConfig): Promise<Response<any>>;

    /**
     * Get the current request configuration in the chain.
     * @returns The current request configuration.
     */
    request(): HttpRequestConfig;

    /**
     * Get the connection timeout in milliseconds.
     * @returns The connection timeout.
     */
    connectTimeout(): number;

    /**
     * Get the read timeout in milliseconds.
     * @returns The read timeout.
     */
    readTimeout(): number;

    /**
     * Get the write timeout in milliseconds.
     * @returns The write timeout.
     */
    writeTimeout(): number;
  }
}