"use client"

import { createContext, useContext, useSyncExternalStore, type ReactNode } from "react"

// Reading `location.hash` is the single imperative edge for deep-linking, and it
// lives here. `HashProvider` is the ONLY place in the app that attaches a
// `hashchange` listener; every consumer (`SetupAccordions`, `Step`) derives its
// behavior from the value it publishes instead of listening on its own.
const HashContext = createContext("")

function subscribe(onStoreChange: () => void): () => void {
  window.addEventListener("hashchange", onStoreChange)
  return () => window.removeEventListener("hashchange", onStoreChange)
}

// The current URL fragment, decoded, without the leading `#`.
function getSnapshot(): string {
  return decodeURIComponent(window.location.hash.slice(1))
}

// No hash on the server; returning "" avoids a hydration mismatch.
function getServerSnapshot(): string {
  return ""
}

// Mounted once, high in the docs layout. Subscribes to `hashchange` a single
// time and publishes the current fragment through context, so the whole page
// reacts to a single source of truth.
export function HashProvider({ children }: { children: ReactNode }) {
  const hash = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot)

  return <HashContext.Provider value={hash}>{children}</HashContext.Provider>
}

// The current URL fragment (without the leading `#`, decoded), kept in sync by
// the single `HashProvider` subscription. Empty string when there is no fragment.
export function useHash(): string {
  return useContext(HashContext)
}
