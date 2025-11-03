export declare function createCoalescingDebounce<T>(fn: () => Promise<T>, wait: number): {
    trigger: () => Promise<T>;
    cancel: () => void;
};
//# sourceMappingURL=coalescing-debounce.d.ts.map