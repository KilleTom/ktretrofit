import { HttpMethod } from "./HttpMethod";
import { createMethodDecorator } from "./HttpMethodDecorator";

export function GET(value: string): MethodDecorator {
  return createMethodDecorator(HttpMethod.GET, value)
}



