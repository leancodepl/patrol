"use client"

import { SectionProvider } from "@/components/section-context"
import { Accordion as FumadocsAccordion } from "fumadocs-ui/components/accordion"
import { type ComponentProps } from "react"

// A thin wrapper around fumadocs' `Accordion`, mapped to `Accordion` in MDX. It
// publishes its `id` to descendant `Step`s through `SectionContext`, so each
// step can compose a stable, section-scoped deep-link id from just a short
// authored slug. The `id` is still forwarded to fumadocs unchanged, so the
// section's own header anchor and "copy link" button keep working exactly as
// before.
export function SetupAccordion({ id, children, ...props }: ComponentProps<typeof FumadocsAccordion>) {
  return (
    <FumadocsAccordion id={id} {...props}>
      <SectionProvider value={id}>{children}</SectionProvider>
    </FumadocsAccordion>
  )
}
