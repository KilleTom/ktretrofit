import { HttpMethod } from './http/method/HttpMethod';
import http from '@ohos.net.http';
import { MetadataUtil } from './MetadataUtil';

/**
 * Retrofit core class
 */
export class Retrofit {
  private baseUrl: string;
  private headers: Record<string, string> = {};
  private connectTimeout: number = 60000;
  private readTimeout: number = 60000;

  /**
   * Constructor for Retrofit instances
   * This constructor is public to ensure compatibility with ArkTS
   * Users should use RetrofitBuilder.build() instead of directly calling this constructor
   */
  constructor(builder: RetrofitBuilder) {
    this.baseUrl = builder.baseUrl;
    this.headers = { ...builder.headers };
    this.connectTimeout = builder.connectTimeout;
    this.readTimeout = builder.readTimeout;
  }

  /**
   * Create API service instance
   */
  create<T>(service: new () => T): T {
    const instance = new service();
    const prototype = Object.getPrototypeOf(instance);

    // Get all methods of the service
    const methods = Object.getOwnPropertyNames(prototype)
      .filter(name => name !== 'constructor')
      .map(name => ({ name, descriptor: Object.getOwnPropertyDescriptor(prototype, name)! }));

    // Wrap each method with HTTP request logic
    for (const { name, descriptor } of methods) {
      const originalMethod = descriptor.value;

      descriptor.value = async function(...args: any[]) {
        // Get method metadata
        const method = MetadataUtil.getMetadata('retrofit:method', prototype, name) as HttpMethod;
        const path = MetadataUtil.getMetadata('retrofit:path', prototype, name) as string;

        if (!method || !path) {
          throw new Error(`Method ${name} is not annotated with HTTP method decorator`);
        }

        // Get parameter metadata
        const queryParams = MetadataUtil.getMetadata('retrofit:params:query', prototype, name) || [];
        const queryMapParams = MetadataUtil.getMetadata('retrofit:params:queryMap', prototype, name) || [];
        const queryNameParams = MetadataUtil.getMetadata('retrofit:params:queryName', prototype, name) || [];
        const bodyParam = MetadataUtil.getMetadata('retrofit:params:body', prototype, name) || [];
        const headerParams = MetadataUtil.getMetadata('retrofit:params:header', prototype, name) || [];
        const headerMapParams = MetadataUtil.getMetadata('retrofit:params:headerMap', prototype, name) || [];
        const pathParams = MetadataUtil.getMetadata('retrofit:params:path', prototype, name) || [];
        const fieldParams = MetadataUtil.getMetadata('retrofit:params:field', prototype, name) || [];
        const fieldMapParams = MetadataUtil.getMetadata('retrofit:params:fieldMap', prototype, name) || [];
        const partParams = MetadataUtil.getMetadata('retrofit:params:part', prototype, name) || [];
        const partMapParams = MetadataUtil.getMetadata('retrofit:params:partMap', prototype, name) || [];
        const urlParams = MetadataUtil.getMetadata('retrofit:params:url', prototype, name) || [];
        const cookieParams = MetadataUtil.getMetadata('retrofit:params:cookie', prototype, name) || [];
        const tagParams = MetadataUtil.getMetadata('retrofit:params:tag', prototype, name) || [];

        // Check if method is form url encoded or multipart
        const isFormUrlEncoded = MetadataUtil.getMetadata('retrofit:formUrlEncoded', prototype, name) as boolean || false;
        const isMultipart = MetadataUtil.getMetadata('retrofit:multipart', prototype, name) as boolean || false;

        // Build URL
        let url = `${this.baseUrl}${path}`;

        // Replace with dynamic URL if provided
        if (urlParams.length > 0) {
          const dynamicUrl = args[urlParams[0].index];
          if (dynamicUrl) {
            url = dynamicUrl;
          }
        }

        // Replace path parameters
        for (const { index, key } of pathParams) {
          const value = args[index];
          url = url.replace(`{${key}}`, encodeURIComponent(value));
        }

        // Build query parameters
        const query = new Map<string, string>();
        for (const { index, key } of queryParams) {
          const value = args[index];
          if (value !== undefined && value !== null) {
            query.set(key, String(value));
          }
        }

        // Add query map parameters
        for (const { index } of queryMapParams) {
          const value = args[index];
          if (value !== undefined && value !== null && typeof value === 'object') {
            Object.entries(value).forEach(([k, v]) => {
              if (v !== undefined && v !== null) {
                query.set(k, String(v));
              }
            });
          }
        }

        // Add query name parameters
        for (const { index, key } of queryNameParams) {
          const value = args[index];
          if (value !== undefined && value !== null) {
            if (Array.isArray(value)) {
              value.forEach(v => {
                if (v !== undefined && v !== null) {
                  query.set(key, String(v));
                }
              });
            } else {
              query.set(key, String(value));
            }
          }
        }

        // Add query parameters to URL
        if (query.size > 0) {
          url += '?' + Array.from(query.entries())
            .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
            .join('&');
        }

        // Build headers
        const headers = { ...this.headers };
        for (const { index, key } of headerParams) {
          const value = args[index];
          if (value !== undefined && value !== null) {
            headers[key] = String(value);
          }
        }

        // Add header map parameters
        for (const { index } of headerMapParams) {
          const value = args[index];
          if (value !== undefined && value !== null && typeof value === 'object') {
            Object.entries(value).forEach(([k, v]) => {
              if (v !== undefined && v !== null) {
                headers[k] = String(v);
              }
            });
          }
        }

        // Add cookie parameters
        const cookies: string[] = [];
        for (const { index, key } of cookieParams) {
          const value = args[index];
          if (value !== undefined && value !== null) {
            cookies.push(`${key}=${encodeURIComponent(String(value))}`);
          }
        }
        if (cookies.length > 0) {
          headers['Cookie'] = cookies.join('; ');
        }

        // Get request body
        let body: any = null;
        if (bodyParam.length > 0) {
          body = args[bodyParam[0].index];
        }

        // Handle form url encoded
        if (isFormUrlEncoded) {
          const formData = new Map<string, string>();
          
          // Add field parameters
          for (const { index, key } of fieldParams) {
            const value = args[index];
            if (value !== undefined && value !== null) {
              formData.set(key, String(value));
            }
          }
          
          // Add field map parameters
          for (const { index } of fieldMapParams) {
            const value = args[index];
            if (value !== undefined && value !== null && typeof value === 'object') {
              Object.entries(value).forEach(([k, v]) => {
                if (v !== undefined && v !== null) {
                  formData.set(k, String(v));
                }
              });
            }
          }
          
          // Convert form data to URL encoded string
          body = Array.from(formData.entries())
            .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
            .join('&');
          
          headers['Content-Type'] = 'application/x-www-form-urlencoded';
        }

        // Handle multipart (simplified implementation)
        if (isMultipart) {
          // In a real implementation, this would handle file uploads and complex multipart data
          // For now, we'll just set the content type
          headers['Content-Type'] = 'multipart/form-data';
        }

        // 使用ArkTS实现HTTP请求
        const httpRequest = http.createHttp();
        try {
          // 将自定义HttpMethod枚举转换为ArkTS的RequestMethod枚举
          let requestMethod: http.RequestMethod;
          switch (method) {
            case HttpMethod.POST:
              requestMethod = http.RequestMethod.POST;
              break;
            case HttpMethod.PUT:
              requestMethod = http.RequestMethod.PUT;
              break;
            case HttpMethod.DELETE:
              requestMethod = http.RequestMethod.DELETE;
              break;
            // case HttpMethod.PATCH:
            //   requestMethod = http.RequestMethod.PATCH;
            //   break;
            case HttpMethod.HEAD:
              requestMethod = http.RequestMethod.HEAD;
              break;
            case HttpMethod.OPTIONS:
              requestMethod = http.RequestMethod.OPTIONS;
              break;
            default:
              requestMethod = http.RequestMethod.GET;
          }
          
          // 准备请求参数
          const requestOptions: http.HttpRequestOptions = {
            method: requestMethod,
            header: headers,
            extraData: body,
            connectTimeout: this.connectTimeout,
            readTimeout: this.readTimeout
          };

          // 发送请求
          const response = await httpRequest.request(url, requestOptions);

          // 处理响应
          if (response.responseCode === 200) {
            // 解析JSON响应
            return JSON.parse(response.result.toString());
          } else {
            // 处理错误响应
            throw new Error(`请求失败，状态码: ${response.responseCode}，响应内容: ${response.result}`);
          }
        } catch (error) {
          // 处理网络异常
          throw new Error(`网络错误: ${error}`);
        } finally {
          // 销毁HTTP请求资源
          httpRequest.destroy();
        }
      };

      Object.defineProperty(prototype, name, descriptor);
    }

    return instance;
  }
}

