/**
 * Path parameter decorator
 * @param key Parameter key
 * @returns Parameter decorator
 */
import { HttpParameterType } from './HttpParameterType';
import { createParameterDecorator } from './HttpParameterDecorator';

export function Path(key: string): ParameterDecorator {
  return createParameterDecorator(HttpParameterType.PATH, key);
}