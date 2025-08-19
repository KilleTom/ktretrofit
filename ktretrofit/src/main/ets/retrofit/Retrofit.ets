/**
 * Retrofit
 * A type-safe HTTP client for Android and Java/Kotlin.
 * This implementation is modeled after the official Retrofit library.
 */

import { HttpClient, HttpClientBuilder, Interceptor } from './client/HttpClient';
import { ConverterFactory, StringConverterFactory, JsonConverterFactory } from './converter/Converter';
import { Call, CallFactory } from './call/Call';
import { MetadataUtil } from './util/MetadataUtil';
import { HttpParameterType } from './http/param/HttpParameterType';
import { HttpMethod } from './http/method/HttpMethod';
import { ApiServiceConfig,  } from './config/ApiConfig';
import { DefaultCallFactory } from './call/DefaultCallFactory';

/**
 * Main class for creating and configuring API service instances.
 * Note: This class should only be instantiated through the RetrofitBuilder.
 */
export class Retrofit {
  private readonly baseUrl: string;
  private readonly client: HttpClient;
  private readonly converterFactories: ConverterFactory[];
  private readonly callFactory: CallFactory;

  /**
   * Private constructor - instances should be created using RetrofitBuilder.
   * This constructor is public for technical reasons in ArkTS but should not be called directly.
   */
  constructor(builder: RetrofitBuilder) {
    this.baseUrl = builder.baseUrl;
    this.client = builder.client;
    this.converterFactories = builder.converterFactories;
    this.callFactory = new DefaultCallFactory(this.client, this.converterFactories);
  }

  /**
   * Create an implementation of the API defined by the provided ApiServiceConfig.
   * @param config The ApiServiceConfig defining the API service to create.
   * @return An implementation of the API service interface.
   */
  configService<T>(config: ApiServiceConfig<T>): T {

    if (!config || !config.methods) {
      throw new Error('Valid ApiServiceConfig must be provided');
    }

    const currentServiceName = config.serviceName
    // Check if serviceName is provided and valid

    if (!currentServiceName || currentServiceName.trim() === '') {
      throw new Error('ApiServiceConfig.serviceName is required and cannot be empty or whitespace');
    }

    const proxy: Record<string, any> = {};
    
    // Process each method configuration
    for (const [methodName, methodConfig] of Object.entries(config.methods)) {
      proxy[methodName] = (...args: any[]) => {
        // Create a mock method object with metadata
        const mockMethod = function() {};
        
        // Apply HTTP method and path metadata
        MetadataUtil.defineHttpMethod(HttpMethod[methodConfig.method], methodConfig.path, mockMethod, methodName);
        
        // Apply form encoded/multipart metadata if specified
        if (methodConfig.isFormEncoded) {
          MetadataUtil.markFormUrlEncoded(mockMethod, methodName);
        }
        if (methodConfig.isMultipart) {
          MetadataUtil.markMultipart(mockMethod, methodName);
        }
        
        // Apply parameter metadata
        if (methodConfig.parameters) {
          for (const [paramIndex, paramConfig] of Object.entries(methodConfig.parameters)) {
            const index = Number(paramIndex);
            
            switch (paramConfig.type) {
              case HttpParameterType.PATH:
                MetadataUtil.definePathParameter(index, paramConfig.name, mockMethod, methodName);
                break;
              case HttpParameterType.QUERY:
                MetadataUtil.defineQueryParameter(index, paramConfig.name, mockMethod, methodName);
                break;
              case HttpParameterType.QUERY_MAP:
                MetadataUtil.defineQueryMapParameter(index, mockMethod, methodName);
                break;
              case HttpParameterType.HEADER:
                MetadataUtil.defineHeaderParameter(index, paramConfig.name, mockMethod, methodName);
                break;
              case HttpParameterType.HEADER_MAP:
                MetadataUtil.defineHeaderMapParameter(index, mockMethod, methodName);
                break;
              case HttpParameterType.BODY:
                MetadataUtil.defineBodyParameter(index, mockMethod, methodName);
                break;
              case HttpParameterType.FIELD:
                MetadataUtil.defineFieldParameter(index, paramConfig.name, mockMethod, methodName);
                break;
              case HttpParameterType.FIELD_MAP:
                MetadataUtil.defineFieldMapParameter(index, mockMethod, methodName);
                break;
              case HttpParameterType.PART:
              case HttpParameterType.PART_MAP:
              case HttpParameterType.URL:
              case HttpParameterType.COOKIE:
              case HttpParameterType.TAG:
              case HttpParameterType.QUERY_NAME:
                // For other parameter types
                const params = MetadataUtil.getMetadata(`retrofit:params:${HttpParameterType[paramConfig.type]}`, mockMethod, methodName) || [];
                params.push({ index, key: paramConfig.name });
                MetadataUtil.defineMetadata(`retrofit:params:${HttpParameterType[paramConfig.type]}`, params, mockMethod, methodName);
                break;
            }
          }
        }
        

        return this.createCall(mockMethod, args, currentServiceName, methodName);
      };
    }
    
    return proxy as T;
  }

