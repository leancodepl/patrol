"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.stringifyTags = stringifyTags;
exports.hasNoneOfTheseTags = hasNoneOfTheseTags;
exports.isComboDepConstraint = isComboDepConstraint;
exports.findDependenciesWithTags = findDependenciesWithTags;
exports.matchImportWithWildcard = matchImportWithWildcard;
exports.isRelative = isRelative;
exports.getTargetProjectBasedOnRelativeImport = getTargetProjectBasedOnRelativeImport;
exports.findProject = findProject;
exports.isAbsoluteImportIntoAnotherProject = isAbsoluteImportIntoAnotherProject;
exports.findProjectUsingImport = findProjectUsingImport;
exports.findConstraintsFor = findConstraintsFor;
exports.hasStaticImportOfDynamicResource = hasStaticImportOfDynamicResource;
exports.getSourceFilePath = getSourceFilePath;
exports.hasBannedImport = hasBannedImport;
exports.findTransitiveExternalDependencies = findTransitiveExternalDependencies;
exports.hasBannedDependencies = hasBannedDependencies;
exports.isDirectDependency = isDirectDependency;
exports.hasBuildExecutor = hasBuildExecutor;
exports.isTerminalRun = isTerminalRun;
exports.groupImports = groupImports;
exports.belongsToDifferentEntryPoint = belongsToDifferentEntryPoint;
exports.getSecondaryEntryPointPath = getSecondaryEntryPointPath;
exports.parseExports = parseExports;
exports.appIsMFERemote = appIsMFERemote;
exports.getParserServices = getParserServices;
const tslib_1 = require("tslib");
const devkit_1 = require("@nx/devkit");
const js_1 = require("@nx/js");
const internal_1 = require("@nx/js/src/internal");
const utils_1 = require("@typescript-eslint/utils");
const path = tslib_1.__importStar(require("node:path"));
const find_project_for_path_1 = require("nx/src/project-graph/utils/find-project-for-path");
const fileutils_1 = require("nx/src/utils/fileutils");
const graph_utils_1 = require("./graph-utils");
function stringifyTags(tags) {
    return tags.map((t) => `"${t}"`).join(', ');
}
function hasNoneOfTheseTags(proj, tags) {
    return tags.filter((tag) => hasTag(proj, tag)).length === 0;
}
function isComboDepConstraint(depConstraint) {
    return !!depConstraint.allSourceTags;
}
/**
 * Check if any of the given tags is included in the project
 * @param proj ProjectGraphProjectNode
 * @param tags
 * @returns
 */
