import { HashProvider } from "@/components/hash-context"
import { baseOptions } from "@/lib/layout.shared"
import { source } from "@/lib/source"
import { DocsLayout } from "fumadocs-ui/layouts/notebook"

export default function Layout({ children }: LayoutProps<"/">) {
  return (
    <DocsLayout tree={source.pageTree} {...baseOptions()}>
      <HashProvider>{children}</HashProvider>
    </DocsLayout>
  )
}
