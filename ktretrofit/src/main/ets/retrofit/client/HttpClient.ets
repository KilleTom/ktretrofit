/**
 * Abstraction for an HTTP client that can execute HTTP requests.
 * This is modeled after OkHttpClient in the official Retrofit.
 */
import http from '@ohos.net.http';
import { Response } from '../response/Response';
import { Interceptor } from '../interceptor/Interceptor';
import { InterceptorHttpClient } from '../interceptor/InterceptorHttpClient';
import { Semaphore } from '../util/Semaphore';

/**
 * Configuration for an HTTP request.
 */
export interface HttpRequestConfig {
  /**
   * The URL to make the request to.
   */
  url: string;

  /**
   * The HTTP method (GET, POST, etc.).
   */
  method: string;

  /**
   * HTTP headers to include with the request.
   */
  headers?: Record<string, string>;

  /**
   * The request body.
   */
  body?: any;

  /**
   * Connection timeout in milliseconds.
   */
  connectTimeout?: number;

  /**
   * Read timeout in milliseconds.
   */
  readTimeout?: number;

  /**
   * Write timeout in milliseconds.
   */
  writeTimeout?: number;

  /**
   * Whether to follow redirects.
   */
  followRedirects?: boolean;

  /**
   * Additional options specific to the underlying HTTP client.
   */
  extraOptions?: Record<string, any>;
}

/**
 * An HTTP client that can execute requests.
 */
export interface HttpClient {
  /**
   * Execute an HTTP request synchronously and return the response directly.
   * This method will block the calling thread until the request completes.
   */
  execute<T>(config: HttpRequestConfig): Response<T>;

  /**
   * Execute an HTTP request asynchronously on a separate thread.
   * @param config The request configuration.
   * @param onResponse Callback for successful responses.
   * @param onFailure Callback for failed requests.
   */
  enqueue<T>(config: HttpRequestConfig, onResponse: (response: Response<T>) => void, onFailure: (error: Error) => void): void;

  /**
   * Cancel all ongoing requests.
   */
  cancelAll(): void;

  /**
   * Close the client and release resources.
   */
  close(): void;
}

/**
 * Default implementation of {@link HttpClient} using ArkTS http module.
 */
export class DefaultHttpClient implements HttpClient {
  private requests: Map<string, http.HttpRequest> = new Map();
  private counter: number = 0;
  private connectTimeout: number = 60000;
  private readTimeout: number = 60000;
  private writeTimeout: number = 60000;
  private followRedirects: boolean = true;

  constructor(config?: { connectTimeout?: number, readTimeout?: number, writeTimeout?: number, followRedirects?: boolean }) {
    if (config) {
      this.connectTimeout = config.connectTimeout ?? this.connectTimeout;
      this.readTimeout = config.readTimeout ?? this.readTimeout;
      this.writeTimeout = config.writeTimeout ?? this.writeTimeout;
      this.followRedirects = config.followRedirects ?? this.followRedirects;
    }
  }

