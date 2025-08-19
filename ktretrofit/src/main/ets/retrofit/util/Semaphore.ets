/**
 * A simple semaphore implementation for synchronization.
 * This is used to implement synchronous HTTP requests in HttpClient.
 */
export class Semaphore {
  private count: number;
  private waitingCallbacks: Array<() => void> = [];

  /**
   * Create a new Semaphore with the specified initial count.
   * @param initialCount The initial count of the semaphore (default: 0).
   */
  constructor(initialCount: number = 0) {
    this.count = initialCount;
  }

  /**
   * Acquire a permit from the semaphore.
   * If no permit is available, this will block until a permit becomes available.
   * Note: This uses a busy-waiting approach, which is not ideal but works for the current use case.
   */
  acquire(): void {
    if (this.count > 0) {
      this.count--;
      return;
    }

    // Use a busy-waiting approach to simulate blocking
    // In a real application, you might want to use a more sophisticated approach
    let acquired = false;
    const startTime = Date.now();
    const timeout = 30000; // 30 seconds timeout

    while (!acquired) {
      // Check if timeout has occurred
      if (Date.now() - startTime > timeout) {
        throw new Error('Semaphore acquire timeout');
      }

      // Very short delay to prevent CPU overuse
      for (let i = 0; i < 100000; i++) {
        // Busy-wait loop
      }

      if (this.count > 0) {
        this.count--;
        acquired = true;
      }
    }
  }

  /**
   * Release a permit back to the semaphore.
   */
  release(): void {
    this.count++;
  }
}