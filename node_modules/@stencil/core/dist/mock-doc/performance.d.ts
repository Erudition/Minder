/**
 * https://developer.mozilla.org/en-US/docs/Web/API/Performance
 */
export declare class MockPerformance {
    clearMarks(): void;
    clearMeasures(): void;
    clearResourceTimings(): void;
    getEntries(): void;
    getEntriesByName(): void;
    getEntriesByType(): void;
    mark(): void;
    measure(): void;
    now(): number;
    setResourceTimingBufferSize(): void;
    toJSON(): void;
}
