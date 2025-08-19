/**
 * Default implementation of {@link CallFactory} that creates {@link OkHttpCall} instances.
 */
import { HttpClient } from '../client/HttpClient';
import { ConverterFactory } from '../converter/Converter';
import { Call, CallFactory } from './Call';
import { OkHttpCall } from './OkHttpCall';

export class DefaultCallFactory implements CallFactory {
    private readonly client: HttpClient;
    private readonly converterFactories: ConverterFactory[];

    constructor(client: HttpClient, converterFactories: ConverterFactory[]) {
      this.client = client;
      this.converterFactories = converterFactories;
    }

    newCall<T>(requestConfig: any): Call<T> {
      return new OkHttpCall<T>(this.client, requestConfig, this.converterFactories);
    }
  }