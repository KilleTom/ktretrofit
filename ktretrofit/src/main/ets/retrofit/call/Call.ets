

import { Response } from '../response/Response';

/**
 * Represents a single HTTP request that can be executed. This is modeled after the official Retrofit Call interface.
 */
export { Response };
export interface Call<T> {
  /**
   * Synchronously send the request and return its response.
   * This method will block the calling thread until the request completes.
   * @throws Error if unable to invoke the request or if the response is not a success.
   */
  execute(): Response<T>;

  /**
   * Asynchronously send the request and notify of its response or failure via the callbacks.
   * @param onResponse Callback for successful responses.
   * @param onFailure Callback for failed requests.
   */
  enqueue(onResponse: (response: Response<T>) => void, onFailure: (error: Error) => void): void;

  /**
   * Cancel this call. An attempt will be made to cancel in-flight requests, but this is not guaranteed.
   */
  cancel(): void;

  /**
   * True if this call has been either executed or enqueued.
   */
  isExecuted(): boolean;

  /**
   * True if this call has been canceled.
   */
  isCanceled(): boolean;

  /**
   * Create a new, identical call to this one which can be enqueued or executed even if this call has already been.
   */
  clone(): Call<T>;
}

/**
 * Factory for creating Call instances.
 */
export interface CallFactory {
  /**
   * Creates a new call for the given request configuration.
   */
  newCall<T>(requestConfig: any): Call<T>;
}