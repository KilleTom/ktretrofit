import { HttpClient, HttpRequestConfig, Response } from '../client/HttpClient';
import { Interceptor } from './Interceptor';
import { RealInterceptorChain } from './RealInterceptorChain';
import { Semaphore } from '../util/Semaphore';

/**
 * An {@link HttpClient} implementation that supports interceptors.
 * This class wraps a delegate {@link HttpClient} and applies interceptors to requests.
 */
export class InterceptorHttpClient implements HttpClient {
  private readonly delegate: HttpClient;
  private readonly interceptors: Interceptor[];

  /**
   * Create a new InterceptorHttpClient.
   * @param delegate The underlying HttpClient to delegate to.
   * @param interceptors The list of interceptors to apply to requests.
   */
  constructor(delegate: HttpClient, interceptors: Interceptor[] = []) {
    this.delegate = delegate;
    this.interceptors = interceptors;
  }

  /**
   * Execute an HTTP request synchronously with interceptors applied.
   * This method will block the calling thread until the request completes.
   * @param config The request configuration.
   * @returns The response directly.
   */
  execute<T>(config: HttpRequestConfig): Response<T> {
    try {
      // Use semaphore to block until the async call completes
      const semaphore = new Semaphore(0);
      let response: Response<T> | undefined;
      let error: Error | undefined;

      // Create the interceptor chain
      const chain = new RealInterceptorChain(
        this.interceptors,
        0,
        config,
        this.delegate,
        config.connectTimeout || 60000,
        config.readTimeout || 60000,
        config.writeTimeout || 60000
      );

      // Execute the chain asynchronously and capture the result
      (async () => {
        try {
          response = await chain.proceed(config) as Response<T>;
        } catch (err) {
          error = err as Error;
        } finally {
          semaphore.release();
        }
      })();

      // Wait for the async call to complete
      semaphore.acquire();

      if (error) {
        throw error instanceof Error ? error : new Error(String(error));
      }

      if (!response) {
        throw new Error('No response received');
      }

      return response;
    } catch (e) {
      throw e instanceof Error ? e : new Error(String(e));
    }
  }

  /**
   * Execute an HTTP request asynchronously with interceptors applied.
   * @param config The request configuration.
   * @param onResponse Callback for successful responses.
   * @param onFailure Callback for failed requests.
   */
  enqueue<T>(config: HttpRequestConfig, onResponse: (response: Response<T>) => void, onFailure: (error: Error) => void): void {
    try {
      // Create the interceptor chain
      const chain = new RealInterceptorChain(
        this.interceptors,
        0,
        config,
        this.delegate,
        config.connectTimeout || 60000,
        config.readTimeout || 60000,
        config.writeTimeout || 60000
      );

      // Execute the chain asynchronously
      (async () => {
        try {
          const response = await chain.proceed(config) as Response<T>;
          onResponse(response);
        } catch (error) {
          onFailure(error as Error);
        }
      })();
    } catch (error) {
      onFailure(error as Error);
    }
  }

  /**
   * Cancel all ongoing requests by delegating to the underlying HttpClient.
   */
  cancelAll(): void {
    this.delegate.cancelAll();
  }

  /**
   * Close the client by delegating to the underlying HttpClient.
   */
  close(): void {
    this.delegate.close();
  }
}