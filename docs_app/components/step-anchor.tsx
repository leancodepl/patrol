"use client"

import { useHash } from "@/components/hash-context"
import { useSectionId } from "@/components/section-context"
import { cn } from "@/lib/cn"
import { Step as FumadocsStep } from "fumadocs-ui/components/steps"
import { useCopyButton } from "fumadocs-ui/utils/use-copy-button"
import { Check, LinkIcon } from "lucide-react"
import { useEffect, useRef, type ReactNode } from "react"

// A "copy link" affordance mirroring the one fumadocs shows on accordion
// headers. Hidden until the step is hovered (or the button is focused), it copies
// the step's absolute URL. `navigator.clipboard.writeText` is the only imperative
// edge here — there is no DOM lookup.
//
// It sits absolutely inside an inner wrapper that is a DESCENDANT of `.fd-step`,
// so it never becomes the positioning ancestor of `.fd-step::before` — the
// numbered circle stays anchored to `.fd-steps` and the CSS counter is untouched.
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

// Thin wrapper around fumadocs' `Step` that makes an individual step
// deep-linkable. The author writes only a short semantic slug (e.g.
// `id="create-test-target"`); the enclosing `SetupAccordion` provides its own id
// through `SectionContext`, and we compose the full, STABLE id as
// `${sectionId}-${slug}` (e.g. `ios-setup-create-test-target`). Stable means the
// id never encodes position, so reordering or inserting steps keeps old shared
// links pointing at the same step.
//
// We render the real fumadocs `Step` (a `<div className="fd-step">`) and add an
// outer id-bearing element for the deep link, because fumadocs' `Step` forwards
// no props — it accepts `children` only. Wrapping is safe: step numbering is
// driven by CSS counters (`counter-increment: step` on `.fd-step`,
// `counter-reset: step` on `.fd-steps`) and the numbered circle is positioned
// relative to `.fd-steps`, so an extra unstyled wrapper changes neither the
// numbering nor the layout.
//
// `scroll-m-24` gives the deep-link target the same `scroll-margin-top` fumadocs
// puts on its own accordion anchors, so a step scrolled to via `scrollIntoView()`
// clears the sticky header exactly like a whole-accordion or heading anchor does.
export function Step({ id, children }: { id?: string; children: ReactNode }) {
  const sectionId = useSectionId()
  const hash = useHash()
  const ref = useRef<HTMLDivElement | null>(null)

  const fullId = id === undefined ? undefined : sectionId === undefined ? id : `${sectionId}-${id}`
  const isTarget = fullId !== undefined && hash === fullId

  // Scroll when this step is the hash target. Driven entirely by the `useHash()`
  // value from the single `HashProvider`, so there is no per-step `hashchange`
  // listener. This one effect covers both cases:
  //   - cold load / cross-section: the controlling `SetupAccordions` opens the
  //     section, Radix mounts this step, and the effect runs on mount with the
  //     hash already equal to `fullId` (the ref is populated by then), and
  //   - same-section navigation: the step is already mounted and only the hash
  //     changes to it (e.g. following another step's copy-link).
  useEffect(() => {
    if (isTarget) ref.current?.scrollIntoView({ block: "start" })
  }, [isTarget])

  return (
    <div ref={ref} id={fullId} className="group/step scroll-m-24">
      <FumadocsStep>
        <div className="relative">
          {children}
          {fullId !== undefined ? <CopyStepLink fullId={fullId} /> : null}
        </div>
      </FumadocsStep>
    </div>
  )
}