function findDependenciesWithTags(targetProject, tags, graph) {
    // find all reachable projects that have one of the tags and
    // are reacheable from the targetProject (including self)
    const allReachableProjects = Object.keys(graph.nodes).filter((projectName) => (0, graph_utils_1.pathExists)(graph, targetProject.name, projectName) &&
        tags.some((tag) => hasTag(graph.nodes[projectName], tag)));
    // return path from targetProject to reachable project
    return allReachableProjects.map((project) => targetProject.name === project
        ? [targetProject]
        : (0, graph_utils_1.getPath)(graph, targetProject.name, project));
}
const regexMap = new Map();
function hasTag(proj, tag) {
    if (tag === '*')
        return true;
    // if the tag is a regex, check if the project matches the regex
    if (tag.startsWith('/') && tag.endsWith('/')) {
        let regex;
        if (regexMap.has(tag)) {
            regex = regexMap.get(tag);
        }
        else {
            regex = new RegExp(tag.substring(1, tag.length - 1));
            regexMap.set(tag, regex);
        }
        return (proj.data.tags || []).some((t) => regex.test(t));
    }
    // if the tag is a glob, check if the project matches the glob prefix
    if (tag.includes('*')) {
        const regex = mapGlobToRegExp(tag);
        return (proj.data.tags || []).some((t) => regex.test(t));
    }
    return (proj.data.tags || []).indexOf(tag) > -1;
}
function matchImportWithWildcard(
// This may or may not contain wildcards ("*")
allowableImport, extractedImport) {
    if (allowableImport.endsWith('/**')) {
        const prefix = allowableImport.substring(0, allowableImport.length - 2);
        return extractedImport.startsWith(prefix);
    }
    else if (allowableImport.endsWith('/*')) {
        const prefix = allowableImport.substring(0, allowableImport.length - 1);
        if (!extractedImport.startsWith(prefix))
            return false;
        return extractedImport.substring(prefix.length).indexOf('/') === -1;
    }
    else if (allowableImport.indexOf('/**/') > -1) {
        const [prefix, suffix] = allowableImport.split('/**/');
        return (extractedImport.startsWith(prefix) && extractedImport.endsWith(suffix));
    }
    else {
        return new RegExp(allowableImport).test(extractedImport);
    }
}
function isRelative(s) {
    return s.startsWith('./') || s.startsWith('../');
}
function getTargetProjectBasedOnRelativeImport(imp, projectPath, projectGraph, projectRootMappings, sourceFilePath) {
    if (!isRelative(imp)) {
        return undefined;
    }
    const sourceDir = path.join(projectPath, path.dirname(sourceFilePath));
    const targetFile = (0, devkit_1.normalizePath)(path.resolve(sourceDir, imp)).substring(projectPath.length + 1);
    return findProject(projectGraph, projectRootMappings, targetFile);
}
function findProject(projectGraph, projectRootMappings, sourceFilePath) {
    return projectGraph.nodes[(0, find_project_for_path_1.findProjectForPath)(sourceFilePath, projectRootMappings)];
}
function isAbsoluteImportIntoAnotherProject(imp, workspaceLayout = { libsDir: 'libs', appsDir: 'apps' }) {
    return (imp.startsWith(`${workspaceLayout.libsDir}/`) ||
        imp.startsWith(`/${workspaceLayout.libsDir}/`) ||
        imp.startsWith(`${workspaceLayout.appsDir}/`) ||
        imp.startsWith(`/${workspaceLayout.appsDir}/`));
}
function findProjectUsingImport(projectGraph, targetProjectLocator, filePath, imp) {
    const target = targetProjectLocator.findProjectFromImport(imp, filePath);
    return projectGraph.nodes[target] || projectGraph.externalNodes?.[target];
}
function findConstraintsFor(depConstraints, sourceProject) {
    return depConstraints.filter((f) => {
        if (isComboDepConstraint(f)) {
            return f.allSourceTags.every((tag) => hasTag(sourceProject, tag));
        }
        else {
            return hasTag(sourceProject, f.sourceTag);
        }
    });
}
function hasStaticImportOfDynamicResource(node, graph, sourceProjectName, targetProjectName, importExpr, filePath) {
    if (node.type !== utils_1.AST_NODE_TYPES.ImportDeclaration ||
        node.importKind === 'type') {
        return false;
    }
    return (hasDynamicImport(graph, sourceProjectName, targetProjectName, []) &&
        !getSecondaryEntryPointPath(importExpr, filePath, graph.nodes[targetProjectName].data.root));
}
function hasDynamicImport(graph, sourceProjectName, targetProjectName, visited) {
    if (visited.indexOf(sourceProjectName) > -1) {
        return false;
    }
    return ((graph.dependencies[sourceProjectName] || []).filter((d) => {
        if (d.type !== devkit_1.DependencyType.dynamic) {
            return false;
        }
        if (d.target === targetProjectName) {
            return true;
        }
        return hasDynamicImport(graph, d.target, targetProjectName, [
            ...visited,
            sourceProjectName,
        ]);
    }).length > 0);
}
function getSourceFilePath(sourceFileName, projectPath) {
    const normalizedProjectPath = (0, devkit_1.normalizePath)(projectPath);
    const normalizedSourceFileName = (0, devkit_1.normalizePath)(sourceFileName);
    return normalizedSourceFileName.slice(normalizedProjectPath.length + 1);
}
/**
 * Find constraint (if any) that explicitly banns the given target npm project
 * @param externalProject
 * @param depConstraints
 * @returns
 */
function isConstraintBanningProject(externalProject, constraint, imp) {
    const { allowedExternalImports, bannedExternalImports } = constraint;
    const { packageName } = externalProject.data;
    if (imp !== packageName && !imp.startsWith(`${packageName}/`)) {
        return false;
    }
    /* Check if import is banned... */
    if (bannedExternalImports?.some((importDefinition) => mapGlobToRegExp(importDefinition).test(imp))) {
        return true;
    }
    /* ... then check if there is a whitelist and if there is a match in the whitelist.  */
    return allowedExternalImports?.every((importDefinition) => !imp.startsWith(packageName) ||
        !mapGlobToRegExp(importDefinition).test(imp));
}
function hasBannedImport(source, target, depConstraints, imp) {
    // return those constraints that match source project
    depConstraints = depConstraints.filter((c) => {
        let tags = [];
        if (isComboDepConstraint(c)) {
            tags = c.allSourceTags;
        }
        else {
            tags = [c.sourceTag];
        }
        return tags.every((t) => hasTag(source, t));
    });
    return depConstraints.find((constraint) => isConstraintBanningProject(target, constraint, imp));
}
/**
 * Find all unique (transitive) external dependencies of given project
 * @param graph
 * @param source
 * @returns
 */
