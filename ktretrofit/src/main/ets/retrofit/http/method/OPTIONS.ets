import { HttpMethod } from "./HttpMethod";
import { createMethodDecorator } from "./HttpMethodDecorator";

/**
 * OPTIONS请求装饰器
 * @param value 请求路径
 * @returns 方法装饰器
 */
export function OPTIONS(value: string): MethodDecorator {
  return createMethodDecorator(HttpMethod.OPTIONS, value);
}