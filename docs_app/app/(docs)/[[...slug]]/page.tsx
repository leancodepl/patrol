import { getFooterNavigation } from "@/lib/footerNavigation"
import { getPageImage, source } from "@/lib/source"
import { getMDXComponents } from "@/mdx-components"
import { createRelativeLink } from "fumadocs-ui/mdx"
import { DocsBody, DocsDescription, DocsPage, DocsTitle } from "fumadocs-ui/page"
import { notFound } from "next/navigation"
import type { TableOfContents } from "fumadocs-core/toc"
import type { Metadata } from "next"

export const dynamicParams = false

type TocExtra = NonNullable<ReturnType<typeof source.getPage>>["data"]["tocExtra"]

// Weave frontmatter-declared `tocExtra` entries into the heading-derived TOC. Each
// extra entry is emitted right after the existing item whose url matches its `after`
// (entries sharing an anchor keep their authored order); anything unmatched is
// appended. Purely additive, so pages without `tocExtra` get the original array back.
function mergeToc(toc: TableOfContents, extra: TocExtra): TableOfContents {
  if (!extra?.length) return toc

  const byAfter = new Map<string, TableOfContents>()
  const trailing: TableOfContents = []
  for (const { title, url, depth, after } of extra) {
    const entry = { title, url, depth }
    if (after !== undefined && toc.some(item => item.url === after)) {
      const group = byAfter.get(after) ?? []
      group.push(entry)
      byAfter.set(after, group)
    } else {
      trailing.push(entry)
    }
  }

  const merged: TableOfContents = []
  for (const item of toc) {
    merged.push(item)
    const inserted = byAfter.get(item.url)
    if (inserted) merged.push(...inserted)
  }
  return [...merged, ...trailing]
}

function isNextInternalSegmentPath(slugs: string[]) {
  return slugs.some(slug => {
    const decodedSlug = decodeURIComponent(slug)

    return decodedSlug.endsWith(".segments") || decodedSlug.startsWith("$oc$") || decodedSlug.startsWith("!")
  })
}

function handleMissingPage(slugs: string[] | undefined, context: "page" | "metadata"): never {
  const normalizedSlugs = slugs ?? []
  const pages = source.getPages()
  const isInternalSegmentPath = isNextInternalSegmentPath(normalizedSlugs)

  console.error(
    "[docs:not-found]",
    JSON.stringify({
      context,
      slugs: normalizedSlugs,
      isInternalSegmentPath,
      pagesCount: pages.length,
      rootExists: Boolean(source.getPage([])),
      firstPages: pages.slice(0, 20).map(page => ({
        url: page.url,
        slugs: page.slugs,
        path: page.path,
      })),
      vercelRegion: process.env.VERCEL_REGION,
      deploymentId: process.env.VERCEL_DEPLOYMENT_ID,
    }),
  )

  if (isInternalSegmentPath) {
    throw new Error("Unexpected docs route miss during render")
  }

  notFound()
}

export default async function Page(props: PageProps<"/[[...slug]]">) {
  const params = await props.params
  const page = source.getPage(params.slug)
  if (!page) handleMissingPage(params.slug, "page")

  const MDX = page.data.body
  const footer = getFooterNavigation(page)
  const toc = mergeToc(page.data.toc, page.data.tocExtra)

  return (
    <DocsPage
      toc={toc}
      full={page.data.full}
      tableOfContent={{
        style: "clerk",
      }}
      footer={{ items: footer }}>
      <DocsTitle>{page.data.title}</DocsTitle>
      <DocsDescription>{page.data.description}</DocsDescription>
      <DocsBody>
        <MDX
          components={getMDXComponents({
            // this allows you to link to other pages with relative file paths
            a: createRelativeLink(source, page),
          })}
        />
      </DocsBody>
    </DocsPage>
  )
}

export async function generateStaticParams() {
  return source.generateParams()
}

export async function generateMetadata(props: PageProps<"/[[...slug]]">): Promise<Metadata> {
  const params = await props.params
  const page = source.getPage(params.slug)
  if (!page) handleMissingPage(params.slug, "metadata")

  const title = page.data.title ? `${page.data.title} | Patrol` : "Patrol"
  return {
    metadataBase: new URL(
      process.env.VERCEL_PROJECT_PRODUCTION_URL
        ? `https://${process.env.VERCEL_PROJECT_PRODUCTION_URL}`
        : "https://patrol.leancode.co",
    ),
    title: page.data.headTitleOverride ?? title,
    description: page.data.description,
    openGraph: {
      images: getPageImage(page).url,
    },
  }
}
