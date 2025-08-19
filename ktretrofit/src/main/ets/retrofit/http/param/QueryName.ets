/**
 * Query parameter name decorator
 * @param key Parameter key
 * @returns Parameter decorator
 */
import { HttpParameterType } from './HttpParameterType';
import { createParameterDecorator } from './HttpParameterDecorator';

export function QueryName(key: string): ParameterDecorator {
  return createParameterDecorator(HttpParameterType.QUERY_NAME, key);
}