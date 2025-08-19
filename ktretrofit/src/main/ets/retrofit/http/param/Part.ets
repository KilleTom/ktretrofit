/**
 * Multipart part parameter decorator
 * @param key Parameter key (optional)
 * @returns Parameter decorator
 */
import { HttpParameterType } from './HttpParameterType';
import { createParameterDecorator } from './HttpParameterDecorator';

export function Part(key?: string): ParameterDecorator {
  return createParameterDecorator(HttpParameterType.PART, key || '');
}