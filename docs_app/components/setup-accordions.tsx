"use client"

import { useHash } from "@/components/hash-context"
import { Accordions as FumadocsAccordions } from "fumadocs-ui/components/accordion"
import { Children, cloneElement, isValidElement, useEffect, useMemo, useState, type ReactNode } from "react"

type AccordionChildProps = { id?: string; value?: string }

// Resolves a hash to the section that owns it. Longest match wins so a section id
// that itself contains a hyphen (e.g. `old-android-setup`) isn't clipped to `old`.
function sectionForHash(hash: string, sectionIds: string[]): string | undefined {
  return sectionIds.filter(id => hash === id || hash.startsWith(`${id}-`)).sort((a, b) => b.length - a.length)[0]
}

// Controlled replacement for fumadocs' `Accordions`. Passing `value` +
// `onValueChange` forces the underlying Radix Root into controlled mode because
// fumadocs spreads incoming props onto it last. Each child's open value is pinned
// to its `id` (via `cloneElement`) so a hash slug addresses the right section.
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

  // Open the hash's section when the hash changes to one we own.
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
