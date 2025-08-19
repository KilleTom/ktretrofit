/**
 * Convert objects to and from their representation in HTTP.
 */

/**
 * Convert a type from its HTTP representation to a Java/Kotlin type.
 */
export interface Converter<F, T> {
  /**
   * Convert the value from {@code F} to {@code T}.
   * @param value the value to convert
   * @throws Error if conversion fails
   */
  convert(value: F): T;
}

/**
 * A factory for creating converters for an API method.
 */
export interface ConverterFactory {
  /**
   * Create a {@link Converter} for converting an HTTP response body to {@code type}.
   */
  responseBodyConverter(type: any): Converter<any, any> | null;

  /**
   * Create a {@link Converter} for converting {@code type} to an HTTP request body.
   */
  requestBodyConverter(type: any): Converter<any, any> | null;

  /**
   * Create a {@link Converter} for converting a {@code type} to a {@link String} to be used as a request parameter value.
   */
  stringConverter(type: any): Converter<any, string> | null;
}

/**
 * A default implementation of {@link ConverterFactory} that supports String conversion.
 */
export class StringConverterFactory implements ConverterFactory {
  responseBodyConverter(type: any): Converter<any, any> | null {
    if (type === String) {
      return {
        convert: (value: any) => value?.toString() || ''
      };
    }
    return null;
  }

  requestBodyConverter(type: any): Converter<any, any> | null {
    if (type === String) {
      return {
        convert: (value: any) => value?.toString() || ''
      };
    }
    return null;
  }

  stringConverter(type: any): Converter<any, string> | null {
    return {
      convert: (value: any) => value?.toString() || ''
    };
  }

  /**
   * Create a new instance of the factory.
   */
  static create(): StringConverterFactory {
    return new StringConverterFactory();
  }
}

/**
 * A default implementation of {@link ConverterFactory} that supports JSON conversion.
 */
export class JsonConverterFactory implements ConverterFactory {
  responseBodyConverter(type: any): Converter<any, any> | null {
    return {
      convert: (value: any) => {
        try {
          return JSON.parse(value?.toString() || '{}');
        } catch (e) {
          throw new Error(`Failed to parse JSON response: ${e}`);
        }
      }
    };
  }

  requestBodyConverter(type: any): Converter<any, any> | null {
    return {
      convert: (value: any) => {
        try {
          return JSON.stringify(value || {});
        } catch (e) {
          throw new Error(`Failed to serialize object to JSON: ${e}`);
        }
      }
    };
  }

  stringConverter(type: any): Converter<any, string> | null {
    return null;
  }

  /**
   * Create a new instance of the factory.
   */
  static create(): JsonConverterFactory {
    return new JsonConverterFactory();
  }
}

/**
 * A composite {@link ConverterFactory} that delegates to a list of other factories.
 */
export class CompositeConverterFactory implements ConverterFactory {
  private factories: ConverterFactory[];

  constructor(factories: ConverterFactory[]) {
    this.factories = factories;
  }

  responseBodyConverter(type: any): Converter<any, any> | null {
    for (const factory of this.factories) {
      const converter = factory.responseBodyConverter(type);
      if (converter != null) {
        return converter;
      }
    }
    return null;
  }

  requestBodyConverter(type: any): Converter<any, any> | null {
    for (const factory of this.factories) {
      const converter = factory.requestBodyConverter(type);
      if (converter != null) {
        return converter;
      }
    }
    return null;
  }

  stringConverter(type: any): Converter<any, string> | null {
    for (const factory of this.factories) {
      const converter = factory.stringConverter(type);
      if (converter != null) {
        return converter;
      }
    }
    return null;
  }
}