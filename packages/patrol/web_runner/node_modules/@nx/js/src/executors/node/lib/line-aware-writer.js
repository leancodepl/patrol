"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.LineAwareWriter = void 0;
class LineAwareWriter {
    constructor() {
        this.buffer = '';
        this.activeTaskId = null;
    }
    get currentProcessId() {
        return this.activeTaskId;
    }
    write(data, taskId) {
        if (taskId !== this.activeTaskId)
            return;
        const text = data.toString();
        this.buffer += text;
        const lines = this.buffer.split('\n');
        this.buffer = lines.pop() || '';
        for (const line of lines) {
            process.stdout.write(line + '\n');
        }
    }
    flush() {
        if (this.buffer) {
            process.stdout.write(this.buffer + '\n');
            this.buffer = '';
        }
    }
    setActiveProcess(taskId) {
        this.flush();
        this.activeTaskId = taskId;
    }
}
exports.LineAwareWriter = LineAwareWriter;
