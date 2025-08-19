import { Interceptor } from './Interceptor';
import { Response } from '../call/Call';

/**
 * An {@link Interceptor} that adds authorization headers to requests.
 * This can be used to add tokens, API keys, or other authentication information.
 */
export class AuthInterceptor implements Interceptor {
  private readonly tokenProvider: TokenProvider;
  private readonly headerName: string;
  private readonly authScheme: string;

  /**
   * Create a new AuthInterceptor.
   * @param tokenProvider A function that provides the authentication token.
   * @param headerName The name of the header to add the token to (default: 'Authorization').
   * @param authScheme The authentication scheme (default: 'Bearer').
   */
  constructor(
    tokenProvider: TokenProvider,
    headerName: string = 'Authorization',
    authScheme: string = 'Bearer'
  ) {
    this.tokenProvider = tokenProvider;
    this.headerName = headerName;
    this.authScheme = authScheme;
  }

  /**
   * Intercept the request and add the authorization header.
   * @param chain The interceptor chain to proceed with.
   * @returns A Promise that resolves to the response.
   */
  async intercept(chain: Interceptor.Chain): Promise<Response<any>> {
    const request = chain.request();
    
    // Get the token from the provider
    const token = await this.tokenProvider.getToken();
    
    if (token) {
      // Create a copy of the request with the authorization header added
      const modifiedRequest = {
        ...request,
        headers: {
          ...request.headers,
          [this.headerName]: `${this.authScheme} ${token}`
        }
      };
      
      // Proceed with the modified request
      return chain.proceed(modifiedRequest);
    }
    
    // If no token is available, proceed with the original request
    return chain.proceed(request);
  }
}

/**
 * Interface for providing authentication tokens.
 */
export interface TokenProvider {
  /**
   * Get the authentication token.
   * @returns A Promise that resolves to the token string, or undefined if no token is available.
   */
  getToken(): Promise<string | undefined>;
}

/**
 * A simple TokenProvider implementation that always returns the same token.
 */
export class StaticTokenProvider implements TokenProvider {
  private readonly token: string;

  /**
   * Create a new StaticTokenProvider.
   * @param token The token to provide.
   */
  constructor(token: string) {
    this.token = token;
  }

  /**
   * Get the static token.
   * @returns A Promise that resolves to the token.
   */
  getToken(): Promise<string | undefined> {
    return Promise.resolve(this.token);
  }
}

/**
 * A TokenProvider implementation that gets the token from a function.
 */
export class DynamicTokenProvider implements TokenProvider {
  private readonly tokenGetter: () => Promise<string | undefined>;

  /**
   * Create a new DynamicTokenProvider.
   * @param tokenGetter A function that returns the token.
   */
  constructor(tokenGetter: () => Promise<string | undefined>) {
    this.tokenGetter = tokenGetter;
  }

  /**
   * Get the token by calling the tokenGetter function.
   * @returns A Promise that resolves to the token.
   */
  getToken(): Promise<string | undefined> {
    return this.tokenGetter();
  }
}