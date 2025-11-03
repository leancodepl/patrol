"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.insertImport = insertImport;
const insert_statement_1 = require("./insert-statement");
const devkit_1 = require("@nx/devkit");
const typescript_1 = require("../../utilities/typescript");
let tsModule;
function insertImport(tree, path, name, modulePath) {
    if (!tsModule) {
        tsModule = (0, typescript_1.ensureTypescript)();
    }
    const { createSourceFile, ScriptTarget, isStringLiteral, isImportDeclaration, isNamedImports, } = tsModule;
    const contents = tree.read(path, 'utf-8');
    const sourceFile = createSourceFile(path, contents, ScriptTarget.ESNext);
    const importStatements = sourceFile.statements.filter(isImportDeclaration);
    const existingImport = importStatements.find((statement) => isStringLiteral(statement.moduleSpecifier) &&
        statement.moduleSpecifier
            .getText(sourceFile)
            .replace(/['"`]/g, '')
            .trim() === modulePath &&
        statement.importClause.namedBindings &&
        isNamedImports(statement.importClause.namedBindings));
    if (!existingImport) {
        (0, insert_statement_1.insertStatement)(tree, path, `import { ${name} } from '${modulePath}';`);
        return;
    }
    // TODO: Also check if the namedImport already exists
    const namedImports = existingImport.importClause
        .namedBindings;
    const index = namedImports.getEnd() - 1;
    let text;
    if (namedImports.elements.hasTrailingComma) {
        text = `${name},`;
    }
    else {
        text = `,${name}`;
    }
    const newContents = (0, devkit_1.applyChangesToString)(contents, [
        {
            type: devkit_1.ChangeType.Insert,
            index,
            text,
        },
    ]);
    tree.write(path, newContents);
}
