/**
 * Query parameter map decorator
 * @returns Parameter decorator
 */
import { HttpParameterType } from './HttpParameterType';
import { createParameterDecorator } from './HttpParameterDecorator';

export function QueryMap(): ParameterDecorator {
  return createParameterDecorator(HttpParameterType.QUERY_MAP, '');
}