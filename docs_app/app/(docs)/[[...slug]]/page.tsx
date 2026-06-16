import { getFooterNavigation } from "@/lib/footerNavigation"
import { getPageImage, source } from "@/lib/source"
import { getMDXComponents } from "@/mdx-components"
import { createRelativeLink } from "fumadocs-ui/mdx"
import { DocsBody, DocsDescription, DocsPage, DocsTitle } from "fumadocs-ui/page"
import { notFound } from "next/navigation"
import type { Metadata } from "next"

export const dynamicParams = false

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

  return (
    <DocsPage
      toc={page.data.toc}
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