  private createCall(method: Function, args: any[], serviceName: string, methodName: string): Call<any> {
    const metadata = MetadataUtil.getMethodMetadata(method);
    
    if (!metadata) {
      throw new Error(`No HTTP method annotation found for ${serviceName}.${methodName}`);
    }

    const httpMethod = metadata.httpMethod;
    let path = metadata.path || '';
    const isFormEncoded = metadata.isFormEncoded || false;
    const isMultipart = metadata.isMultipart || false;

    // Process path parameters
    const pathParams = MetadataUtil.getPathParameters(method);
    if (pathParams) {
      for (const [paramIndex, paramName] of Object.entries(pathParams)) {
        const value = args[Number(paramIndex)];
        if (value !== undefined) {
          path = path.replace(new RegExp(`\\{${paramName}\\}`, 'g'), encodeURIComponent(value));
        }
      }
    }

    // Build URL
    const url = this.createUrl(this.baseUrl, path);

    // Create request configuration
    const requestConfig = {
      url,
      method: httpMethod,
      headers: this.buildHeaders(method, args),
      body: this.buildRequestBody(method, args, isFormEncoded, isMultipart),
      queryParams: this.buildQueryParams(method, args),
      isFormEncoded,
      isMultipart
    };

    // Create and return a Call object
    return this.callFactory.newCall<any>(requestConfig);
  }

