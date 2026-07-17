"use client"

import { createContext, useContext, useSyncExternalStore, type ReactNode } from "react"

// Publishes the current URL fragment (decoded, no leading `#`) so the page reacts
// to hash changes from a single `hashchange` listener.
const HashContext = createContext("")

function subscribe(onStoreChange: () => void): () => void {
  window.addEventListener("hashchange", onStoreChange)
  return () => window.removeEventListener("hashchange", onStoreChange)
}

function getSnapshot(): string {
  return decodeURIComponent(window.location.hash.slice(1))
}

// "" on the server avoids a hydration mismatch.
function getServerSnapshot(): string {
  return ""
}

export function HashProvider({ children }: { children: ReactNode }) {
  const hash = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot)

  return <HashContext.Provider value={hash}>{children}</HashContext.Provider>
}

export function useHash(): string {
  return useContext(HashContext)
}
