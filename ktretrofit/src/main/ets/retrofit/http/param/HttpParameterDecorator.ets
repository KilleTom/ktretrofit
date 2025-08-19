/**
 * HTTP parameter decorators for Retrofit
 */
import { MetadataUtil } from '../../util/MetadataUtil';
import { HttpParameterType } from './HttpParameterType';

/**
 * Create a parameter decorator
 * @param type Parameter type
 * @param key Parameter key
 * @returns Parameter decorator
 */
export function createParameterDecorator(type: HttpParameterType, key: string): ParameterDecorator {
  return (target: Object, propertyKey: string | symbol, parameterIndex: number) => {
    switch (type) {
      case HttpParameterType.PATH:
        MetadataUtil.definePathParameter(parameterIndex, key, target, propertyKey);
        break;
      case HttpParameterType.QUERY:
        MetadataUtil.defineQueryParameter(parameterIndex, key, target, propertyKey);
        break;
      case HttpParameterType.QUERY_MAP:
        MetadataUtil.defineQueryMapParameter(parameterIndex, target, propertyKey);
        break;
      case HttpParameterType.HEADER:
        MetadataUtil.defineHeaderParameter(parameterIndex, key, target, propertyKey);
        break;
      case HttpParameterType.HEADER_MAP:
        MetadataUtil.defineHeaderMapParameter(parameterIndex, target, propertyKey);
        break;
      case HttpParameterType.BODY:
        MetadataUtil.defineBodyParameter(parameterIndex, target, propertyKey);
        break;
      case HttpParameterType.FIELD:
        MetadataUtil.defineFieldParameter(parameterIndex, key, target, propertyKey);
        break;
      case HttpParameterType.FIELD_MAP:
        MetadataUtil.defineFieldMapParameter(parameterIndex, target, propertyKey);
        break;
      case HttpParameterType.PART:
      case HttpParameterType.PART_MAP:
      case HttpParameterType.URL:
      case HttpParameterType.COOKIE:
      case HttpParameterType.TAG:
      case HttpParameterType.QUERY_NAME:
        // For other parameter types, store them using the old format for backward compatibility
        const params = MetadataUtil.getMetadata(`retrofit:params:${HttpParameterType[type]}`, target, propertyKey) || [];
        params.push({ index: parameterIndex, key });
        MetadataUtil.defineMetadata(`retrofit:params:${HttpParameterType[type]}`, params, target, propertyKey);
        break;
    }
  };
}

/**
 * Form URL encoded method decorator
 * @returns Method decorator
 */
export function FormUrlEncoded(): MethodDecorator {
  return (target: Object, propertyKey: string | symbol, descriptor: PropertyDescriptor) => {
    MetadataUtil.markFormUrlEncoded(target, propertyKey);
  };
}

/**
 * Multipart method decorator
 * @returns Method decorator
 */
export function Multipart(): MethodDecorator {
  return (target: Object, propertyKey: string | symbol, descriptor: PropertyDescriptor) => {
    MetadataUtil.markMultipart(target, propertyKey);
  };
}