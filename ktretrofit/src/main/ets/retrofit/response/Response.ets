/**
 * HTTP response from an API call. This is modeled after the official Retrofit Response class.
 */
export class Response<T> {
  /**
   * The HTTP status code.
   */
  readonly code: number;

  /**
   * The HTTP status message.
   */
  readonly message: string;

  /**
   * The body of the HTTP response.
   */
  readonly body: T | null;

  /**
   * The HTTP headers of the response.
   */
  readonly headers: Record<string, string>;

  /**
   * True if the code is in the range [200..300).
   */
  readonly isSuccessful: boolean;

  /**
   * The request that generated this response.
   */
  readonly rawRequest: any;

  /**
   * The raw response object from the underlying HTTP client.
   */
  readonly rawResponse: any;

  constructor(
    code: number,
    message: string,
    body: T | null,
    headers: Record<string, string>,
    rawRequest: any = null,
    rawResponse: any = null
  ) {
    this.code = code;
    this.message = message;
    this.body = body;
    this.headers = headers;
    this.rawRequest = rawRequest;
    this.rawResponse = rawResponse;
    this.isSuccessful = code >= 200 && code < 300;
  }

  /**
   * Create a synthetic successful response with null body.
   */
  static success<T>(body: T | null = null): Response<T> {
    return new Response<T>(200, 'OK', body, {});
  }

  /**
   * Create a synthetic error response.
   */
  static error<T>(code: number, message: string = 'Error'): Response<T> {
    return new Response<T>(code, message, null, {});
  }

  /**
   * Get the response body, ensuring it is not null and the request was successful.
   * @returns The non-null response body.
   * @throws Error if the request was not successful or the body is null.
   */
  getNotNullBody(): T {
    if (!this.isSuccessful) {
      throw new Error(`Request failed with status code: ${this.code}, message: ${this.message}`);
    }
    
    if (this.body === null) {
      throw new Error('Response body is null');
    }
    
    return this.body;
  }
}