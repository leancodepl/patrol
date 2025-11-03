"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = counter;
exports.batchCounter = batchCounter;
const os_1 = require("os");
async function wait() {
    return new Promise((res) => {
        setTimeout(() => res(), 1000);
    });
}
async function* counter(opts) {
    for (let i = 0; i < opts.to; ++i) {
        console.log(i);
        yield { success: false };
        await wait();
    }
    yield { success: opts.result };
}
async function batchCounter(taskGraph, inputs) {
    const result = {};
    const results = await Promise.all(taskGraph.roots
        .map((rootTaskId) => [rootTaskId, inputs[rootTaskId]])
        .map(async ([taskId, options]) => {
        let terminalOutput = '';
        for (let i = 0; i < options.to; ++i) {
            console.log(i);
            terminalOutput += i + os_1.EOL;
            await wait();
        }
        return [taskId, options.result, terminalOutput];
    }));
    for (const [taskId, taskResult, terminalOutput] of results) {
        result[taskId] = {
            success: taskResult,
            terminalOutput,
        };
    }
    return result;
}
