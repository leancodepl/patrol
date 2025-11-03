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
export declare function resolve(specifier: string, context: any, nextResolve: any): Promise<any>;
//# sourceMappingURL=esm-loader.d.ts.map