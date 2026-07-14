"use client"

import { useEffect } from "react"

// Deep-links to an individual step inside an accordion, e.g. `#ios-setup-step-2`.
//
// Step ids are prefixed with their accordion's id, which lets us open a
// collapsed accordion (fumadocs unmounts closed accordion content, so the step
// element isn't in the DOM yet) before scrolling to the step.
//
// Whole-accordion ids (e.g. `#ios-setup`) are left to fumadocs' own built-in
// hash handling — we bail out for those so the two don't conflict.
function revealStep() {
  const hash = decodeURIComponent(window.location.hash.slice(1))
  if (!hash) return

  const target = document.getElementById(hash)
  // An accordion header carries its own hash handling — don't interfere.
  if (target?.hasAttribute("data-accordion-value")) return

  // Find the accordion header owning this step: by DOM ancestry when the step
  // is already visible, or by id prefix when it lives in a collapsed panel.
  const header = target ? enclosingHeader(target) : headerByIdPrefix(hash)
  if (!header && !target) return

  const trigger = header?.querySelector<HTMLElement>("[aria-expanded]")
  if (trigger?.getAttribute("aria-expanded") === "false") trigger.click()

  scrollWhenReady(hash)
}

function enclosingHeader(el: Element): Element | null {
  for (let node = el.parentElement; node; node = node.parentElement) {
    const header = node.querySelector(":scope > [data-accordion-value]")
    if (header) return header
  }
  return null
}

function headerByIdPrefix(hash: string): HTMLElement | null {
  const headers = Array.from(document.querySelectorAll<HTMLElement>("[data-accordion-value][id]"))
  let best: HTMLElement | null = null
  for (const h of headers) {
    if (hash !== h.id && !hash.startsWith(`${h.id}-`)) continue
    // Longest matching id wins (e.g. `old-android-setup` over `android-setup`).
    if (!best || h.id.length > best.id.length) best = h
  }
  return best
}

// The accordion content mounts + animates open asynchronously, so retry across
// a few frames until the step element exists, then scroll to it.
function scrollWhenReady(hash: string, attempts = 24) {
  const el = document.getElementById(hash)
  if (el) {
    el.scrollIntoView({ block: "start" })
    return
  }
  if (attempts > 0) requestAnimationFrame(() => scrollWhenReady(hash, attempts - 1))
}

export function HashStepOpener() {
  useEffect(() => {
    revealStep()
    window.addEventListener("hashchange", revealStep)
    return () => window.removeEventListener("hashchange", revealStep)
  }, [])

  return null
}
