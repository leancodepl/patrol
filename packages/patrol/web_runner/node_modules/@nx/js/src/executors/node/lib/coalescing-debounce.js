"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createCoalescingDebounce = createCoalescingDebounce;
function createCoalescingDebounce(fn, wait) {
    let timeoutId = null;
    let activePromise = null;
    let nextPromiseResolvers = [];
    return {
        trigger: () => {
            if (timeoutId) {
                clearTimeout(timeoutId);
                timeoutId = null;
            }
            if (activePromise) {
                return new Promise((resolve, reject) => {
                    nextPromiseResolvers.push({ resolve, reject });
                });
            }
            return new Promise((resolve, reject) => {
                nextPromiseResolvers.push({ resolve, reject });
                timeoutId = setTimeout(async () => {
                    activePromise = fn();
                    try {
                        const result = await activePromise;
                        for (const { resolve } of nextPromiseResolvers) {
                            resolve(result);
                        }
                    }
                    catch (error) {
                        for (const { reject } of nextPromiseResolvers) {
                            reject(error);
                        }
                    }
                    finally {
                        activePromise = null;
                        nextPromiseResolvers = [];
                    }
                }, wait);
            });
        },
        cancel: () => {
            if (timeoutId) {
                clearTimeout(timeoutId);
                timeoutId = null;
            }
            for (const { reject } of nextPromiseResolvers) {
                reject(new Error('Cancelled'));
            }
            nextPromiseResolvers = [];
        },
    };
}
