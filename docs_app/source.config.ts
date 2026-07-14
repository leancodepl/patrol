import { defineConfig, defineDocs, frontmatterSchema, metaSchema } from "fumadocs-mdx/config"
import { z } from "zod"

const docsDir = process.env.CI ? "./docs" : "../docs"

// You can customise Zod schemas for frontmatter and `meta.json` here
// see https://fumadocs.dev/docs/mdx/collections
export const docs = defineDocs({
  dir: docsDir,
  docs: {
    schema: frontmatterSchema.extend({
      title: z.string().optional(),
      headTitleOverride: z.string().optional(),
      next: z.string().optional(),
      nextTitle: z.string().optional(),
      hideNext: z.boolean().optional(),
      previous: z.string().optional(),
      previousTitle: z.string().optional(),
      hidePrevious: z.boolean().optional(),
      // Extra "On this page" entries that don't come from markdown headings — used to
      // surface in-page anchors that live inside components (e.g. the setup accordion
      // sections). Each item is inserted right after the existing TOC entry whose url
      // matches `after` (appended if omitted / not found), preserving authored order.
      tocExtra: z
        .array(
          z.object({
            title: z.string(),
            url: z.string(),
            depth: z.number().int().default(3),
            after: z.string().optional(),
          }),
        )
        .optional(),
    }),

    postprocess: {
      includeProcessedMarkdown: true,
    },
  },
  meta: {
    schema: metaSchema,
  },
})

export default defineConfig({
  mdxOptions: {
    // MDX options
  },
})