  private createUrl(baseUrl: string, path: string): string {
    let url = baseUrl;
    
    // Ensure baseUrl ends with / if path starts with /
    if (path.startsWith('/') && !url.endsWith('/')) {
      url += '/';
    }
    
    // Ensure baseUrl doesn't have duplicate / with path
    if (!path.startsWith('/') && url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    
    return url + path;
  }

  private buildHeaders(method: Function, args: any[]): Record<string, string> {
    const headers: Record<string, string> = {};
    const headerParams = MetadataUtil.getHeaderParameters(method);
    const headerMapParams = MetadataUtil.getHeaderMapParameters(method);

    if (headerParams) {
      for (const [paramIndex, paramName] of Object.entries(headerParams)) {
        const value = args[Number(paramIndex)];
        if (value !== undefined) {
          headers[paramName] = value.toString();
        }
      }
    }

    if (headerMapParams) {
      for (const paramIndex of headerMapParams) {
        const headerMap = args[Number(paramIndex)];
        if (headerMap && typeof headerMap === 'object') {
          for (const [key, value] of Object.entries(headerMap)) {
            headers[key] = value.toString();
          }
        }
      }
    }

    return headers;
  }

  private buildQueryParams(method: Function, args: any[]): Record<string, string> {
    const queryParams: Record<string, string> = {};
    const queryParamsMap = MetadataUtil.getQueryParameters(method);
    const queryMapParams = MetadataUtil.getQueryMapParameters(method);

    if (queryParamsMap) {
      for (const [paramIndex, paramName] of Object.entries(queryParamsMap)) {
        const value = args[Number(paramIndex)];
        if (value !== undefined) {
          queryParams[paramName] = value.toString();
        }
      }
    }

    if (queryMapParams) {
      for (const paramIndex of queryMapParams) {
        const queryMap = args[Number(paramIndex)];
        if (queryMap && typeof queryMap === 'object') {
          for (const [key, value] of Object.entries(queryMap)) {
            queryParams[key] = value.toString();
          }
        }
      }
    }

    return queryParams;
  }

  private buildRequestBody(method: Function, args: any[], isFormEncoded: boolean, isMultipart: boolean): any {
    const bodyParam = MetadataUtil.getBodyParameter(method);
    const fieldParams = MetadataUtil.getFieldParameters(method);
    const fieldMapParams = MetadataUtil.getFieldMapParameters(method);
    const partParams = MetadataUtil.getPartParameters(method);
    const partMapParams = MetadataUtil.getPartMapParameters(method);

    if (bodyParam !== -1) {
      return args[bodyParam];
    }

    if (isFormEncoded) {
      const formData: Record<string, string> = {};
      
      if (fieldParams) {
        for (const [paramIndex, paramName] of Object.entries(fieldParams)) {
          const value = args[Number(paramIndex)];
          if (value !== undefined) {
            formData[paramName] = value.toString();
          }
        }
      }

      if (fieldMapParams) {
        for (const paramIndex of fieldMapParams) {
          const fieldMap = args[Number(paramIndex)];
          if (fieldMap && typeof fieldMap === 'object') {
            for (const [key, value] of Object.entries(fieldMap)) {
              formData[key] = value.toString();
            }
          }
        }
      }

      // Use JSON converter for form data to ensure type safety
      for (const factory of this.converterFactories) {
        const converter = factory.requestBodyConverter(Object);
        if (converter) {
          try {
            return converter.convert(formData);
          } catch (e) {
            // Failed to convert with this factory, continue
            continue;
          }
        }
      }
      
      return formData;
    } else if (isMultipart) {
      const multipartData: Record<string, any> = { parts: [] };
      
      // Process part parameters
      if (partParams) {
        for (const [paramIndex, paramName] of Object.entries(partParams)) {
          const value = args[Number(paramIndex)];
          if (value !== undefined) {
            multipartData.parts.push({
              name: paramName,
              value: value
            });
          }
        }
      }

      // Process part map parameters
      if (partMapParams) {
        for (const paramIndex of partMapParams) {
          const partMap = args[Number(paramIndex)];
          if (partMap && typeof partMap === 'object') {
            for (const [key, value] of Object.entries(partMap)) {
              multipartData.parts.push({
                name: key,
                value: value
              });
            }
          }
        }
      }

      // Use JSON converter for multipart data to ensure type safety
      for (const factory of this.converterFactories) {
        const converter = factory.requestBodyConverter(Object);
        if (converter) {
          try {
            return converter.convert(multipartData);
          } catch (e) {
            // Failed to convert with this factory, continue
            continue;
          }
        }
      }
      
      return multipartData;
    }

    return null;
  }

  /**
   * Returns a new {@link RetrofitBuilder} to create a new {@link Retrofit} instance.
   */
  static builder(): RetrofitBuilder {
    return new RetrofitBuilder();
  }
}

/**
 * Builder for creating {@link Retrofit} instances.
 */
export class RetrofitBuilder {
    baseUrl: string = '';
    client: HttpClient = new HttpClientBuilder().build();
    converterFactories: ConverterFactory[] = [
      StringConverterFactory.create(),
      JsonConverterFactory.create()
    ];
    defaultHeaders: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };

    /**
     * Set the base URL for HTTP requests.
     */
    setBaseUrl(baseUrl: string): RetrofitBuilder {
      this.baseUrl = baseUrl;
      return this;
    }

    /**
     * Set the HTTP client to use for requests.
     */
    setHttpClient(client: HttpClient): RetrofitBuilder {
      this.client = client;
      return this;
    }

