import { Tree } from '@nx/devkit';
import { Schema } from './schema';
export declare function validateSchema(schema: Schema, configName: string): Promise<void>;
export declare function convertToNxProjectGenerator(host: Tree, schema: Schema): Promise<void>;
export default convertToNxProjectGenerator;
//# sourceMappingURL=convert-to-nx-project.d.ts.map