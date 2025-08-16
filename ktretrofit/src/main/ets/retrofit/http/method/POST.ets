import { HttpMethod } from "./HttpMethod";
import { createMethodDecorator } from "./HttpMethodDecorator";

export function POST(value: string): MethodDecorator {
  return createMethodDecorator(HttpMethod.POST, value)
}