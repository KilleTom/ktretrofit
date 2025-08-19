/**
 * Request tag decorator
 * @returns Parameter decorator
 */
import { HttpParameterType } from './HttpParameterType';
import { createParameterDecorator } from './HttpParameterDecorator';

export function Tag(): ParameterDecorator {
  return createParameterDecorator(HttpParameterType.TAG, '');
}