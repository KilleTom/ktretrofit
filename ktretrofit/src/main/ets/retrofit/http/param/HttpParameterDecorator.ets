import { MetadataUtil } from '../../MetadataUtil';

export function createParameterDecorator(type: string, key: string): ParameterDecorator {
  return (target: Object, propertyKey: string | symbol, parameterIndex: number) => {
    const params = MetadataUtil.getMetadata(`retrofit:params:${type}`, target, propertyKey) || [];
    params.push({ index: parameterIndex, key });
    MetadataUtil.defineMetadata(`retrofit:params:${type}`, params, target, propertyKey);
  };
}

/**
 * Form field parameter decorator
 */
export function Field(key: string): ParameterDecorator {
  return createParameterDecorator('field', key)
}

/**
 * Form field map parameter decorator
 */
export function FieldMap(): ParameterDecorator {
  return createParameterDecorator('fieldMap', '')
}

/**
 * Multipart part parameter decorator
 */
export function Part(key?: string): ParameterDecorator {
  return createParameterDecorator('part', key || '')
}

/**
 * Multipart part map parameter decorator
 */
export function PartMap(): ParameterDecorator {
  return createParameterDecorator('partMap', '')
}

/**
 * Query parameter map decorator
 */
export function QueryMap(): ParameterDecorator {
  return createParameterDecorator('queryMap', '')
}

/**
 * URL replacement decorator
 */
export function Url(): ParameterDecorator {
  return createParameterDecorator('url', '')
}

/**
 * Cookie parameter decorator
 */
export function Cookie(key: string): ParameterDecorator {
  return createParameterDecorator('cookie', key)
}

/**
 * Header map parameter decorator
 */
export function HeaderMap(): ParameterDecorator {
  return createParameterDecorator('headerMap', '')
}

/**
 * Request tag decorator
 */
export function Tag(): ParameterDecorator {
  return createParameterDecorator('tag', '')
}

/**
 * Query parameter name decorator
 */
export function QueryName(key: string): ParameterDecorator {
  return createParameterDecorator('queryName', key)
}

/**
 * Form URL encoded method decorator
 */
export function FormUrlEncoded(): MethodDecorator {
  return (target: Object, propertyKey: string | symbol, descriptor: PropertyDescriptor) => {
    MetadataUtil.defineMetadata('retrofit:formUrlEncoded', true, target, propertyKey);
  };
}

/**
 * Multipart method decorator
 */
export function Multipart(): MethodDecorator {
  return (target: Object, propertyKey: string | symbol, descriptor: PropertyDescriptor) => {
    MetadataUtil.defineMetadata('retrofit:multipart', true, target, propertyKey);
  };
}

/**
 * Query parameter decorator
 */
export function Query(key: string): ParameterDecorator {
  return createParameterDecorator('query', key)
}

/**
 * Request body decorator
 */
export function Body(): ParameterDecorator {
  return createParameterDecorator('body', '')
}

/**
 * Header parameter decorator
 */
export function Header(key: string): ParameterDecorator {
  return createParameterDecorator('header', key)
}

/**
 * Path parameter decorator
 */
export function Path(key: string): ParameterDecorator {
  return createParameterDecorator('path', key)
}