function findTransitiveExternalDependencies(graph, source) {
    if (!graph.externalNodes) {
        return [];
    }
    const allReachableProjects = [];
    const allProjects = Object.keys(graph.nodes);
    for (let i = 0; i < allProjects.length; i++) {
        if ((0, graph_utils_1.pathExists)(graph, source.name, allProjects[i])) {
            allReachableProjects.push(allProjects[i]);
        }
    }
    const externalDependencies = [];
    for (let i = 0; i < allReachableProjects.length; i++) {
        const dependencies = graph.dependencies[allReachableProjects[i]];
        if (dependencies) {
            for (let d = 0; d < dependencies.length; d++) {
                const dependency = dependencies[d];
                if (graph.externalNodes[dependency.target]) {
                    externalDependencies.push(dependency);
                }
            }
        }
    }
    return externalDependencies;
}
/**
 * Check if
 * @param externalDependencies
 * @param graph
 * @param depConstraint
 * @returns
 */
function hasBannedDependencies(externalDependencies, graph, depConstraint, imp) {
    return externalDependencies
        .filter((dependency) => isConstraintBanningProject(graph.externalNodes[dependency.target], depConstraint, imp))
        .map((dep) => [
        graph.externalNodes[dep.target],
        graph.nodes[dep.source],
        depConstraint,
    ]);
}
function isDirectDependency(source, target) {
    return (packageExistsInPackageJson(target.data.packageName, '.') ||
        packageExistsInPackageJson(target.data.packageName, source.data.root));
}
function packageExistsInPackageJson(packageName, projectRoot) {
    const content = (0, fileutils_1.readFileIfExisting)(path.join(devkit_1.workspaceRoot, projectRoot, 'package.json'));
    if (content) {
        const { dependencies, devDependencies, peerDependencies } = (0, devkit_1.parseJson)(content);
        if (dependencies && dependencies[packageName]) {
            return true;
        }
        if (peerDependencies && peerDependencies[packageName]) {
            return true;
        }
        if (devDependencies && devDependencies[packageName]) {
            return true;
        }
    }
    return false;
}
/**
 * Maps import with wildcards to regex pattern
 * @param importDefinition
 * @returns
 */
function mapGlobToRegExp(importDefinition) {
    // we replace all instances of `*`, `**..*` and `.*` with `.*`
    const mappedWildcards = importDefinition.split(/(?:\.\*)|\*+/).join('.*');
    return new RegExp(`^${new RegExp(mappedWildcards).source}$`);
}
/**
 * Verifies whether the given node has a builder target
 * @param projectGraph the node to verify
 * @param buildTargets the list of targets to check for
 */
function hasBuildExecutor(projectGraph, buildTargets = ['build']) {
    return (projectGraph.data.targets &&
        buildTargets.some((target) => projectGraph.data.targets[target] &&
            projectGraph.data.targets[target].executor !== ''));
}
const ESLINT_REGEX = /node_modules.*[\/\\]eslint(?:\.js)?$/;
const JEST_REGEX = /node_modules\/.bin\/jest$/; // when we run unit tests in jest
const NRWL_CLI_REGEX = /nx[\/\\]bin[\/\\]run-executor\.js$/;
function isTerminalRun() {
    return (process.argv.length > 1 &&
        (!!process.argv[1].match(NRWL_CLI_REGEX) ||
            !!process.argv[1].match(JEST_REGEX) ||
            !!process.argv[1].match(ESLINT_REGEX) ||
            !!process.argv[1].endsWith('/bin/jest.js')));
}
/**
 * Takes an array of imports and tries to group them, so rather than having
 * `import { A } from './some-location'` and `import { B } from './some-location'` you get
 * `import { A, B } from './some-location'`
 * @param importsToRemap
 * @returns
 */
function groupImports(importsToRemap) {
    const importsToRemapGrouped = importsToRemap.reduce((acc, curr) => {
        const existing = acc.find((i) => i.importPath === curr.importPath && i.member !== curr.member);
        if (existing) {
            if (existing.member) {
                existing.member += `, ${curr.member}`;
            }
        }
        else {
            acc.push({
                importPath: curr.importPath,
                member: curr.member,
            });
        }
        return acc;
    }, []);
    return importsToRemapGrouped
        .map((entry) => `import { ${entry.member} } from '${entry.importPath}';`)
        .join('\n');
}
/**
 * Checks if source file belongs to a secondary entry point different than the import one
 */
