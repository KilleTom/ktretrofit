/**
 * Query parameter decorator
 * @param key Parameter key
 * @returns Parameter decorator
 */
import { HttpParameterType } from './HttpParameterType';
import { createParameterDecorator } from './HttpParameterDecorator';

export function Query(key: string): ParameterDecorator {
  return createParameterDecorator(HttpParameterType.QUERY, key);
}