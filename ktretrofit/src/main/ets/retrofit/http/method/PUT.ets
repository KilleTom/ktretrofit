import { HttpMethod } from "./HttpMethod";
import { createMethodDecorator } from "./HttpMethodDecorator";

export function PUT(value: string): MethodDecorator {
  return createMethodDecorator(HttpMethod.PUT, value)
}