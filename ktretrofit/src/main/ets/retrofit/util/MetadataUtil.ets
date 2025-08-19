/**
 * Metadata utility class for managing HTTP method and parameter metadata in Retrofit.
 */
export class MetadataUtil {
  private static metadataMap: Map<string, Map<string | symbol, any>> = new Map();

  /**
   * Define metadata for a target
   */
  static defineMetadata(metadataKey: string, metadataValue: any, target: Object, propertyKey?: string | symbol): void {
    const targetKey = target.constructor.name + (propertyKey ? ':' + String(propertyKey) : '');
    
    if (!this.metadataMap.has(targetKey)) {
      this.metadataMap.set(targetKey, new Map());
    }
    
    const targetMetadata = this.metadataMap.get(targetKey)!;
    targetMetadata.set(metadataKey, metadataValue);
  }

  /**
   * Get metadata from a target
   */
  static getMetadata(metadataKey: string, target: Object, propertyKey?: string | symbol): any {
    const targetKey = target.constructor.name + (propertyKey ? ':' + String(propertyKey) : '');
    
    if (!this.metadataMap.has(targetKey)) {
      return undefined;
    }
    
    const targetMetadata = this.metadataMap.get(targetKey)!;
    return targetMetadata.get(metadataKey);
  }

  /**
   * Define HTTP method metadata for a method
   */
  static defineHttpMethod(method: string, path: string, target: Object, propertyKey: string | symbol): void {
    this.defineMetadata('retrofit:httpMethod', method, target, propertyKey);
    this.defineMetadata('retrofit:path', path, target, propertyKey);
  }

  /**
   * Mark a method as form url encoded
   */
  static markFormUrlEncoded(target: Object, propertyKey: string | symbol): void {
    this.defineMetadata('retrofit:isFormEncoded', true, target, propertyKey);
  }

  /**
   * Mark a method as multipart
   */
  static markMultipart(target: Object, propertyKey: string | symbol): void {
    this.defineMetadata('retrofit:isMultipart', true, target, propertyKey);
  }

  /**
   * Define path parameter metadata
   */
  static definePathParameter(paramIndex: number, paramName: string, target: Object, propertyKey: string | symbol): void {
    let pathParams = this.getMetadata('retrofit:pathParams', target, propertyKey) as Record<number, string> || {};
    pathParams[paramIndex] = paramName;
    this.defineMetadata('retrofit:pathParams', pathParams, target, propertyKey);
  }

  /**
   * Define query parameter metadata
   */
  static defineQueryParameter(paramIndex: number, paramName: string, target: Object, propertyKey: string | symbol): void {
    let queryParams = this.getMetadata('retrofit:queryParams', target, propertyKey) as Record<number, string> || {};
    queryParams[paramIndex] = paramName;
    this.defineMetadata('retrofit:queryParams', queryParams, target, propertyKey);
  }

  /**
   * Define query map parameter metadata
   */
  static defineQueryMapParameter(paramIndex: number, target: Object, propertyKey: string | symbol): void {
    let queryMapParams = this.getMetadata('retrofit:queryMapParams', target, propertyKey) as number[] || [];
    queryMapParams.push(paramIndex);
    this.defineMetadata('retrofit:queryMapParams', queryMapParams, target, propertyKey);
  }

  /**
   * Define header parameter metadata
   */
  static defineHeaderParameter(paramIndex: number, paramName: string, target: Object, propertyKey: string | symbol): void {
    let headerParams = this.getMetadata('retrofit:headerParams', target, propertyKey) as Record<number, string> || {};
    headerParams[paramIndex] = paramName;
    this.defineMetadata('retrofit:headerParams', headerParams, target, propertyKey);
  }

  /**
   * Define header map parameter metadata
   */
  static defineHeaderMapParameter(paramIndex: number, target: Object, propertyKey: string | symbol): void {
    let headerMapParams = this.getMetadata('retrofit:headerMapParams', target, propertyKey) as number[] || [];
    headerMapParams.push(paramIndex);
    this.defineMetadata('retrofit:headerMapParams', headerMapParams, target, propertyKey);
  }

  /**
   * Define body parameter metadata
   */
  static defineBodyParameter(paramIndex: number, target: Object, propertyKey: string | symbol): void {
    this.defineMetadata('retrofit:bodyParam', paramIndex, target, propertyKey);
  }

