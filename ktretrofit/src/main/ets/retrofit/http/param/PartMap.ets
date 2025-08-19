/**
 * Multipart part map parameter decorator
 * @returns Parameter decorator
 */
import { HttpParameterType } from './HttpParameterType';
import { createParameterDecorator } from './HttpParameterDecorator';

export function PartMap(): ParameterDecorator {
  return createParameterDecorator(HttpParameterType.PART_MAP, '');
}