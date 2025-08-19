// Export all from retrofit index
import * as retrofit from './src/main/ets/retrofit/Index';

// Re-export all components for better accessibility
// HTTP Method Decorators
export const { GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS } = retrofit;

// Parameter Decorators
export const { Query, QueryMap, QueryName, Body, Header, HeaderMap, Path, Field, FieldMap, Part, PartMap, Url, Cookie, Tag } = retrofit;

// Method Decorators
export const { FormUrlEncoded, Multipart, createParameterDecorator } = retrofit;

// Utility Functions
export const { MetadataUtil, HttpMethod, HttpParameterType, createRetrofit, Semaphore } = retrofit;

// Interceptors
export const {  AuthInterceptor, LoggingInterceptor, LogLevel, InterceptorHttpClient, RealInterceptorChain } = retrofit;

// Response
export const { Response } = retrofit;

// Core Classes and Functions
export const { Retrofit, RetrofitBuilder } = retrofit;


// Call
export const {  DefaultCallFactory, OkHttpCall } = retrofit;

// Converter
export const {  StringConverterFactory, JsonConverterFactory, CompositeConverterFactory } = retrofit;

// HttpClient
export const {  DefaultHttpClient, HttpClientBuilder } = retrofit;

// Default export for convenience
export default retrofit;