  /**
   * Define field parameter metadata
   */
  static defineFieldParameter(paramIndex: number, paramName: string, target: Object, propertyKey: string | symbol): void {
    let fieldParams = this.getMetadata('retrofit:fieldParams', target, propertyKey) as Record<number, string> || {};
    fieldParams[paramIndex] = paramName;
    this.defineMetadata('retrofit:fieldParams', fieldParams, target, propertyKey);
  }

  /**
   * Define field map parameter metadata
   */
  static defineFieldMapParameter(paramIndex: number, target: Object, propertyKey: string | symbol): void {
    let fieldMapParams = this.getMetadata('retrofit:fieldMapParams', target, propertyKey) as number[] || [];
    fieldMapParams.push(paramIndex);
    this.defineMetadata('retrofit:fieldMapParams', fieldMapParams, target, propertyKey);
  }

  /**
   * Define part parameter metadata
   */
  static definePartParameter(paramIndex: number, paramName: string, target: Object, propertyKey: string | symbol): void {
    let partParams = this.getMetadata('retrofit:partParams', target, propertyKey) as Record<number, string> || {};
    partParams[paramIndex] = paramName;
    this.defineMetadata('retrofit:partParams', partParams, target, propertyKey);
  }

  /**
   * Define part map parameter metadata
   */
  static definePartMapParameter(paramIndex: number, target: Object, propertyKey: string | symbol): void {
    let partMapParams = this.getMetadata('retrofit:partMapParams', target, propertyKey) as number[] || [];
    partMapParams.push(paramIndex);
    this.defineMetadata('retrofit:partMapParams', partMapParams, target, propertyKey);
  }

  /**
   * Get method metadata (HTTP method, path, etc.)
   */
  static getMethodMetadata(target: Object, propertyKey?: string | symbol): {
    httpMethod: string;
    path: string;
    isFormEncoded: boolean;
    isMultipart: boolean;
  } | null {
    const httpMethod = this.getMetadata('retrofit:httpMethod', target, propertyKey);
    const path = this.getMetadata('retrofit:path', target, propertyKey);
    
    if (!httpMethod || !path) {
      return null;
    }
    
    return {
      httpMethod,
      path,
      isFormEncoded: this.getMetadata('retrofit:isFormEncoded', target, propertyKey) || false,
      isMultipart: this.getMetadata('retrofit:isMultipart', target, propertyKey) || false
    };
  }

  /**
   * Get path parameters metadata
   */
  static getPathParameters(target: Object, propertyKey?: string | symbol): Record<number, string> | null {
    return this.getMetadata('retrofit:pathParams', target, propertyKey) || null;
  }

  /**
   * Get query parameters metadata
   */
  static getQueryParameters(target: Object, propertyKey?: string | symbol): Record<number, string> | null {
    return this.getMetadata('retrofit:queryParams', target, propertyKey) || null;
  }

  /**
   * Get query map parameters metadata
   */
  static getQueryMapParameters(target: Object, propertyKey?: string | symbol): number[] | null {
    return this.getMetadata('retrofit:queryMapParams', target, propertyKey) || null;
  }

  /**
   * Get header parameters metadata
   */
  static getHeaderParameters(target: Object, propertyKey?: string | symbol): Record<number, string> | null {
    return this.getMetadata('retrofit:headerParams', target, propertyKey) || null;
  }

  /**
   * Get header map parameters metadata
   */
  static getHeaderMapParameters(target: Object, propertyKey?: string | symbol): number[] | null {
    return this.getMetadata('retrofit:headerMapParams', target, propertyKey) || null;
  }

  /**
   * Get body parameter index
   */
  static getBodyParameter(target: Object, propertyKey?: string | symbol): number {
    return this.getMetadata('retrofit:bodyParam', target, propertyKey) || -1;
  }

  /**
   * Get field parameters metadata
   */
  static getFieldParameters(target: Object, propertyKey?: string | symbol): Record<number, string> | null {
    return this.getMetadata('retrofit:fieldParams', target, propertyKey) || null;
  }

  /**
   * Get field map parameters metadata
   */
  static getFieldMapParameters(target: Object, propertyKey?: string | symbol): number[] | null {
    return this.getMetadata('retrofit:fieldMapParams', target, propertyKey) || null;
  }

  /**
   * Get part parameters metadata
   */
  static getPartParameters(target: Object, propertyKey?: string | symbol): Record<number, string> | null {
    return this.getMetadata('retrofit:partParams', target, propertyKey) || null;
  }

  /**
   * Get part map parameters metadata
   */
  static getPartMapParameters(target: Object, propertyKey?: string | symbol): number[] | null {
    return this.getMetadata('retrofit:partMapParams', target, propertyKey) || null;
  }
}