  execute<T>(config: HttpRequestConfig): Response<T> {
    const requestId = `request-${this.counter++}`;
    const httpRequest = http.createHttp();
    this.requests.set(requestId, httpRequest);

    try {
      // 获取转换后的方法
      const convertedMethod = this.convertMethod(config.method);
      
      // 创建请求头的副本
      let requestHeaders = { ...(config.headers || {}) };
      
      // 处理PATCH请求：如果原始方法是PATCH但转换后的方法是POST
      // 添加X-Override-Method头部以确保服务器正确识别请求类型
      if (config.method.toUpperCase() === 'PATCH' && convertedMethod === http.RequestMethod.POST) {
        requestHeaders['X-Override-Method'] = 'PATCH';
      }
      
      const requestOptions: http.HttpRequestOptions = {
        method: convertedMethod,
        header: requestHeaders,
        extraData: config.body,
        connectTimeout: config.connectTimeout ?? this.connectTimeout,
        readTimeout: config.readTimeout ?? this.readTimeout,
        // 注意：ArkTS的http模块目前不直接支持writeTimeout配置
        // 如果需要支持，可能需要通过额外的方式实现
      };

      // 注意：ArkTS的http模块目前不直接支持followRedirects配置
      // 可以根据需要在此处添加相关处理逻辑

      // 使用Promise的同步等待方式实现同步请求
      let responseData: http.HttpResponse | undefined;
      let errorData: Error | undefined;
      const semaphore = new Semaphore();
      
      httpRequest.request(config.url, requestOptions)
        .then(response => {
          responseData = response;
        })
        .catch(error => {
          errorData = error as Error;
        })
        .finally(() => {
          semaphore.release();
        });
      
      // 等待请求完成
      semaphore.acquire();
      
      if (errorData) {
        throw errorData instanceof Error ? errorData : new Error('Request failed');
      }
      
      if (!responseData) {
        throw new Error('No response received');
      }
      
      this.requests.delete(requestId);

      let body: T | null = null;
      if (responseData.result) {
        try {
          body = JSON.parse(responseData.result.toString()) as T;
        } catch (e) {
          body = responseData.result.toString() as unknown as T;
        }
      }

      // Convert response.header to Record<string, string> to avoid type errors
      const responseHeaders: Record<string, string> = {};
      if (responseData.header && typeof responseData.header === 'object') {
        for (const [key, value] of Object.entries(responseData.header)) {
          responseHeaders[key] = String(value);
        }
      }

      return new Response<T>(
        responseData.responseCode,
        this.getStatusMessage(responseData.responseCode),
        body,
        responseHeaders,
        config,
        responseData
      );
    } catch (error) {
      this.requests.delete(requestId);
      throw error instanceof Error ? error : new Error(String(error));
    }
  }

  enqueue<T>(config: HttpRequestConfig, onResponse: (response: Response<T>) => void, onFailure: (error: Error) => void): void {
    const requestId = `request-${this.counter++}`;
    const httpRequest = http.createHttp();
    this.requests.set(requestId, httpRequest);

    try {
      // 获取转换后的方法
      const convertedMethod = this.convertMethod(config.method);
      
      // 创建请求头的副本
      let requestHeaders = { ...(config.headers || {}) };
      
      // 处理PATCH请求：如果原始方法是PATCH但转换后的方法是POST
      // 添加X-Override-Method头部以确保服务器正确识别请求类型
      if (config.method.toUpperCase() === 'PATCH' && convertedMethod === http.RequestMethod.POST) {
        requestHeaders['X-Override-Method'] = 'PATCH';
      }
      
      const requestOptions: http.HttpRequestOptions = {
        method: convertedMethod,
        header: requestHeaders,
        extraData: config.body,
        connectTimeout: config.connectTimeout ?? this.connectTimeout,
        readTimeout: config.readTimeout ?? this.readTimeout,
      };

      // 异步执行请求
      httpRequest.request(config.url, requestOptions)
        .then(responseData => {
          this.requests.delete(requestId);

          let body: T | null = null;
          if (responseData.result) {
            try {
              body = JSON.parse(responseData.result.toString()) as T;
            } catch (e) {
              body = responseData.result.toString() as unknown as T;
            }
          }

          // Convert response.header to Record<string, string>
          const responseHeaders: Record<string, string> = {};
          if (responseData.header && typeof responseData.header === 'object') {
            for (const [key, value] of Object.entries(responseData.header)) {
              responseHeaders[key] = String(value);
            }
          }

          const response = new Response<T>(
            responseData.responseCode,
            this.getStatusMessage(responseData.responseCode),
            body,
            responseHeaders,
            config,
            responseData
          );

          onResponse(response);
        })
        .catch(error => {
          this.requests.delete(requestId);
          onFailure(error as Error);
        });
    } catch (error) {
      this.requests.delete(requestId);
      onFailure(error as Error);
    }
  }

