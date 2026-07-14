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
// extra id-bearing wrapper is safe since step numbering is CSS-counter based, and
// `scroll-m-24` matches fumadocs' anchor offset so the target clears the sticky header.
export function Step({ id, children }: { id?: string; children: ReactNode }) {
  const sectionId = useSectionId()
  const hash = useHash()
  const ref = useRef<HTMLDivElement | null>(null)

  const fullId = id === undefined ? undefined : sectionId === undefined ? id : `${sectionId}-${id}`
  const isTarget = fullId !== undefined && hash === fullId

  // Scroll to this step when it becomes the hash target (fires on mount for a cold
  // load once its section opens, and on later hash changes when already mounted).
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
