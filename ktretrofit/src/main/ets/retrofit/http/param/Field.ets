/**
 * Form field parameter decorator
 * @param key Parameter key
 * @returns Parameter decorator
 */
import { HttpParameterType } from './HttpParameterType';
import { createParameterDecorator } from './HttpParameterDecorator';

export function Field(key: string): ParameterDecorator {
  return createParameterDecorator(HttpParameterType.FIELD, key);
}