/**
 * Retrofit Builder class to configure and create Retrofit instances
 */
export class RetrofitBuilder {
  baseUrl: string;
  headers: Record<string, string> = {};
  connectTimeout: number = 60000;
  readTimeout: number = 60000;

  /**
   * Constructor with required base URL
   */
  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  /**
   * Add default header
   */
  addHeader(key: string, value: string): RetrofitBuilder {
    this.headers[key] = value;
    return this;
  }

  /**
   * Add multiple default headers
   */
  addHeaders(headers: Record<string, string>): RetrofitBuilder {
    this.headers = { ...this.headers, ...headers };
    return this;
  }

  /**
   * Set connection timeout in milliseconds
   */
  setConnectTimeout(timeout: number): RetrofitBuilder {
    this.connectTimeout = timeout;
    return this;
  }

  /**
   * Set read timeout in milliseconds
   */
  setReadTimeout(timeout: number): RetrofitBuilder {
    this.readTimeout = timeout;
    return this;
  }

  /**
     * Build and return a Retrofit instance
     */
    build(): Retrofit {
      return new Retrofit(this);
    }
  }

/**
 * Create Retrofit builder with base URL
 */
export function createRetrofit(baseUrl: string): RetrofitBuilder {
  return new RetrofitBuilder(baseUrl);
}