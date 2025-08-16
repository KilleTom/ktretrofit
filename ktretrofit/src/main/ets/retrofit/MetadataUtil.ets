/**
 * Metadata utility class for managing metadata in ArkTS
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
}