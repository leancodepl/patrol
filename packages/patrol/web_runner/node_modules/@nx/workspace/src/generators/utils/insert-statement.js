"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.insertStatement = insertStatement;
const devkit_1 = require("@nx/devkit");
const typescript_1 = require("../../utilities/typescript");
let tsModule;
/**
 * Insert a statement after the last import statement in a file
 */
function insertStatement(tree, path, statement) {
    if (!tsModule) {
        tsModule = (0, typescript_1.ensureTypescript)();
    }
    const { createSourceFile, isImportDeclaration, ScriptTarget } = tsModule;
    const contents = tree.read(path, 'utf-8');
    const sourceFile = createSourceFile(path, contents, ScriptTarget.ESNext);
    const importStatements = sourceFile.statements.filter(isImportDeclaration);
    const index = importStatements.length > 0
        ? importStatements[importStatements.length - 1].getEnd()
        : 0;
    if (importStatements.length > 0) {
        statement = `\n${statement}`;
    }
    const newContents = (0, devkit_1.applyChangesToString)(contents, [
        {
            type: devkit_1.ChangeType.Insert,
            index,
            text: statement,
        },
    ]);
    tree.write(path, newContents);
}
