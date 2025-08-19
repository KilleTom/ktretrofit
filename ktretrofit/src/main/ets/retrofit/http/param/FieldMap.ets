/**
 * Form field map parameter decorator
 * @returns Parameter decorator
 */
import { HttpParameterType } from './HttpParameterType';
import { createParameterDecorator } from './HttpParameterDecorator';

export function FieldMap(): ParameterDecorator {
  return createParameterDecorator(HttpParameterType.FIELD_MAP, '');
}