// Scrolls the page so a deep-link target (`el`) sits below the sticky top stack,
// honoring the element's CSS `scroll-margin-top` (`--fd-docs-row-3` + the shared
// `--patrol-anchor-scroll-gap`, see `global.css`).
//
// We compute the target position and call `window.scrollTo` rather than
// `el.scrollIntoView({ block: "start" })`. `scrollIntoView` aligns against the
// element's *nearest scroll container*, and the setup accordions nest their targets
// inside `overflow: hidden` wrappers (fumadocs' accordion list and Radix' animated
// content). An `overflow: hidden` box is still a scroll container, so `scrollIntoView`
// aligns the section header against that clipped scrollport and then scrolls the window
// without re-applying the header's `scroll-margin-top` — landing it flush under the
// bar. Scrolling the window to an absolute offset sidesteps those inner scrollports;
// reading the computed `scroll-margin-top` keeps CSS the single source of truth.
export function scrollAnchorBelowStickyHeader(el: HTMLElement): void {
  const marginTop = Number.parseFloat(getComputedStyle(el).scrollMarginTop) || 0
  const top = el.getBoundingClientRect().top + window.scrollY - marginTop
  window.scrollTo({ top })
}
