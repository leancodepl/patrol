# @leancodepl/prettier-config

Prettier configuration for code formatting.

## Installation

```bash
npm install --save-dev @leancodepl/prettier-config
# or
yarn add --dev @leancodepl/prettier-config
```

## Usage Examples

### Basic Setup

```javascript
// prettier.config.js
module.exports = require('@leancodepl/prettier-config');
```

### With Overrides

```javascript
// prettier.config.js
const baseConfig = require('@leancodepl/prettier-config');

module.exports = {
  ...baseConfig,
  printWidth: 100,
  singleQuote: true,
};
```