"use client"

import { useHash } from "@/components/hash-context"
import { Accordions as FumadocsAccordions } from "fumadocs-ui/components/accordion"
import { Children, cloneElement, isValidElement, useEffect, useMemo, useState, type ReactNode } from "react"

type AccordionChildProps = { id?: string; value?: string }

// Resolves a hash fragment to the section that should open. A step's full id is
// `${sectionId}-${slug}`, so the owning section is the accordion id that either
// equals the hash or is a `-`-delimited prefix of it. We match against the KNOWN
// set of accordion ids and take the longest match, so a section id that itself
// contains a hyphen (e.g. `old-android-setup`) resolves correctly instead of
// being clipped to `old` the way a positional `-step-n` regex would.
function sectionForHash(hash: string, sectionIds: string[]): string | undefined {
  return sectionIds.filter(id => hash === id || hash.startsWith(`${id}-`)).sort((a, b) => b.length - a.length)[0]
}

// A controlled replacement for fumadocs' `Accordions`. It owns the open value as
// React state so manual clicks still toggle sections, and it opens the section
// addressed by the hash declaratively — no code ever pokes the DOM to expand a
// section (no `getElementById`, no synthetic trigger click, no `aria-expanded`
// polling).
//
// fumadocs' `Accordions` spreads incoming props onto the underlying Radix
// `Accordion.Root` last, so passing `value` + `onValueChange` puts it into
// controlled mode and overrides its internal `useState`/hash effect. Each child
// `Accordion`'s open value defaults to `String(title)`; we pin it to the child's
// `id` (via `cloneElement`) so a hash slug addresses the right section, and we
// collect those ids so this group only reacts to hashes it actually owns.
export function SetupAccordions({ children }: { children: ReactNode }) {
  const hash = useHash()
  const [value, setValue] = useState("")

  const { items, sectionIds } = useMemo(() => {
    const sectionIds: string[] = []
    const items = Children.map(children, child => {
      if (!isValidElement<AccordionChildProps>(child) || typeof child.props.id !== "string") return child
      sectionIds.push(child.props.id)
      return cloneElement(child, { value: child.props.id })
    })
    return { items, sectionIds }
  }, [children])

  // Open the hash's section when the hash changes to one we own. This reacts to
  // the `useHash()` value published by the single `HashProvider` listener — it
  // is not a listener of its own.
  useEffect(() => {
    const section = sectionForHash(hash, sectionIds)
    if (section) setValue(section)
  }, [hash, sectionIds])

  return (
    <FumadocsAccordions type="single" value={value} onValueChange={setValue}>
      {items}
    </FumadocsAccordions>
  )
}
