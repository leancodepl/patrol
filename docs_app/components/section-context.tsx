"use client"

import { createContext, useContext } from "react"

// The id of the enclosing setup section (a `SetupAccordion`'s `id`). A `Step`
// reads it to compose its full, stable deep-link id as `${sectionId}-${slug}`,
// so authors write only a short semantic slug per step and never repeat the
// section prefix. `undefined` when a step is rendered outside any section.
const SectionContext = createContext<string | undefined>(undefined)

export const SectionProvider = SectionContext.Provider

export function useSectionId(): string | undefined {
  return useContext(SectionContext)
}
