import { Interceptor } from './Interceptor';
import { HttpRequestConfig, Response, HttpClient } from '../client/HttpClient';

/**
 * Default implementation of {@link Interceptor.Chain} that processes a chain of interceptors.
 */
export class RealInterceptorChain implements Interceptor.Chain {
  private readonly interceptors: Interceptor[];
  private readonly index: number;
  private readonly _request: HttpRequestConfig;
  private readonly client: HttpClient;
  private readonly _connectTimeout: number;
  private readonly _readTimeout: number;
  private readonly _writeTimeout: number;

  /**
   * Create a new RealInterceptorChain.
   * @param interceptors The list of interceptors to process.
   * @param index The current index in the interceptor list.
   * @param request The request configuration.
   * @param client The HTTP client to use for executing the request.
   * @param connectTimeout The connection timeout in milliseconds.
   * @param readTimeout The read timeout in milliseconds.
   * @param writeTimeout The write timeout in milliseconds.
   */
  constructor(
    interceptors: Interceptor[],
    index: number,
    request: HttpRequestConfig,
    client: HttpClient,
    connectTimeout: number,
    readTimeout: number,
    writeTimeout: number
  ) {
    this.interceptors = interceptors;
    this.index = index;
    this._request = request;
    this.client = client;
    this._connectTimeout = connectTimeout;
    this._readTimeout = readTimeout;
    this._writeTimeout = writeTimeout;
  }

  /**
   * Get the current request configuration.
   * @returns The current request configuration.
   */
  request(): HttpRequestConfig {
    return this._request;
  }

  /**
   * Get the connection timeout.
   * @returns The connection timeout in milliseconds.
   */
  connectTimeout(): number {
    return this._connectTimeout;
  }

  /**
   * Get the read timeout.
   * @returns The read timeout in milliseconds.
   */
  readTimeout(): number {
    return this._readTimeout;
  }

  /**
   * Get the write timeout.
   * @returns The write timeout in milliseconds.
   */
  writeTimeout(): number {
    return this._writeTimeout;
  }

  /**
   * Proceed with the request through the next interceptor in the chain.
   * @param request The request configuration to use.
   * @returns A Promise that resolves to the response.
   */
  async proceed(request: HttpRequestConfig): Promise<Response<any>> {
    if (this.index >= this.interceptors.length) {
      // No more interceptors, execute the request directly
      return this.client.execute<any>(request);
    }

    // Create a new chain for the next interceptor
    const next = new RealInterceptorChain(
      this.interceptors,
      this.index + 1,
      request,
      this.client,
      this._connectTimeout,
      this._readTimeout,
      this._writeTimeout
    );

    // Get the current interceptor and call its intercept method
    const interceptor = this.interceptors[this.index];
    return interceptor.intercept(next);
  }
}