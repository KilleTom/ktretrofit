/**
 * Default implementation of {@link Call} that uses the {@link HttpClient} to execute requests.
 */
import { HttpClient } from '../client/HttpClient';
import { ConverterFactory } from '../converter/Converter';
import { Call } from './Call';
import { Response } from '../response/Response';

export class OkHttpCall<T> implements Call<T> {
    private readonly client: HttpClient;
    private readonly requestConfig: any;
    private readonly converterFactories: ConverterFactory[];
    private executed: boolean = false;
    private canceled: boolean = false;

    constructor(client: HttpClient, requestConfig: any, converterFactories: ConverterFactory[]) {
      this.client = client;
      this.requestConfig = requestConfig;
      this.converterFactories = converterFactories;
    }

    execute(): Response<T> {
    if (this.executed) {
      throw new Error('Already executed. Use clone() to make multiple calls.');
    }

    if (this.canceled) {
      throw new Error('Canceled');
    }

    this.executed = true;

    // Build the final HTTP request configuration
    const httpRequestConfig = {
      url: this.buildUrlWithQueryParams(),
      method: this.requestConfig.method,
      headers: this.requestConfig.headers,
      body: this.requestConfig.body,
      connectTimeout: 60000,
      readTimeout: 60000
    };

    // Execute the request with the client (blocks current thread)
    const response = this.client.execute<T>(httpRequestConfig);
    // Use converter factories to convert the response data if needed
    return this.convertResponseData(response);
  }

  enqueue(onResponse: (response: Response<T>) => void, onFailure: (error: Error) => void): void {
    if (this.executed) {
      onFailure(new Error('Already executed. Use clone() to make multiple calls.'));
      return;
    }

    if (this.canceled) {
      onFailure(new Error('Canceled'));
      return;
    }

    this.executed = true;

    // Build the final HTTP request configuration
    const httpRequestConfig = {
      url: this.buildUrlWithQueryParams(),
      method: this.requestConfig.method,
      headers: this.requestConfig.headers,
      body: this.requestConfig.body,
      connectTimeout: 60000,
      readTimeout: 60000
    };

    // Use the client's enqueue method for asynchronous execution
    this.client.enqueue<T>(
      httpRequestConfig,
      (response) => {
        // Convert the response data if needed
        const convertedResponse = this.convertResponseData(response);
        onResponse(convertedResponse);
      },
      (error) => {
        onFailure(error);
      }
    );
  }

  cancel(): void {
    this.canceled = true;
  }

  isExecuted(): boolean {
    return this.executed;
  }

  isCanceled(): boolean {
    return this.canceled;
  }

  clone(): Call<T> {
      return new OkHttpCall<T>(this.client, { ...this.requestConfig }, this.converterFactories);
    }

    /**
     * Convert the response data using the available converter factories.
     */
    private convertResponseData(response: Response<T>): Response<T> {
      if (!response.isSuccessful || !response.body) {
        return response;
      }

      // Try to find a suitable converter factory
      for (const factory of this.converterFactories) {
        // Since we don't have access to the actual type at runtime, try with object type
        const converter = factory.responseBodyConverter(Object);
        if (converter) {
          try {
              const convertedBody = converter.convert(response.body);
              return new Response<T>(response.code, response.message, convertedBody as T, response.headers);
            } catch (e) {
              // Failed to convert with this factory, try next one
              continue;
            }
        }
      }

      // If no converter found, return the original response
      return response;
    }

  private buildUrlWithQueryParams(): string {
    const { url, queryParams } = this.requestConfig;
    
    if (!queryParams || Object.keys(queryParams).length === 0) {
      return url;
    }

    const queryString = Object.entries(queryParams)
      .map(([key, value]) => `${encodeURIComponent(String(key))}=${encodeURIComponent(value !== undefined && value !== null ? String(value) : '')}`)
      .join('&');

    return url + (url.includes('?') ? '&' : '?') + queryString;
  }
}