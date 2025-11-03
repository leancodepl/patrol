# babel-plugin-transform-typescript-metadata

[![Travis (.com)](https://img.shields.io/travis/com/leonardfactory/babel-plugin-transform-typescript-metadata.svg)](https://travis-ci.com/leonardfactory/babel-plugin-transform-typescript-metadata)
[![Codecov](https://img.shields.io/codecov/c/github/leonardfactory/babel-plugin-transform-typescript-metadata.svg)](https://codecov.io/gh/leonardfactory/babel-plugin-transform-typescript-metadata)
[![npm](https://img.shields.io/npm/v/babel-plugin-transform-typescript-metadata.svg?style=popout)](https://www.npmjs.com/package/babel-plugin-transform-typescript-metadata)

Babel plugin to emit decorator metadata like typescript compiler

## Motivation

TypeScript _Decorators_ allows advanced reflection patterns when combined
with [`Reflect.metadata`](https://rbuckton.github.io/reflect-metadata/) output.

Current `@babel/preset-typescript` implementation however just strips all types and
_does not_ emit the relative Metadata in the output code.

Since this kind of information is used extensively in libraries like
[Nest](https://docs.nestjs.com/providers) and [TypeORM](https://typeorm.io/#/)
to implement advanced features like **Dependency Injection**, I've thought it would
be awesome to be able to provide the same functionality that [TypeScript
compiler `experimentalDecorators` and `emitDecoratorMetadata`
flags](https://www.typescriptlang.org/docs/handbook/decorators.html) provide.

This means that code like:

```ts
import { Injectable, Inject } from 'some-di-library'; // Just an example
import { MyService } from './MyService';
import { Configuration } from './Configuration';

@Injectable()
class AnotherService {
  @Inject()
  config: Configuration;

  constructor(private service: MyService) {}
}
```

will be interpreted like:

```ts
import { MyService } from './MyService';
import { Configuration } from './Configuration';

@Injectable()
@Reflect.metadata('design:paramtypes', [MyService])
class AnotherService {
  @Inject()
  @Reflect.metadata('design:type', Configuration)
  config: Configuration;

  constructor(private service: MyService) {}
}
```

### Parameter decorators

Since decorators in typescript supports also _Parameters_, this plugin
also provides support for them, enabling the following syntax:

```ts
@Injectable()
class Some {
  constructor(@Inject() private: SomeService);
}
```

This will be roughly translated to:

```js
// ...
Inject()(Some.prototype, undefined, 0);
```

## Installation

With npm:

```sh
npm install --dev --save babel-plugin-transform-typescript-metadata
```

or with Yarn:

```sh
yarn add --dev babel-plugin-transform-typescript-metadata
```

## Usage

With `.babelrc`:

> **Note:** should be placed **before** `@babel/plugin-proposal-decorators`.

```js
{
  "plugins": [
    "babel-plugin-transform-typescript-metadata",
    ["@babel/plugin-proposal-decorators", { "legacy": true }],
    ["@babel/plugin-proposal-class-properties", { "loose": true }],
  ],
  "presets": [
    "@babel/preset-typescript"
  ]
}
```

### Usage with [InversifyJS](http://inversify.io)

If you are using normal dependency injection letting Inversify **create your instances**, you should be fine with all kind of decorators.

Instead, if you are using **property injection**, when [the container does not
create the instances](https://github.com/inversify/InversifyJS/blob/master/wiki/property_injection.md#when-we-cannot-use-inversifyjs-to-create-an-instance-of-a-class),
you would likely encounter errors since babel
decorators are not exactly the same as TypeScript.

You can fix it by _enhancing property decorators_ with the following function:

```ts
import getDecorators from 'inversify-inject-decorators';
// setup the container...
let { lazyInject: originalLazyInject } = getDecorators(container);

// Additional function to make properties decorators compatible with babel.
function fixPropertyDecorator<T extends Function>(decorator: T): T {
  return ((...args: any[]) => (
    target: any,
    propertyName: any,
    ...decoratorArgs: any[]
  ) => {
    decorator(...args)(target, propertyName, ...decoratorArgs);
    return Object.getOwnPropertyDescriptor(target, propertyName);
  }) as any;
}

export const lazyInject = fixPropertyDecorator(originalLazyInject);
```

## Current Pitfalls

- If you are using webpack and it complains about missing exports due to types
  not being removed, you can switch from `import { MyType } from ...` to 
  `import type { MyType } from ...`. See [#46](https://github.com/leonardfactory/babel-plugin-transform-typescript-metadata/issues/46) for details and 
  examples.

- We cannot know if type annotations are just types (i.e. `IMyInterface`) or
  concrete values (like classes, etc.). In order to resolve this, we emit the
  following: `typeof Type === 'undefined' ? Object : Type`. The code has the
  advantage of not throwing. If you know a better way to do this, let me know!
