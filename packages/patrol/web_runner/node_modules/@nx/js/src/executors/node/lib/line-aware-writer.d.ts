export declare class LineAwareWriter {
    private buffer;
    private activeTaskId;
    get currentProcessId(): string | null;
    write(data: Buffer | string, taskId: string): void;
    flush(): void;
    setActiveProcess(taskId: string | null): void;
}
//# sourceMappingURL=line-aware-writer.d.ts.map