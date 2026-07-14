"use client"

import { SectionProvider } from "@/components/section-context"
import { Accordion as FumadocsAccordion } from "fumadocs-ui/components/accordion"
import { type ComponentProps } from "react"

// Wraps fumadocs' `Accordion` (mapped to `Accordion` in MDX) and publishes its
// `id` to descendant `Step`s via `SectionContext`. The `id` is still forwarded to
// fumadocs, so the section's own header anchor and copy-link button keep working.
export function SetupAccordion({ id, children, ...props }: ComponentProps<typeof FumadocsAccordion>) {
  return (
    <FumadocsAccordion id={id} {...props}>
      <SectionProvider value={id}>{children}</SectionProvider>
    </FumadocsAccordion>
  )
}
