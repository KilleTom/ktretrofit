import { Interceptor } from './Interceptor';
import { Response } from '../call/Call';

/**
 * An {@link Interceptor} that logs request and response information.
 * This can be useful for debugging network issues.
 */
export class LoggingInterceptor implements Interceptor {
  private readonly tag: string;
  private readonly logLevel: LogLevel;

  /**
   * Create a new LoggingInterceptor.
   * @param tag The tag to use for logging (default: 'Retrofit').
   * @param logLevel The level of logging detail (default: LogLevel.BASIC).
   */
  constructor(tag: string = 'Retrofit', logLevel: LogLevel = LogLevel.BASIC) {
    this.tag = tag;
    this.logLevel = logLevel;
  }

  /**
   * Intercept the request and log information about it and the response.
   * @param chain The interceptor chain to proceed with.
   * @returns A Promise that resolves to the response.
   */
  async intercept(chain: Interceptor.Chain): Promise<Response<any>> {
    const request = chain.request();
    const startTime = Date.now();

    // Log request information based on log level
    if (this.logLevel >= LogLevel.BASIC) {
      console.log(`${this.tag}: --> ${request.method} ${request.url}`);
    }

    if (this.logLevel >= LogLevel.HEADERS) {
      if (request.headers && Object.keys(request.headers).length > 0) {
        console.log(`${this.tag}: Headers:`);
        for (const [key, value] of Object.entries(request.headers)) {
          console.log(`${this.tag}: ${key}: ${value}`);
        }
      }
    }

    if (this.logLevel >= LogLevel.BODY && request.body) {
      try {
        console.log(`${this.tag}: Body: ${JSON.stringify(request.body)}`);
      } catch (e) {
        console.log(`${this.tag}: Body: [cannot be serialized]`);
      }
    }

    // Proceed with the request
    let response: Response<any>;
    try {
      response = await chain.proceed(request);
    } catch (error) {
      console.error(`${this.tag}: <-- Error: ${error.message}`);
      throw error instanceof Error ? error : new Error(String(error));
    }

    const endTime = Date.now();
    const duration = endTime - startTime;

    // Log response information based on log level
    if (this.logLevel >= LogLevel.BASIC) {
      console.log(`${this.tag}: <-- ${response.code} ${response.message} ${request.url} (${duration}ms)`);
    }

    if (this.logLevel >= LogLevel.HEADERS) {
      if (response.headers && Object.keys(response.headers).length > 0) {
        console.log(`${this.tag}: Response Headers:`);
        for (const [key, value] of Object.entries(response.headers)) {
          console.log(`${this.tag}: ${key}: ${value}`);
        }
      }
    }

    if (this.logLevel >= LogLevel.BODY && response.body) {
      try {
        console.log(`${this.tag}: Response Body: ${JSON.stringify(response.body)}`);
      } catch (e) {
        console.log(`${this.tag}: Response Body: [cannot be serialized]`);
      }
    }

    return response;
  }
}

/**
 * Enum representing the level of logging detail.
 */
export enum LogLevel {
  /** No logging. */
  NONE = 0,
  /** Log only the request method and URL, and the response status code and execution time. */
  BASIC = 1,
  /** Log basic information plus headers. */
  HEADERS = 2,
  /** Log basic information, headers, and body. */
  BODY = 3
}