"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSwcrcPath = getSwcrcPath;
const path_1 = require("path");
function getSwcrcPath(options, contextRoot, projectRoot) {
    const swcrcPath = options.swcrc
        ? (0, path_1.join)(contextRoot, options.swcrc)
        : (0, path_1.join)(contextRoot, projectRoot, '.swcrc');
    const tmpSwcrcPath = (0, path_1.join)(contextRoot, projectRoot, 'tmp', '.generated.swcrc');
    return {
        swcrcPath,
        tmpSwcrcPath,
    };
}
