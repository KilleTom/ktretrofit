/**
 * HTTP method decorators for Retrofit
 */
import { MetadataUtil } from '../../util/MetadataUtil';
import { HttpMethod } from './HttpMethod';

/**
 * Create an HTTP method decorator
 * @param method HTTP method type
 * @param path Request path
 * @returns Method decorator
 */
export function createMethodDecorator(method: HttpMethod, path: string): MethodDecorator {
  return (target: Object, propertyKey: string | symbol, descriptor: PropertyDescriptor) => {
    // Convert HttpMethod enum to string before storing in metadata
    // Using HttpMethod[method] to get the string representation of the enum value
    const methodString = HttpMethod[method];
    
    // Store HTTP method and path information
    MetadataUtil.defineHttpMethod(methodString, path, target, propertyKey);
  };
}