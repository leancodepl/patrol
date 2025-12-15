import { defineConfig, defineDocs, frontmatterSchema, metaSchema } from "fumadocs-mdx/config"
import { z } from "zod"
import { remarkImage } from "fumadocs-core/mdx-plugins"

// You can customise Zod schemas for frontmatter and `meta.json` here
// see https://fumadocs.dev/docs/mdx/collections
export const docs = defineDocs({
  dir: "../docs",
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
