"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolveModuleByImport = resolveModuleByImport;
exports.insertChange = insertChange;
exports.replaceChange = replaceChange;
exports.removeChange = removeChange;
exports.insertImport = insertImport;
exports.addGlobal = addGlobal;
exports.getImport = getImport;
exports.replaceNodeValue = replaceNodeValue;
exports.addParameterToConstructor = addParameterToConstructor;
exports.addMethod = addMethod;
exports.findClass = findClass;
exports.findNodes = findNodes;
const ensure_typescript_1 = require("./ensure-typescript");
const devkit_1 = require("@nx/devkit");
const path_1 = require("path");
const get_source_nodes_1 = require("./get-source-nodes");
const normalizedAppRoot = devkit_1.workspaceRoot.replace(/\\/g, '/');
let tsModule;
let compilerHost;
/**
 * Find a module based on its import
 *
 * @param importExpr Import used to resolve to a module
 * @param filePath
 * @param tsConfigPath
 */
function resolveModuleByImport(importExpr, filePath, tsConfigPath) {
    compilerHost = compilerHost || getCompilerHost(tsConfigPath);
    const { options, host, moduleResolutionCache } = compilerHost;
    const { resolvedModule } = tsModule.resolveModuleName(importExpr, filePath, options, host, moduleResolutionCache);
    if (!resolvedModule) {
        return;
    }
    else {
        return resolvedModule.resolvedFileName.replace(`${normalizedAppRoot}/`, '');
    }
}
function getCompilerHost(tsConfigPath) {
    const options = readTsConfigOptions(tsConfigPath);
    const host = tsModule.createCompilerHost(options, true);
    const moduleResolutionCache = tsModule.createModuleResolutionCache(devkit_1.workspaceRoot, host.getCanonicalFileName);
    return { options, host, moduleResolutionCache };
}
function readTsConfigOptions(tsConfigPath) {
    if (!tsModule) {
        tsModule = require('typescript');
    }
    const readResult = tsModule.readConfigFile(tsConfigPath, tsModule.sys.readFile);
    // we don't need to scan the files, we only care about options
    const host = {
        readDirectory: () => [],
        readFile: () => '',
        fileExists: tsModule.sys.fileExists,
    };
    return tsModule.parseJsonConfigFileContent(readResult.config, host, (0, path_1.dirname)(tsConfigPath)).options;
}
function nodesByPosition(first, second) {
    return first.getStart() - second.getStart();
}
function updateTsSourceFile(host, sourceFile, filePath) {
    const newFileContents = host.read(filePath).toString('utf-8');
    return sourceFile.update(newFileContents, {
        newLength: newFileContents.length,
        span: {
            length: sourceFile.text.length,
            start: 0,
        },
    });
}
function insertChange(host, sourceFile, filePath, insertPosition, contentToInsert) {
    const content = host.read(filePath).toString();
    const prefix = content.substring(0, insertPosition);
    const suffix = content.substring(insertPosition);
    host.write(filePath, `${prefix}${contentToInsert}${suffix}`);
    return updateTsSourceFile(host, sourceFile, filePath);
}
function replaceChange(host, sourceFile, filePath, insertPosition, contentToInsert, oldContent) {
    const content = host.read(filePath, 'utf-8');
    const prefix = content.substring(0, insertPosition);
    const suffix = content.substring(insertPosition + oldContent.length);
    const text = content.substring(insertPosition, insertPosition + oldContent.length);
    if (text !== oldContent) {
        throw new Error(`Invalid replace: "${text}" != "${oldContent}".`);
    }
    host.write(filePath, `${prefix}${contentToInsert}${suffix}`);
    return updateTsSourceFile(host, sourceFile, filePath);
}
function removeChange(host, sourceFile, filePath, removePosition, contentToRemove) {
    const content = host.read(filePath).toString();
    const prefix = content.substring(0, removePosition);
    const suffix = content.substring(removePosition + contentToRemove.length);
    host.write(filePath, `${prefix}${suffix}`);
    return updateTsSourceFile(host, sourceFile, filePath);
}
function insertImport(host, source, fileToEdit, symbolName, fileName, isDefault = false) {
    if (!tsModule) {
        tsModule = (0, ensure_typescript_1.ensureTypescript)();
    }
    const rootNode = source;
    const allImports = findNodes(rootNode, tsModule.SyntaxKind.ImportDeclaration);
    // get nodes that map to import statements from the file fileName
    const relevantImports = allImports.filter((node) => {
        // StringLiteral of the ImportDeclaration is the import file (fileName in this case).
        const importFiles = node
            .getChildren()
            .filter((child) => child.kind === tsModule.SyntaxKind.StringLiteral)
            .map((n) => n.text);
        return importFiles.filter((file) => file === fileName).length === 1;
    });
    if (relevantImports.length > 0) {
        let importsAsterisk = false;
        // imports from import file
        const imports = [];
        relevantImports.forEach((n) => {
            Array.prototype.push.apply(imports, findNodes(n, tsModule.SyntaxKind.Identifier));
            if (findNodes(n, tsModule.SyntaxKind.AsteriskToken).length > 0) {
                importsAsterisk = true;
            }
        });
        // if imports * from fileName, don't add symbolName
        if (importsAsterisk) {
            return source;
        }
        const importTextNodes = imports.filter((n) => n.text === symbolName);
        // insert import if it's not there
        if (importTextNodes.length === 0) {
            const fallbackPos = findNodes(relevantImports[0], tsModule.SyntaxKind.CloseBraceToken)[0].getStart() ||
                findNodes(relevantImports[0], tsModule.SyntaxKind.FromKeyword)[0].getStart();
            return insertAfterLastOccurrence(host, source, imports, `, ${symbolName}`, fileToEdit, fallbackPos);
        }
        return source;
    }
    // no such import declaration exists
    const useStrict = findNodes(rootNode, tsModule.SyntaxKind.StringLiteral).filter((n) => n.text === 'use strict');
    let fallbackPos = 0;
    if (useStrict.length > 0) {
        fallbackPos = useStrict[0].end;
    }
    const open = isDefault ? '' : '{ ';
    const close = isDefault ? '' : ' }';
    // if there are no imports or 'use strict' statement, insert import at beginning of file
    const insertAtBeginning = allImports.length === 0 && useStrict.length === 0;
    const separator = insertAtBeginning ? '' : ';\n';
    const toInsert = `${separator}import ${open}${symbolName}${close}` +
        ` from '${fileName}'${insertAtBeginning ? ';\n' : ''}`;
    return insertAfterLastOccurrence(host, source, allImports, toInsert, fileToEdit, fallbackPos, tsModule.SyntaxKind.StringLiteral);
}
function insertAfterLastOccurrence(host, sourceFile, nodes, toInsert, pathToFile, fallbackPos, syntaxKind) {
    // sort() has a side effect, so make a copy so that we won't overwrite the parent's object.
    let lastItem = [...nodes].sort(nodesByPosition).pop();
    if (!lastItem) {
        throw new Error();
    }
    if (syntaxKind) {
        lastItem = findNodes(lastItem, syntaxKind).sort(nodesByPosition).pop();
    }
    if (!lastItem && fallbackPos == undefined) {
        throw new Error(`tried to insert ${toInsert} as first occurrence with no fallback position`);
    }
    const lastItemPosition = lastItem ? lastItem.getEnd() : fallbackPos;
    return insertChange(host, sourceFile, pathToFile, lastItemPosition, toInsert);
}
function addGlobal(host, source, modulePath, statement) {
    if (!tsModule) {
        tsModule = (0, ensure_typescript_1.ensureTypescript)();
    }
    const allImports = findNodes(source, tsModule.SyntaxKind.ImportDeclaration);
    if (allImports.length > 0) {
        const lastImport = allImports[allImports.length - 1];
        return insertChange(host, source, modulePath, lastImport.end + 1, `\n${statement}\n`);
    }
    else {
        return insertChange(host, source, modulePath, 0, `${statement}\n`);
    }
}
function getImport(source, predicate) {
    if (!tsModule) {
        tsModule = (0, ensure_typescript_1.ensureTypescript)();
    }
    const allImports = findNodes(source, tsModule.SyntaxKind.ImportDeclaration);
    const matching = allImports.filter((i) => predicate(i.moduleSpecifier.getText()));
    return matching.map((i) => {
        const moduleSpec = i.moduleSpecifier
            .getText()
            .substring(1, i.moduleSpecifier.getText().length - 1);
        const t = i.importClause.namedBindings.getText();
        const bindings = t
            .replace('{', '')
            .replace('}', '')
            .split(',')
            .map((q) => q.trim());
        return { moduleSpec, bindings };
    });
}
function replaceNodeValue(host, sourceFile, modulePath, node, content) {
    return replaceChange(host, sourceFile, modulePath, node.getStart(node.getSourceFile()), content, node.getText());
}
function addParameterToConstructor(tree, source, modulePath, opts) {
    if (!tsModule) {
        tsModule = (0, ensure_typescript_1.ensureTypescript)();
    }
    const clazz = findClass(source, opts.className);
    const constructor = clazz.members.filter((m) => m.kind === tsModule.SyntaxKind.Constructor)[0];
    if (constructor) {
        throw new Error('Should be tested'); // TODO: check this
    }
    return addMethod(tree, source, modulePath, {
        className: opts.className,
        methodHeader: `constructor(${opts.param})`,
    });
}
function addMethod(tree, source, modulePath, opts) {
    const clazz = findClass(source, opts.className);
    const body = opts.body
        ? `
${opts.methodHeader} {
${opts.body}
}
`
        : `
${opts.methodHeader} {}
`;
    return insertChange(tree, source, modulePath, clazz.end - 1, body);
}
function findClass(source, className, silent = false) {
    if (!tsModule) {
        tsModule = (0, ensure_typescript_1.ensureTypescript)();
    }
    const nodes = (0, get_source_nodes_1.getSourceNodes)(source);
    const clazz = nodes.filter((n) => n.kind === tsModule.SyntaxKind.ClassDeclaration &&
        n.name.text === className)[0];
    if (!clazz && !silent) {
        throw new Error(`Cannot find class '${className}'.`);
    }
    return clazz;
}
function findNodes(node, kind, max = Infinity) {
    if (!node || max == 0) {
        return [];
    }
    const arr = [];
    const hasMatch = Array.isArray(kind)
        ? kind.includes(node.kind)
        : node.kind === kind;
    if (hasMatch) {
        arr.push(node);
        max--;
    }
    if (max > 0) {
        for (const child of node.getChildren()) {
            findNodes(child, kind, max).forEach((node) => {
                if (max > 0) {
                    arr.push(node);
                }
                max--;
            });
            if (max <= 0) {
                break;
            }
        }
    }
    return arr;
}
