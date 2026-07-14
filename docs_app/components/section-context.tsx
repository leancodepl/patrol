"use client"

import { createContext, useContext } from "react"

// The enclosing `SetupAccordion`'s id. A `Step` reads it to build its deep-link id
// as `${sectionId}-${slug}`. `undefined` outside any section.
const SectionContext = createContext<string | undefined>(undefined)

export const SectionProvider = SectionContext.Provider

export function useSectionId(): string | undefined {
  return useContext(SectionContext)
}