  cancelAll(): void {
    for (const [, request] of this.requests.entries()) {
      try {
        request.destroy();
      } catch (e) {
        // Ignore errors when canceling requests
      }
    }
    this.requests.clear();
  }

  close(): void {
    this.cancelAll();
  }

  private convertMethod(method: string): http.RequestMethod {    
    // 检查http模块是否支持PATCH方法
    const methodUpper = method.toUpperCase();
    
    switch (methodUpper) {
      case 'POST':
        return http.RequestMethod.POST;
      case 'PUT':
        return http.RequestMethod.PUT;
      case 'DELETE':
        return http.RequestMethod.DELETE;
      case 'HEAD':
        return http.RequestMethod.HEAD;
      case 'OPTIONS':
        return http.RequestMethod.OPTIONS;
      case 'PATCH':
        // 由于RequestMethod不存在PATCH用法，我们直接使用POST方法
        // 并在execute方法中添加X-Override-Method请求头来标识这是一个PATCH请求
        console.warn('PATCH method is not directly supported, using POST with X-Override-Method header');
        return http.RequestMethod.POST;
      default:
        return http.RequestMethod.GET;
    }
  }

  private getStatusMessage(statusCode: number): string {
    const messages: Record<number, string> = {
      200: 'OK',
      201: 'Created',
      202: 'Accepted',
      204: 'No Content',
      400: 'Bad Request',
      401: 'Unauthorized',
      403: 'Forbidden',
      404: 'Not Found',
      500: 'Internal Server Error',
      501: 'Not Implemented',
      502: 'Bad Gateway',
      503: 'Service Unavailable',
    };
    return messages[statusCode] || `HTTP ${statusCode}`;
  }
}

/**
 * Builder for creating {@link DefaultHttpClient} instances with custom configuration.
 */
export class HttpClientBuilder {
  private connectTimeout: number = 60000;
  private readTimeout: number = 60000;
  private writeTimeout: number = 60000;
  private followRedirects: boolean = true;
  private defaultHeaders: Record<string, string> = {};
  private interceptors: Interceptor[] = [];

  setConnectTimeout(timeout: number): HttpClientBuilder {
    this.connectTimeout = timeout;
    return this;
  }

  setReadTimeout(timeout: number): HttpClientBuilder {
    this.readTimeout = timeout;
    return this;
  }

  setWriteTimeout(timeout: number): HttpClientBuilder {
    this.writeTimeout = timeout;
    return this;
  }

  setFollowRedirects(follow: boolean): HttpClientBuilder {
    this.followRedirects = follow;
    return this;
  }

  addHeader(key: string, value: string): HttpClientBuilder {
    this.defaultHeaders[key] = value;
    return this;
  }

  addHeaders(headers: Record<string, string>): HttpClientBuilder {
    this.defaultHeaders = { ...this.defaultHeaders, ...headers };
    return this;
  }

  /**
   * Add an interceptor to the HTTP client.
   * @param interceptor The interceptor to add.
   * @returns This builder instance for method chaining.
   */
  addInterceptor(interceptor: Interceptor): HttpClientBuilder {
    this.interceptors.push(interceptor);
    return this;
  }

  /**
   * Add multiple interceptors to the HTTP client.
   * @param interceptors The list of interceptors to add.
   * @returns This builder instance for method chaining.
   */
  addInterceptors(interceptors: Interceptor[]): HttpClientBuilder {
    this.interceptors.push(...interceptors);
    return this;
  }

  build(): HttpClient {
    // Create a new client instance with the configured settings
    const defaultClient = new DefaultHttpClient({
      connectTimeout: this.connectTimeout,
      readTimeout: this.readTimeout,
      writeTimeout: this.writeTimeout,
      followRedirects: this.followRedirects
    });
    
    // If there are interceptors, wrap the default client with InterceptorHttpClient
    if (this.interceptors.length > 0) {
      return new InterceptorHttpClient(defaultClient, this.interceptors);
    }
    
    return defaultClient;
  }
}

export { Interceptor, Response };
