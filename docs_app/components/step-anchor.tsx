import { Step as FumadocsStep } from "fumadocs-ui/components/steps"
import type { ReactNode } from "react"

// Thin wrapper around fumadocs' `Step` that also accepts an `id`, so an
// individual step can be deep-linked (e.g. `#ios-setup-step-2`).
//
// We render the real fumadocs `Step` (which is `<div className="fd-step">`) and
// only add an outer id-bearing element for the deep link, because fumadocs'
// `Step` forwards no props — it accepts `children` only. Wrapping is safe: the
// step numbering is driven by CSS counters (`counter-increment: step` on
// `.fd-step`, `counter-reset: step` on `.fd-steps`) and the numbered circle is
// positioned relative to `.fd-steps`, so an extra unstyled wrapper changes
// neither the numbering nor the layout.
//
// `scroll-m-24` gives the deep-link target the same `scroll-margin-top` fumadocs
// puts on its own accordion anchors (see `AccordionItem` in fumadocs-ui), so a
// step scrolled to via `element.scrollIntoView()` clears the sticky header
// exactly like a whole-accordion or heading anchor does.
export function Step({ id, children }: { id?: string; children: ReactNode }) {
  return (
    <div id={id} className="scroll-m-24">
      <FumadocsStep>{children}</FumadocsStep>
    </div>
  )
}
