import { HttpMethod } from "./HttpMethod";
import { createMethodDecorator } from "./HttpMethodDecorator";

export function HEAD(value: string): MethodDecorator {
  return createMethodDecorator(HttpMethod.HEAD, value)
}