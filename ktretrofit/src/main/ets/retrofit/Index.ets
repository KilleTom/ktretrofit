// HTTP Method Decorators
import { GET } from './http/method/GET';
import { POST } from './http/method/POST';
import { PUT } from './http/method/PUT';
import { DELETE } from './http/method/DELETE';
import { PATCH } from './http/method/PATCH';
import { HEAD } from './http/method/HEAD';
import { OPTIONS } from './http/method/OPTIONS';

// Parameter Decorators
import { Query } from './http/param/Query';
import { QueryMap } from './http/param/QueryMap';
import { QueryName } from './http/param/QueryName';
import { Body } from './http/param/Body';
import { Header } from './http/param/Header';
import { HeaderMap } from './http/param/HeaderMap';
import { Path } from './http/param/Path';
import { Field } from './http/param/Field';
import { FieldMap } from './http/param/FieldMap';
import { Part } from './http/param/Part';
import { PartMap } from './http/param/PartMap';
import { Url } from './http/param/Url';
import { Cookie } from './http/param/Cookie';
import { Tag } from './http/param/Tag';

import { HttpMethod } from './http/method/HttpMethod';
import { HttpParameterType } from './http/param/HttpParameterType';

// Method Decorators
import { FormUrlEncoded, Multipart, createParameterDecorator } from './http/param/HttpParameterDecorator';

// Core Classes
import { Retrofit, RetrofitBuilder, createRetrofit } from './Retrofit';
import { MetadataUtil } from './util/MetadataUtil';
import { ApiServiceConfig, ApiMethodConfig, ApiParameterConfig } from './config/ApiConfig';

// Call Interface and Response
import { Call } from './call/Call';
import { DefaultCallFactory } from './call/DefaultCallFactory';
import { OkHttpCall } from './call/OkHttpCall';
import { Response } from './response/Response';

// Interceptor related imports
import { Interceptor } from './interceptor/Interceptor';
import { AuthInterceptor } from './interceptor/AuthInterceptor';
import { LoggingInterceptor, LogLevel } from './interceptor/LoggingInterceptor';
import { InterceptorHttpClient } from './interceptor/InterceptorHttpClient';
import { RealInterceptorChain } from './interceptor/RealInterceptorChain';

// Util related imports
import { Semaphore } from './util/Semaphore';

// Converter
import { Converter, ConverterFactory, StringConverterFactory, JsonConverterFactory, CompositeConverterFactory } from './converter/Converter';

// HttpClient
import { HttpClient, HttpRequestConfig, DefaultHttpClient, HttpClientBuilder } from './client/HttpClient';

// Export all modules
export {
  // HTTP Method Decorators
  GET,
  POST,
  PUT,
  DELETE,
  PATCH,
  HEAD,
  OPTIONS,
  
  // Parameter Decorators
  Query,
  QueryMap,
  QueryName,
  Body,
  Header,
  HeaderMap,
  Path,
  Field,
  FieldMap,
  Part,
  PartMap,
  Url,
  Cookie,
  Tag,
  
  // Method Decorators
  FormUrlEncoded,
  Multipart,
  
  // Utility Functions
  createParameterDecorator,
  MetadataUtil,
  HttpMethod,
  HttpParameterType,
  createRetrofit,
  Semaphore,
  
  // Interceptors
  Interceptor,
  AuthInterceptor,
  LoggingInterceptor,
  LogLevel,
  InterceptorHttpClient,
  RealInterceptorChain,
  
  // Response
  Response,
  
  // Core Classes and Functions
  Retrofit,
  RetrofitBuilder,
  // Configuration interfaces
  ApiServiceConfig,
  ApiMethodConfig,
  ApiParameterConfig,
  
  // Call
  Call,
  DefaultCallFactory,
  OkHttpCall,
  
  // Converter
  Converter,
  ConverterFactory,
  StringConverterFactory,
  JsonConverterFactory,
  CompositeConverterFactory,
  
  // HttpClient
  HttpClient,
  HttpRequestConfig,
  DefaultHttpClient,
  HttpClientBuilder
};

// Default export
const ktRetrofit = {
  // HTTP Method Decorators
  GET,
  POST,
  PUT,
  DELETE,
  PATCH,
  HEAD,
  OPTIONS,
  
  // Parameter Decorators
  Query,
  QueryMap,
  QueryName,
  Body,
  Header,
  HeaderMap,
  Path,
  Field,
  FieldMap,
  Part,
  PartMap,
  Url,
  Cookie,
  Tag,
  
  // Method Decorators
  FormUrlEncoded,
  Multipart,
  
  // Utility Functions
  createParameterDecorator,
  
  // Interceptors
  AuthInterceptor,
  LoggingInterceptor,
  LogLevel,
  InterceptorHttpClient,
  RealInterceptorChain,
  
  // Response
  Response,
  
  // Util
  MetadataUtil,
  HttpMethod,
  HttpParameterType,
  createRetrofit,
  Semaphore,
  
  // Core Classes and Functions
  Retrofit,
  RetrofitBuilder,


  DefaultCallFactory,
  OkHttpCall,
  
  // Converter - only including classes, not interfaces
  StringConverterFactory,
  JsonConverterFactory,
  CompositeConverterFactory,
  
  // HttpClient - only including classes, not interfaces
  DefaultHttpClient,
  HttpClientBuilder,
};

export default ktRetrofit;