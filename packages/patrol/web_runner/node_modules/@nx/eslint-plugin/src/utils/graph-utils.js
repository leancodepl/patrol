"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getPath = getPath;
exports.pathExists = pathExists;
exports.checkCircularPath = checkCircularPath;
exports.circularPathHasPair = circularPathHasPair;
exports.findFilesInCircularPath = findFilesInCircularPath;
exports.findFilesWithDynamicImports = findFilesWithDynamicImports;
exports.expandIgnoredCircularDependencies = expandIgnoredCircularDependencies;
const project_graph_1 = require("nx/src/config/project-graph");
const find_matching_projects_1 = require("nx/src/utils/find-matching-projects");
const reach = {
    graph: null,
    matrix: null,
    adjList: null,
};
function buildMatrix(graph) {
    const nodes = Object.keys(graph.nodes);
    const nodesLength = nodes.length;
    const adjList = {};
    const matrix = {};
    // create matrix value set
    for (let i = 0; i < nodesLength; i++) {
        const v = nodes[i];
        adjList[v] = [];
        // meeroslav: turns out this is 10x faster than spreading the pre-generated initMatrixValues
        matrix[v] = {};
    }
    const projectsWithDependencies = Object.keys(graph.dependencies);
    for (let i = 0; i < projectsWithDependencies.length; i++) {
        const dependencies = graph.dependencies[projectsWithDependencies[i]];
        for (let j = 0; j < dependencies.length; j++) {
            const dependency = dependencies[j];
            if (graph.nodes[dependency.target]) {
                adjList[dependency.source].push(dependency.target);
            }
        }
    }
    const traverse = (s, v) => {
        matrix[s][v] = true;
        const adjListLength = adjList[v].length;
        for (let i = 0; i < adjListLength; i++) {
            const adj = adjList[v][i];
            if (!matrix[s][adj]) {
                traverse(s, adj);
            }
        }
    };
    for (let i = 0; i < nodesLength; i++) {
        const v = nodes[i];
        traverse(v, v);
    }
    return {
        matrix,
        adjList,
    };
}
function getPath(graph, sourceProjectName, targetProjectName) {
    if (sourceProjectName === targetProjectName)
        return [];
    if (reach.graph !== graph) {
        const { matrix, adjList } = buildMatrix(graph);
        reach.graph = graph;
        reach.matrix = matrix;
        reach.adjList = adjList;
    }
    const adjList = reach.adjList;
    let path = [];
    const queue = [[sourceProjectName, path]];
    const visited = [sourceProjectName];
    while (queue.length > 0) {
        const [current, p] = queue.pop();
        path = [...p, current];
        if (current === targetProjectName)
            break;
        if (!adjList[current])
            break;
        adjList[current]
            .filter((adj) => visited.indexOf(adj) === -1)
            .filter((adj) => reach.matrix[adj][targetProjectName])
            .forEach((adj) => {
            visited.push(adj);
            queue.push([adj, [...path]]);
        });
    }
    if (path.length > 1) {
        return path.map((n) => graph.nodes[n]);
    }
    else {
        return [];
    }
}
function pathExists(graph, sourceProjectName, targetProjectName) {
    if (sourceProjectName === targetProjectName)
        return true;
    if (reach.graph !== graph) {
        const { matrix, adjList } = buildMatrix(graph);
        reach.graph = graph;
        reach.matrix = matrix;
        reach.adjList = adjList;
    }
    return !!reach.matrix[sourceProjectName][targetProjectName];
}
function checkCircularPath(graph, sourceProject, targetProject) {
    if (!graph.nodes[targetProject.name])
        return [];
    return getPath(graph, targetProject.name, sourceProject.name);
}
function circularPathHasPair(circularPath, ignored) {
    if (circularPath.length < 2)
        return false;
    for (let i = 0; i < circularPath.length - 1; i++) {
        const dependencyIsIgnored = ignored
            .get(circularPath[i].name)
            ?.has(circularPath[i + 1].name);
        if (dependencyIsIgnored) {
            return true;
        }
    }
    return false;
}
function findFilesInCircularPath(projectFileMap, circularPath) {
    const filePathChain = [];
    for (let i = 0; i < circularPath.length - 1; i++) {
        const next = circularPath[i + 1].name;
        const files = projectFileMap[circularPath[i].name] || [];
        filePathChain.push(files
            .filter((file) => file.deps && file.deps.find((d) => (0, project_graph_1.fileDataDepTarget)(d) === next))
            .map((file) => file.file));
    }
    return filePathChain;
}
function findFilesWithDynamicImports(projectFileMap, sourceProjectName, targetProjectName) {
    const files = [];
    projectFileMap[sourceProjectName].forEach((file) => {
        if (!file.deps)
            return;
        if (file.deps.some((d) => (0, project_graph_1.fileDataDepTarget)(d) === targetProjectName &&
            (0, project_graph_1.fileDataDepType)(d) === project_graph_1.DependencyType.dynamic)) {
            files.push(file);
        }
    });
    return files;
}
function expandIgnoredCircularDependencies(ignoredCircularDependencies, projectGraph) {
    const allowed = new Map();
    for (const [a, b] of ignoredCircularDependencies) {
        const setA = new Set((0, find_matching_projects_1.findMatchingProjects)([a], projectGraph.nodes));
        const setB = new Set((0, find_matching_projects_1.findMatchingProjects)([b], projectGraph.nodes));
        for (const projectA of setA) {
            if (!allowed.has(projectA)) {
                allowed.set(projectA, new Set());
            }
            const currentSetA = allowed.get(projectA);
            for (const projectB of setB) {
                currentSetA.add(projectB);
            }
        }
        for (const projectB of setB) {
            if (!allowed.has(projectB)) {
                allowed.set(projectB, new Set());
            }
            const currentSetB = allowed.get(projectB);
            for (const projectA of setA) {
                currentSetB.add(projectA);
            }
        }
    }
    return allowed;
}
