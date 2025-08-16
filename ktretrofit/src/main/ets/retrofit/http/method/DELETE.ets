import { HttpMethod } from "./HttpMethod";
import { createMethodDecorator } from "./HttpMethodDecorator";

export function DELETE(value: string): MethodDecorator {
  return createMethodDecorator(HttpMethod.DELETE, value)
}