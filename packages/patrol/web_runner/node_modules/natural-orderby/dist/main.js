/**
 * natural-orderby v5.0.0
 *
 * Copyright (c) Olaf Ennen
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE.md file in the root directory of this source tree.
 *
 * @license MIT
 */
'use strict';

/* eslint-disable n/no-missing-require */

if (process.env.NODE_ENV === 'production') {
  module.exports = require('./umd/natural-orderby.production.min.js');
} else {
  module.exports = require('./umd/natural-orderby.development.js');
}