    /**
     * Add a converter factory for serialization and deserialization of objects.
     */
    addConverterFactory(factory: ConverterFactory): RetrofitBuilder {
      this.converterFactories.unshift(factory);
      return this;
    }

    /**
     * Add a default header to all requests.
     */
    addHeader(key: string, value: string): RetrofitBuilder {
      this.defaultHeaders[key] = value;
      return this;
    }

    /**
     * Add multiple default headers to all requests.
     */
    addHeaders(headers: Record<string, string>): RetrofitBuilder {
      this.defaultHeaders = { ...this.defaultHeaders, ...headers };
      return this;
    }

    /**
     * Add an interceptor to the HTTP client.
     * @param interceptor The interceptor to add.
     * @returns This builder instance for method chaining.
     */
    addInterceptor(interceptor: Interceptor): RetrofitBuilder {
      // Create a new HttpClientBuilder with the existing client's configuration
      const newClientBuilder = new HttpClientBuilder();

      // Add all existing interceptors from the current client
      if (typeof (this.client as any).interceptors === 'object') {
        newClientBuilder.addInterceptors((this.client as any).interceptors || []);
      }

      // Add the new interceptor
      newClientBuilder.addInterceptor(interceptor);

      // Update the client with the new builder
      this.client = newClientBuilder.build();
      return this;
    }

    /**
     * Add multiple interceptors to the HTTP client.
     * @param interceptors The list of interceptors to add.
     * @returns This builder instance for method chaining.
     */
    addInterceptors(interceptors: Interceptor[]): RetrofitBuilder {
      // Create a new HttpClientBuilder with the existing client's configuration
      const newClientBuilder = new HttpClientBuilder();

      // Add all existing interceptors from the current client
      if (typeof (this.client as any).interceptors === 'object') {
        newClientBuilder.addInterceptors((this.client as any).interceptors || []);
      }

      // Add the new interceptors
      newClientBuilder.addInterceptors(interceptors);

      // Update the client with the new builder
      this.client = newClientBuilder.build();
      return this;
    }

    /**
     * Set the connection timeout for HTTP requests.
     * @param timeout Timeout in milliseconds.
     * @returns This builder instance for method chaining.
     */
    setConnectTimeout(timeout: number): RetrofitBuilder {
      // Create a new HttpClientBuilder with the existing client's configuration
      const newClientBuilder = new HttpClientBuilder();
      
      // Add all existing interceptors from the current client
      if (typeof (this.client as any).interceptors === 'object') {
        newClientBuilder.addInterceptors((this.client as any).interceptors || []);
      }
      
      // Set the new connect timeout
      newClientBuilder.setConnectTimeout(timeout);
      
      // Update the client with the new builder
      this.client = newClientBuilder.build();
      return this;
    }
    
    /**
     * Set the read timeout for HTTP requests.
     * @param timeout Timeout in milliseconds.
     * @returns This builder instance for method chaining.
     */
    setReadTimeout(timeout: number): RetrofitBuilder {
      // Create a new HttpClientBuilder with the existing client's configuration
      const newClientBuilder = new HttpClientBuilder();
      
      // Add all existing interceptors from the current client
      if (typeof (this.client as any).interceptors === 'object') {
        newClientBuilder.addInterceptors((this.client as any).interceptors || []);
      }
      
      // Set the new read timeout
      newClientBuilder.setReadTimeout(timeout);
      
      // Update the client with the new builder
      this.client = newClientBuilder.build();
      return this;
    }

    /**
   * Build the {@link Retrofit} instance.
   */
  build(): Retrofit {
    if (!this.baseUrl) {
      throw new Error('Base URL is required');
    }

    return new Retrofit(this);
  }
}




/**
 * Helper function to create a new {@link RetrofitBuilder} instance.
 * @param baseUrl Optional base URL to set immediately on the builder
 */
export function createRetrofit(baseUrl?: string): RetrofitBuilder {
  const builder = Retrofit.builder();
  if (baseUrl) {
    builder.setBaseUrl(baseUrl);
  }
  return builder;
}