"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateWorkspaceFiles = generateWorkspaceFiles;
const devkit_1 = require("@nx/devkit");
const connect_to_nx_cloud_1 = require("nx/src/nx-cloud/generators/connect-to-nx-cloud/connect-to-nx-cloud");
const url_shorten_1 = require("nx/src/nx-cloud/utilities/url-shorten");
const path_1 = require("path");
const semver_1 = require("semver");
const default_base_1 = require("../../utilities/default-base");
const versions_1 = require("../../utils/versions");
const presets_1 = require("../utils/presets");
const set_up_ai_agents_1 = require("nx/src/ai/set-up-ai-agents/set-up-ai-agents");
// map from the preset to the name of the plugin s.t. the README can have a more
// meaningful generator command.
const presetToPluginMap = {
    [presets_1.Preset.Apps]: {
        learnMoreLink: 'https://nx.dev/getting-started/intro#learn-nx?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.NPM]: {
        generateNxReleaseInfo: true,
        learnMoreLink: 'https://nx.dev/getting-started/tutorials/npm-workspaces-tutorial?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.TS]: {
        generateLibCmd: '@nx/js',
        generateNxReleaseInfo: true,
        learnMoreLink: 'https://nx.dev/nx-api/js?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.WebComponents]: {
        generateAppCmd: null,
        learnMoreLink: 'https://nx.dev/getting-started/intro#learn-nx?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.AngularMonorepo]: {
        generateAppCmd: '@nx/angular',
        generateLibCmd: '@nx/angular',
        learnMoreLink: 'https://nx.dev/getting-started/tutorials/angular-monorepo-tutorial?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.AngularStandalone]: {
        generateAppCmd: '@nx/angular',
        generateLibCmd: '@nx/angular',
        learnMoreLink: 'https://nx.dev/getting-started/tutorials/angular-standalone-tutorial?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.ReactMonorepo]: {
        generateAppCmd: '@nx/react',
        generateLibCmd: '@nx/react',
        learnMoreLink: 'https://nx.dev/getting-started/tutorials/react-monorepo-tutorial?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.ReactStandalone]: {
        generateAppCmd: '@nx/react',
        generateLibCmd: '@nx/react',
        learnMoreLink: 'https://nx.dev/getting-started/tutorials/react-standalone-tutorial?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.NextJsStandalone]: {
        generateAppCmd: '@nx/next',
        generateLibCmd: '@nx/react',
        learnMoreLink: 'https://nx.dev/nx-api/next?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.ReactNative]: {
        generateAppCmd: '@nx/react-native',
        generateLibCmd: '@nx/react',
        learnMoreLink: 'https://nx.dev/nx-api/react-native?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.VueMonorepo]: {
        generateAppCmd: '@nx/vue',
        generateLibCmd: '@nx/vue',
        learnMoreLink: 'https://nx.dev/getting-started/tutorials/vue-standalone-tutorial?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.VueStandalone]: {
        generateAppCmd: '@nx/vue',
        generateLibCmd: '@nx/vue',
        learnMoreLink: 'https://nx.dev/getting-started/tutorials/vue-standalone-tutorial?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.Nuxt]: {
        generateAppCmd: '@nx/nuxt',
        generateLibCmd: '@nx/vue',
        learnMoreLink: 'https://nx.dev/nx-api/nuxt?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.NuxtStandalone]: {
        generateAppCmd: '@nx/nuxt',
        generateLibCmd: '@nx/vue',
        learnMoreLink: 'https://nx.dev/nx-api/nuxt?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.Expo]: {
        generateAppCmd: '@nx/expo',
        generateLibCmd: '@nx/react',
        learnMoreLink: 'https://nx.dev/nx-api/expo?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.NextJs]: {
        generateAppCmd: '@nx/next',
        generateLibCmd: '@nx/react',
        learnMoreLink: 'https://nx.dev/nx-api/next?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.Nest]: {
        generateAppCmd: '@nx/nest',
        generateLibCmd: '@nx/node',
        learnMoreLink: 'https://nx.dev/nx-api/nest?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.Express]: {
        generateAppCmd: '@nx/express',
        generateLibCmd: '@nx/node',
        learnMoreLink: 'https://nx.dev/nx-api/express?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.NodeStandalone]: {
        generateAppCmd: '@nx/node',
        generateLibCmd: '@nx/node',
        learnMoreLink: 'https://nx.dev/nx-api/node?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.NodeMonorepo]: {
        generateAppCmd: '@nx/node',
        generateLibCmd: '@nx/node',
        learnMoreLink: 'https://nx.dev/nx-api/node?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
    [presets_1.Preset.TsStandalone]: {
        generateAppCmd: null,
        generateLibCmd: null,
        generateNxReleaseInfo: true,
        learnMoreLink: 'https://nx.dev/nx-api/js?utm_source=nx_project&utm_medium=readme&utm_campaign=nx_projects',
    },
};
async function generateWorkspaceFiles(tree, options) {
    if (!options.name) {
        throw new Error(`Invalid options, "name" is required.`);
    }
    // we need to check package manager version before the package.json is generated
    // since it might influence the version report
    const packageManagerVersion = (0, devkit_1.getPackageManagerVersion)(options.packageManager, tree.root);
    options = normalizeOptions(options);
    createFiles(tree, options);
    const nxJson = createNxJson(tree, options);
    const token = options.nxCloud !== 'skip'
        ? await (0, connect_to_nx_cloud_1.connectToNxCloud)(tree, {
            installationSource: 'create-nx-workspace',
            directory: options.directory,
            github: options.useGitHub,
        }, nxJson)
        : null;
    await createReadme(tree, options, token);
    let aiAgentsCallback = undefined;
    if (options.aiAgents && options.aiAgents.length > 0) {
        aiAgentsCallback = await (0, set_up_ai_agents_1.setupAiAgentsGenerator)(tree, {
            directory: options.directory,
            writeNxCloudRules: options.nxCloud !== 'skip',
            packageVersion: 'latest',
            agents: [...options.aiAgents],
        });
    }
    const [packageMajor] = packageManagerVersion.split('.');
    if (options.packageManager === 'pnpm' && +packageMajor >= 7) {
        if ((0, semver_1.gte)(packageManagerVersion, '10.6.0')) {
            addPnpmSettings(tree, options);
        }
        else {
            createNpmrc(tree, options);
        }
    }
    else if (options.packageManager === 'yarn') {
        if (+packageMajor >= 2) {
            createYarnrcYml(tree, options);
            // avoids errors when using nested yarn projects
            tree.write((0, path_1.join)(options.directory, 'yarn.lock'), '');
        }
    }
    setPresetProperty(tree, options);
    addNpmScripts(tree, options);
    setUpWorkspacesInPackageJson(tree, options);
    return { token, aiAgentsCallback };
}
function setPresetProperty(tree, options) {
    if (options.preset === presets_1.Preset.NPM) {
        (0, devkit_1.updateJson)(tree, (0, path_1.join)(options.directory, 'nx.json'), (json) => {
            addPropertyWithStableKeys(json, 'extends', 'nx/presets/npm.json');
            return json;
        });
    }
}
function createNxJson(tree, { directory, defaultBase, preset }) {
    const nxJson = {
        $schema: './node_modules/nx/schemas/nx-schema.json',
        defaultBase,
        targetDefaults: process.env.NX_ADD_PLUGINS === 'false'
            ? {
                build: {
                    cache: true,
                    dependsOn: ['^build'],
                },
                lint: {
                    cache: true,
                },
            }
            : undefined,
    };
    if (defaultBase === 'main') {
        delete nxJson.defaultBase;
    }
    if (preset !== presets_1.Preset.NPM) {
        nxJson.namedInputs = {
            default: ['{projectRoot}/**/*', 'sharedGlobals'],
            production: ['default'],
            sharedGlobals: [],
        };
        if (process.env.NX_ADD_PLUGINS === 'false') {
            nxJson.targetDefaults.build.inputs = ['production', '^production'];
            nxJson.useInferencePlugins = false;
        }
    }
    (0, devkit_1.writeJson)(tree, (0, path_1.join)(directory, 'nx.json'), nxJson);
    return nxJson;
}
function createFiles(tree, options) {
    const formattedNames = (0, devkit_1.names)(options.name);
    const filesDirName = options.preset === presets_1.Preset.AngularStandalone ||
        options.preset === presets_1.Preset.ReactStandalone ||
        options.preset === presets_1.Preset.VueStandalone ||
        options.preset === presets_1.Preset.NuxtStandalone ||
        options.preset === presets_1.Preset.NodeStandalone ||
        options.preset === presets_1.Preset.NextJsStandalone ||
        options.preset === presets_1.Preset.TsStandalone
        ? './files-root-app'
        : (options.preset === presets_1.Preset.TS &&
            options.workspaces &&
            process.env.NX_ADD_PLUGINS !== 'false') ||
            options.preset === presets_1.Preset.NPM
            ? './files-package-based-repo'
            : './files-integrated-repo';
    (0, devkit_1.generateFiles)(tree, (0, path_1.join)(__dirname, filesDirName), options.directory, {
        formattedNames,
        dot: '.',
        tmpl: '',
        cliCommand: 'nx',
        nxCli: false,
        ...options,
        nxVersion: versions_1.nxVersion,
        packageManager: options.packageManager,
    });
}
async function createReadme(tree, { name, appName, directory, preset, nxCloud, workspaces }, nxCloudToken) {
    const formattedNames = (0, devkit_1.names)(name);
    // default to an empty one for custom presets
    const presetInfo = presetToPluginMap[preset] ?? {
        package: '',
        generateLibCmd: null,
    };
    const nxCloudOnboardingUrl = nxCloudToken
        ? await (0, url_shorten_1.createNxCloudOnboardingURL)('readme', nxCloudToken, undefined, false)
        : null;
    (0, devkit_1.generateFiles)(tree, (0, path_1.join)(__dirname, './files-readme'), directory, {
        formattedNames,
        isJsStandalone: preset === presets_1.Preset.TsStandalone,
        isTsPreset: preset === presets_1.Preset.TS,
        isUsingNewTsSolutionSetup: process.env.NX_ADD_PLUGINS !== 'false' && workspaces,
        isEmptyRepo: !appName,
        appName,
        generateAppCmd: presetInfo.generateAppCmd,
        generateLibCmd: presetInfo.generateLibCmd,
        generateNxReleaseInfo: presetInfo.generateNxReleaseInfo,
        learnMoreLink: presetInfo.learnMoreLink,
        serveCommand: preset === presets_1.Preset.NextJs || preset === presets_1.Preset.NextJsStandalone
            ? 'dev'
            : 'serve',
        name,
        nxCloud,
        nxCloudOnboardingUrl,
    });
}
// ensure that pnpm install add all the missing peer deps
function addPnpmSettings(tree, options) {
    tree.write((0, path_1.join)(options.directory, 'pnpm-workspace.yaml'), `autoInstallPeers: true
`);
}
function createNpmrc(tree, options) {
    tree.write((0, path_1.join)(options.directory, '.npmrc'), 'strict-peer-dependencies=false\nauto-install-peers=true\n');
}
// ensure that yarn (berry) install uses classic node linker
function createYarnrcYml(tree, options) {
    tree.write((0, path_1.join)(options.directory, '.yarnrc.yml'), 'nodeLinker: node-modules\n');
}
function addNpmScripts(tree, options) {
    if (options.preset === presets_1.Preset.AngularStandalone ||
        options.preset === presets_1.Preset.ReactStandalone ||
        options.preset === presets_1.Preset.VueStandalone ||
        options.preset === presets_1.Preset.NuxtStandalone ||
        options.preset === presets_1.Preset.NodeStandalone) {
        (0, devkit_1.updateJson)(tree, (0, path_1.join)(options.directory, 'package.json'), (json) => {
            Object.assign(json.scripts, {
                start: 'nx serve',
                build: 'nx build',
                test: 'nx test',
            });
            return json;
        });
    }
    if (options.preset === presets_1.Preset.NextJsStandalone) {
        (0, devkit_1.updateJson)(tree, (0, path_1.join)(options.directory, 'package.json'), (json) => {
            Object.assign(json.scripts, {
                dev: 'nx dev',
                build: 'nx build',
                start: 'nx start',
                test: 'nx test',
            });
            return json;
        });
    }
    if (options.preset === presets_1.Preset.TsStandalone) {
        (0, devkit_1.updateJson)(tree, (0, path_1.join)(options.directory, 'package.json'), (json) => {
            Object.assign(json.scripts, {
                build: 'nx build',
                test: 'nx test',
            });
            return json;
        });
    }
}
function addPropertyWithStableKeys(obj, key, value) {
    const copy = { ...obj };
    Object.keys(obj).forEach((k) => {
        delete obj[k];
    });
    obj[key] = value;
    Object.keys(copy).forEach((k) => {
        obj[k] = copy[k];
    });
}
function normalizeOptions(options) {
    let defaultBase = options.defaultBase || (0, default_base_1.deduceDefaultBase)();
    const name = (0, devkit_1.names)(options.name).fileName;
    return {
        name,
        ...options,
        defaultBase,
        nxCloud: options.nxCloud ?? 'skip',
    };
}
function setUpWorkspacesInPackageJson(tree, options) {
    if (options.preset === presets_1.Preset.NPM ||
        (options.preset === presets_1.Preset.TS &&
            process.env.NX_ADD_PLUGINS !== 'false' &&
            options.workspaces) ||
        ((options.preset === presets_1.Preset.Expo ||
            options.preset === presets_1.Preset.NextJs ||
            options.preset === presets_1.Preset.ReactMonorepo ||
            options.preset === presets_1.Preset.ReactNative ||
            options.preset === presets_1.Preset.VueMonorepo ||
            options.preset === presets_1.Preset.Nuxt ||
            options.preset === presets_1.Preset.NodeMonorepo ||
            options.preset === presets_1.Preset.Express) &&
            options.workspaces)) {
        const workspaces = options.workspaceGlobs ?? ['packages/*'];
        if (options.packageManager === 'pnpm') {
            const pnpmWorkspacePath = (0, path_1.join)(options.directory, 'pnpm-workspace.yaml');
            let content = `packages:
  ${workspaces.map((workspace) => `- "${workspace}"`).join('\n  ')}
`;
            if (tree.exists(pnpmWorkspacePath)) {
                // already added to set the peer deps settings for pnpm 10.6.0+
                const existingContent = tree.read(pnpmWorkspacePath, 'utf-8');
                if (existingContent.trim().length) {
                    content = `${content}\n${existingContent}`;
                }
            }
            tree.write(pnpmWorkspacePath, content);
        }
        else {
            (0, devkit_1.updateJson)(tree, (0, path_1.join)(options.directory, 'package.json'), (json) => {
                json.workspaces = workspaces;
                return json;
            });
        }
    }
}