function belongsToDifferentEntryPoint(importExpr, filePath, projectRoot) {
    const importEntryPoint = getSecondaryEntryPointPath(importExpr, filePath, projectRoot);
    const srcEntryPoint = getEntryPoint(filePath, projectRoot);
    // check if the entry point of import expression is different than the source file's entry point
    return importEntryPoint !== srcEntryPoint;
}
function getSecondaryEntryPointPath(importExpr, filePath, projectRoot) {
    const resolvedImportFile = (0, internal_1.resolveModuleByImport)(importExpr, filePath, // not strictly necessary, but speeds up resolution
    path.join(devkit_1.workspaceRoot, (0, js_1.getRootTsConfigFileName)()));
    if (!resolvedImportFile) {
        return undefined;
    }
    const entryPoint = getEntryPoint(resolvedImportFile, projectRoot);
    return entryPoint;
}
function getEntryPoint(file, projectRoot) {
    const packageEntryPoints = getPackageEntryPoints(projectRoot);
    const fileEntryPoint = packageEntryPoints.find((entry) => entry.file === file);
    if (fileEntryPoint) {
        return fileEntryPoint.file;
    }
    let parent = (0, devkit_1.joinPathFragments)(file, '../');
    while (parent !== `${projectRoot}/`) {
        const entryPoint = packageEntryPoints.find((entry) => entry.path === parent);
        if (entryPoint) {
            return entryPoint.file;
        }
        // for Angular we need to find closest existing ng-package.json
        // in order to determine if the file matches the secondary entry point
        const ngPackageContent = (0, fileutils_1.readFileIfExisting)(path.join(devkit_1.workspaceRoot, parent, 'ng-package.json'));
        if (ngPackageContent) {
            // https://github.com/ng-packagr/ng-packagr/blob/23c718d04eea85e015b4c261310b7bd0c39e5311/src/ng-package.schema.json#L54
            const entryFile = (0, devkit_1.parseJson)(ngPackageContent)?.lib?.entryFile ?? 'src/public_api.ts';
            return (0, devkit_1.joinPathFragments)(parent, entryFile);
        }
        parent = (0, devkit_1.joinPathFragments)(parent, '../');
    }
    return undefined;
}
function getPackageEntryPoints(projectRoot) {
    const packageContent = (0, fileutils_1.readFileIfExisting)(path.join(devkit_1.workspaceRoot, projectRoot, 'package.json'));
    if (!packageContent) {
        return [];
    }
    const exports = (0, devkit_1.parseJson)(packageContent).exports;
    if (!exports) {
        return [];
    }
    const entryPaths = [];
    parseExports(exports, projectRoot, entryPaths);
    return entryPaths;
}
function parseExports(exports, projectRoot, entryPaths, basePath = '.') {
    if (exports === null) {
        return;
    }
    if (typeof exports === 'string') {
        if (basePath === '.') {
            return;
        }
        else {
            entryPaths.push({
                path: (0, devkit_1.joinPathFragments)(projectRoot, basePath),
                file: (0, devkit_1.joinPathFragments)(projectRoot, exports),
            });
            return;
        }
    }
    // parse conditional exports
    if (exports.import || exports.require || exports.default || exports.node) {
        parseExports(exports.default || exports.import || exports.require || exports.node, projectRoot, entryPaths, basePath);
        return;
    }
    // parse general nested exports
    for (const [key, value] of Object.entries(exports)) {
        parseExports(value, projectRoot, entryPaths, key);
    }
}
/**
 * Returns true if the given project contains MFE config with "exposes:" section
 */
function appIsMFERemote(project) {
    const mfeConfig = (0, fileutils_1.readFileIfExisting)(path.join(devkit_1.workspaceRoot, project.data.root, 'module-federation.config.js')) ||
        (0, fileutils_1.readFileIfExisting)(path.join(devkit_1.workspaceRoot, project.data.root, 'module-federation.config.ts'));
    if (mfeConfig) {
        return !!mfeConfig.match(/('|")?exposes('|")?:/);
    }
    return false;
}
/**
 * parserServices moved from the context object to the nested sourceCode object in v8,
 * and was removed from its original location in v9.
 */
function getParserServices(context) {
    if (context.sourceCode && context.sourceCode.parserServices) {
        return context.sourceCode.parserServices;
    }
    const parserServices = context.parserServices;
    if (!parserServices) {
        throw new Error('Parser Services are not available, please check your ESLint configuration');
    }
    return parserServices;
}
