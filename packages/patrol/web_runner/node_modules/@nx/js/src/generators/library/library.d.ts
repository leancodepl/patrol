import { GeneratorCallback, Tree } from '@nx/devkit';
import type { LibraryGeneratorSchema, NormalizedLibraryGeneratorOptions } from './schema';
export declare function libraryGenerator(tree: Tree, schema: LibraryGeneratorSchema): Promise<GeneratorCallback>;
export declare function libraryGeneratorInternal(tree: Tree, schema: LibraryGeneratorSchema): Promise<GeneratorCallback>;
export type AddLintOptions = Pick<NormalizedLibraryGeneratorOptions, 'name' | 'linter' | 'projectRoot' | 'unitTestRunner' | 'js' | 'setParserOptionsProject' | 'rootProject' | 'bundler' | 'addPlugin' | 'isUsingTsSolutionConfig'>;
export declare function addLint(tree: Tree, options: AddLintOptions): Promise<GeneratorCallback>;
export default libraryGenerator;
//# sourceMappingURL=library.d.ts.map