# patrol-docs

## Development

This is a Next.js application generated with
[Create Fumadocs](https://github.com/fuma-nama/fumadocs).

Run development server:

```bash
npm run dev
# or
pnpm dev
# or
yarn dev
```

Open http://localhost:3000 with your browser to see the result.

## Docs MDX parameters

You can add the following parameters to the MDX file

- `title`: The title of the page.
- `headTitleOverride`: The title of the page in the browser tab.
- `next`: The URL of the next page in the footer navigation.
- `nextTitle`: The title of the next page in the footer navigation.
- `previous`: The URL of the previous page in the footer navigation.
- `previousTitle`: The title of the previous page in the footer navigation.
- `hideNext`: Whether to hide the next page in the footer navigation.
- `hidePrevious`: Whether to hide the previous page in the footer navigation.

A schema is defined in `source.config.ts`:

## meta.json

A meta.json file is defined in each directory to control the navigation.

```json
{
  "title": "Title", // The title of the directory
  "root": true, // Whether the directory is the root of the navigation, this will narrow down the sidebar tabs
  "pages": [
    "---Separator text---", // Text separator
    "name" // The name of the page file, it will be displayed in the sidebar, if it is a directory, it will be displayed as a dropdown with all child pages
  ]
}
```
