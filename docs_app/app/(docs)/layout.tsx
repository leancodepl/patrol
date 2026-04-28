import { baseOptions } from "@/lib/layout.shared"
import { source } from "@/lib/source"
import { Banner } from "fumadocs-ui/components/banner"
import { DocsLayout } from "fumadocs-ui/layouts/notebook"

const webinarUrl =
  "https://leancode.co/webinar/mastering-patrol-and-ai-next-level-e2e-testing?utm_source=patrol_page&utm_medium=yellow_banner&utm_campaign=webinar"

export default function Layout({ children }: LayoutProps<"/">) {
  return (
    <DocsLayout
      tree={source.pageTree}
      {...baseOptions()}
      containerProps={{
        className: "patrol-docs-layout-with-banner",
      }}>
      <Banner id="patrol-webinar-banner" changeLayout={false} className="patrol-docs-webinar-banner">
        Webinar: Mastering Patrol & AI: Next-Level E2E Testing.{" "}
        <a href={webinarUrl} className="font-bold underline underline-offset-2">
          Register now
        </a>
      </Banner>
      {children}
    </DocsLayout>
  )
}
