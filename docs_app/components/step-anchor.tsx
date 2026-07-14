"use client"

import { useHash } from "@/components/hash-context"
import { useSectionId } from "@/components/section-context"
import { cn } from "@/lib/cn"
import { Step as FumadocsStep } from "fumadocs-ui/components/steps"
import { useCopyButton } from "fumadocs-ui/utils/use-copy-button"
import { Check, LinkIcon } from "lucide-react"
import { useEffect, useRef, type ReactNode } from "react"

// Copy-link button shown on hover, mirroring fumadocs' accordion-header one. It
// sits inside a descendant wrapper of `.fd-step` so it never becomes the
// positioning ancestor of the numbered circle (`.fd-step::before`).
function CopyStepLink({ fullId }: { fullId: string }) {
  const [checked, onClick] = useCopyButton(() =>
    navigator.clipboard.writeText(`${window.location.origin}${window.location.pathname}#${fullId}`),
  )

  return (
    <button
      type="button"
      aria-label="Copy link to this step"
      onClick={onClick}
      className={cn(
        "absolute end-0 top-0 rounded-md p-1 text-fd-muted-foreground opacity-0 transition-opacity",
        "hover:bg-fd-accent hover:text-fd-accent-foreground focus-visible:opacity-100 group-hover/step:opacity-100",
      )}>
      {checked ? <Check className="size-3.5" /> : <LinkIcon className="size-3.5" />}
    </button>
  )
}

// Wraps fumadocs' `Step` to make it deep-linkable. Full id is `${sectionId}-${slug}`
// (section id from `SectionContext`), stable because it never encodes position. The
// extra id-bearing wrapper is safe since step numbering is CSS-counter based. The
// scroll offset tracks `--fd-docs-row-3` — the notebook layout's full sticky-top
// stack (promo banner + nav header + mobile TOC bar) — so the target always clears
// whatever is pinned above it and shrinks back automatically when the banner is
// dismissed (`--fd-banner-height` becomes unset → the stack collapses). The added
// `4.5rem` is a deliberate, constant breathing gap (~1.5× the banner height) so the
// step never sits flush below the bar, banner or not; tune it via this one number.
export function Step({ id, children }: { id?: string; children: ReactNode }) {
  const sectionId = useSectionId()
  const hash = useHash()
  const ref = useRef<HTMLDivElement | null>(null)

  const fullId = id === undefined ? undefined : sectionId === undefined ? id : `${sectionId}-${id}`
  const isTarget = fullId !== undefined && hash === fullId

  // Scroll to this step when it becomes the hash target (fires on mount for a cold
  // load once its section opens, and on later hash changes when already mounted).
  useEffect(() => {
    if (!isTarget) return
    const el = ref.current
    if (!el) return

    // The element's `scroll-mt` (below) keeps the step clear of the sticky top stack.
    const scroll = () => el.scrollIntoView({ block: "start" })

    // On a cold load the enclosing accordion is opened first and expands via a CSS
    // animation that runs *after* this step mounts, so scrolling now lands at the
    // still-collapsed section top. Scroll immediately for the warm / already-open
    // case, then re-scroll once the expand animation finishes (with a timeout
    // fallback for when it never fires, e.g. reduced motion). The animation belongs
    // to an ancestor accordion-content element, so match it by name + containment.
    scroll()

    const onAnimationEnd = (event: AnimationEvent) => {
      if (event.animationName.startsWith("fd-accordion") && event.target instanceof Node && event.target.contains(el)) {
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
    <div ref={ref} id={fullId} className="group/step scroll-mt-[calc(var(--fd-docs-row-3)_+_4.5rem)]">
      <FumadocsStep>
        {/* `pe-8` reserves a right-hand column for the copy-link button so the step
            text wraps before it and never sits under the icon. Only added when there
            is a link to show. Absolute insets resolve against this padding box, so the
            icon still sits flush at the edge, clear of the text. */}
        <div className={cn("relative", fullId !== undefined && "pe-8")}>
          {children}
          {fullId !== undefined ? <CopyStepLink fullId={fullId} /> : null}
        </div>
      </FumadocsStep>
    </div>
  )
}
