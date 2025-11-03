"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = [
    {
        plugins: {
            get ['@nx']() {
                return require('../index');
            },
        },
        ignores: ['.nx'],
    },
];
