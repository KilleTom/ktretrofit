/**
 * Header parameter decorator
 * @param key Parameter key
 * @returns Parameter decorator
 */
import { HttpParameterType } from './HttpParameterType';
import { createParameterDecorator } from './HttpParameterDecorator';

export function Header(key: string): ParameterDecorator {
  return createParameterDecorator(HttpParameterType.HEADER, key);
}