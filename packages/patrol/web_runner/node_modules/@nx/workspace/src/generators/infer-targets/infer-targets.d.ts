import { GeneratorCallback, Tree } from '@nx/devkit';
interface Schema {
    project?: string;
    plugins?: string[];
    skipFormat?: boolean;
}
export declare function convertToInferredGenerator(tree: Tree, options: Schema): Promise<GeneratorCallback>;
export default convertToInferredGenerator;
//# sourceMappingURL=infer-targets.d.ts.map