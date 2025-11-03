"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolve = resolve;
const node_url_1 = require("node:url");
const node_fs_1 = require("node:fs");
const node_path_1 = require("node:path");
/**
 * Custom ESM resolver for Node.js that handles Nx workspace library mappings.
 *
 * This resolver is necessary because:
 * 1. Node.js ESM resolution doesn't understand TypeScript path mappings (e.g., @myorg/mylib)
 * 2. Nx workspace libraries need to be resolved to their actual built output locations
 * 3. The built output might be in different formats (.js, .mjs) or locations (index.js)
 *
 * The resolver intercepts import requests for workspace libraries and maps them to their
 * actual file system locations based on the NX_MAPPINGS environment variable set by
 * the Node executor.
 */
async function resolve(specifier, context, nextResolve) {
    // Parse mappings on each call to ensure we get the latest values
    const mappings = JSON.parse(process.env.NX_MAPPINGS || '{}');
    const mappingKeys = Object.keys(mappings);
    // Check if this is a workspace library mapping
    const matchingKey = mappingKeys.find((key) => specifier === key || specifier.startsWith(key + '/'));
    if (matchingKey) {
        const mappedPath = mappings[matchingKey];
        const restOfPath = specifier.slice(matchingKey.length);
        const fullPath = (0, node_path_1.join)(mappedPath, restOfPath);
        // Try to resolve the mapped path as a file first
        if ((0, node_fs_1.existsSync)(fullPath)) {
            const stats = (0, node_fs_1.statSync)(fullPath);
            if (stats.isFile()) {
                return nextResolve((0, node_url_1.pathToFileURL)(fullPath).href, context);
            }
        }
        // Try with index.js
        const indexPath = (0, node_path_1.join)(fullPath, 'index.js');
        if ((0, node_fs_1.existsSync)(indexPath)) {
            return nextResolve((0, node_url_1.pathToFileURL)(indexPath).href, context);
        }
        const jsPath = fullPath + '.js';
        if ((0, node_fs_1.existsSync)(jsPath)) {
            return nextResolve((0, node_url_1.pathToFileURL)(jsPath).href, context);
        }
        const mjsPath = fullPath + '.mjs';
        if ((0, node_fs_1.existsSync)(mjsPath)) {
            return nextResolve((0, node_url_1.pathToFileURL)(mjsPath).href, context);
        }
    }
    return nextResolve(specifier, context);
}
