import { type ConfigArray } from 'typescript-eslint';
/**
 * This configuration is intended to be applied to ONLY .ts and .tsx files within a
 * React project in an Nx workspace.
 *
 * It should therefore NOT contain any rules or plugins which are generic
 * to all variants of React projects, e.g. TypeScript vs JavaScript, .js vs .jsx etc
 *
 * This configuration is intended to be combined with other configs from this
 * package.
 */
declare const config: ConfigArray;
export default config;
//# sourceMappingURL=react-typescript.d.ts.map