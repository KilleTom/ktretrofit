/**
 * Header map parameter decorator
 * @returns Parameter decorator
 */
import { HttpParameterType } from './HttpParameterType';
import { createParameterDecorator } from './HttpParameterDecorator';

export function HeaderMap(): ParameterDecorator {
  return createParameterDecorator(HttpParameterType.HEADER_MAP, '');
}