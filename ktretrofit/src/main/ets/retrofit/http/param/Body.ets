/**
 * Request body decorator
 * @returns Parameter decorator
 */
import { HttpParameterType } from './HttpParameterType';
import { createParameterDecorator } from './HttpParameterDecorator';

export function Body(): ParameterDecorator {
  return createParameterDecorator(HttpParameterType.BODY, '');
}