/**
 * URL replacement decorator
 * @returns Parameter decorator
 */
import { HttpParameterType } from './HttpParameterType';
import { createParameterDecorator } from './HttpParameterDecorator';

export function Url(): ParameterDecorator {
  return createParameterDecorator(HttpParameterType.URL, '');
}