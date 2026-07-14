"use client"

import { createContext, useContext, useEffect, useState, type ReactNode } from "react"

// Reading `location.hash` is the single imperative edge for deep-linking, and it
// lives here. `HashProvider` is the ONLY place in the app that attaches a
// `hashchange` listener; every consumer (`SetupAccordions`, `Step`) derives its
// behavior from the value it publishes instead of listening on its own.
const HashContext = createContext("")

function currentHash(): string {
  return decodeURIComponent(window.location.hash.slice(1))
}

// Mounted once, high in the docs layout. Holds the current fragment in state and
// keeps it in sync via one listener, so the whole page reacts to a single source
// of truth.
export function HashProvider({ children }: { children: ReactNode }) {
  const [hash, setHash] = useState("")

  useEffect(() => {
    const sync = () => setHash(currentHash())
    sync()
    window.addEventListener("hashchange", sync)
    return () => window.removeEventListener("hashchange", sync)
  }, [])

  return <HashContext.Provider value={hash}>{children}</HashContext.Provider>
}

// The current URL fragment (without the leading `#`, decoded), kept in sync by
// the single `HashProvider` listener. Empty string when there is no fragment.
export function useHash(): string {
  return useContext(HashContext)
}
