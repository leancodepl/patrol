## [0.3.2](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/compare/v0.3.1...v0.3.2) (2021-03-19)


### 🛠 Improvements

* Fixed up return type to include objectpattern type ([368eb09](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/368eb09))


### 📚 Documentation

* Add documentation about webpack complains ([a397113](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/a397113))


### 🏗 Chore

* Added test for object spread argument ([d6ec125](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/d6ec125))
* Fixed missing call to ObjectSpread decorator ([ee28b83](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/ee28b83))

## [0.3.1](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/compare/v0.3.0...v0.3.1) (2020-10-12)


### 🐛 Bug Fixes

* Use cloneDeep to keep reference linked ([869a913](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/869a913))

# [0.3.0](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/compare/v0.2.2...v0.3.0) (2020-03-05)


### ✨ Features

* Add support for TSBigIntKeyword ([358a689](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/358a689))
* Move param dec to class ([1371f6b](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/1371f6b))


### 🐛 Bug Fixes

* Restored [@babel](https://github.com/babel)/core types to allow TSC checking ([55ff485](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/55ff485))


### 🏗 Chore

* Update release-it to v11+ ([e61386f](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/e61386f))

## [0.2.2](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/compare/v0.2.1...v0.2.2) (2019-03-27)


### 🐛 Bug Fixes

* Add InversifyJS function to make decorators compatible with babel ([4535adb](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/4535adb))
* Handle unsupported kind of parameters with void zero ([a35f733](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/a35f733))
* Omit value when it's a reference to self (class name) ([f755bc2](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/f755bc2))


### 📚 Documentation

* Add InversifyJS property injection doc ([b263fcd](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/b263fcd))
* Make example DI code more realistic ([620182f](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/620182f))


### 🏗 Chore

* Add example code to test InversifyJS property injector ([48bd0bb](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/48bd0bb)), closes [#2](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/issues/2)


## [0.2.1](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/compare/v0.2.0...v0.2.1) (2019-03-24)


### 📚 Documentation

* Add current pitfalls to README ([2f2b888](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/2f2b888))


### 🏗 Chore

* Add package.json keywords ([97690ca](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/97690ca))


# [0.2.0](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/compare/v0.1.1...v0.2.0) (2019-03-24)


### ✨ Features

* Enhance type serialization following TSC [#1](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/issues/1) ([5a76db1](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/5a76db1))


### 🐛 Bug Fixes

* Fix parameter assignments type serialization ([0eb91bb](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/0eb91bb))


### 📚 Documentation

* Add motivation to README ([f59c802](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/f59c802))


## [0.1.1](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/compare/v0.1.0...v0.1.1) (2019-03-24)


### 📚 Documentation

* Add CHANGELOG ([880b618](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/880b618))


# 0.1.0 (2019-03-24)


### ✨ Features

* Add decorators metadata support ([9cb1e8f](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/9cb1e8f))


### 📚 Documentation

* Add installation and usage in README ([8d31825](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/8d31825))


### 🏗 Chore

* Use babel-plugin-utils to assert babel version ([bbf626a](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/commit/bbf626a))


