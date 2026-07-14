"use client"

import { useHash } from "@/components/hash-context"
import { SectionProvider } from "@/components/section-context"
import { Accordion as FumadocsAccordion } from "fumadocs-ui/components/accordion"
import { useEffect, useRef, type ComponentProps } from "react"

// Wraps fumadocs' `Accordion` (mapped to `Accordion` in MDX) and publishes its
// `id` to descendant `Step`s via `SectionContext`. The `id` is still forwarded to
// fumadocs, so the section's own header anchor and copy-link button keep working.
//
// We also own the deep-link scroll for a bare section hash (e.g. `#ios-setup`).
// fumadocs would leave this to the browser's native hash scroll, but it puts the
// anchor `id` on the header while its `scroll-m-24` lives on the parent item, so
// native scroll ignores the offset and hides the header under the sticky top stack.
// Instead we scroll the section ourselves once it is the hash target — with the same
// `--patrol-anchor-scroll-mt` offset (applied inline here and to the header in
// `global.css`, so our scroll and the native one agree) and the same expand-aware
// re-scroll as `Step`, so sections land exactly like steps and stay put while the
// controlled accordion animates open. Steps inside the section keep scrolling
// themselves; this only fires when the hash is the section id itself.
export function SetupAccordion({ id, children, ...props }: ComponentProps<typeof FumadocsAccordion>) {
  const hash = useHash()
  const ref = useRef<HTMLDivElement | null>(null)
  const isTarget = id !== undefined && hash === id

  useEffect(() => {
    if (!isTarget) return
    const el = ref.current
    if (!el) return

    // The item's inline `scroll-margin-top` (below) keeps it clear of the sticky top
    // stack; scroll now for the already-open case, then re-scroll once the expand
    // animation finishes (timeout fallback for when it never fires, e.g. reduced
    // motion). The animation runs on a descendant content element, so match it by
    // name + containment within this item.
    const scroll = () => el.scrollIntoView({ block: "start" })
    scroll()

    const onAnimationEnd = (event: AnimationEvent) => {
      if (event.animationName.startsWith("fd-accordion") && event.target instanceof Node && el.contains(event.target)) {
        scroll()
      }
    }
    document.addEventListener("animationend", onAnimationEnd)
    const fallback = window.setTimeout(scroll, 300)

    return () => {
      document.removeEventListener("animationend", onAnimationEnd)
      window.clearTimeout(fallback)
    }
  }, [isTarget])

  return (
    <FumadocsAccordion id={id} ref={ref} style={{ scrollMarginTop: "var(--patrol-anchor-scroll-mt)" }} {...props}>
      <SectionProvider value={id}>{children}</SectionProvider>
    </FumadocsAccordion>
  )
}
