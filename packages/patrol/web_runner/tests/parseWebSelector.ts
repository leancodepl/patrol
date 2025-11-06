import { Locator, Page } from "playwright"
import { WebSelector } from "./contracts"

/**
 * Parses a WebSelector and returns a Playwright Locator.
 * Combines all provided selector properties using .and() method.
 */
export function parseWebSelector(page: Page, selector: WebSelector): Locator {
  const selectorMappings: Array<{
    value: string | null
    getter: (value: string) => Locator
  }> = [
    { value: selector.testId, getter: val => page.getByTestId(val) },
    { value: selector.role, getter: val => page.getByRole(val as any) },
    { value: selector.label, getter: val => page.getByLabel(val) },
    { value: selector.placeholder, getter: val => page.getByPlaceholder(val) },
    { value: selector.text, getter: val => page.getByText(val) },
    { value: selector.altText, getter: val => page.getByAltText(val) },
    { value: selector.title, getter: val => page.getByTitle(val) },
    { value: selector.cssOrXpath, getter: val => page.locator(val) },
  ]

  const locators = selectorMappings
    .filter(mapping => mapping.value !== null)
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    .map(mapping => mapping.getter(mapping.value!))

  if (locators.length === 0) {
    throw new Error("WebSelector must have at least one property defined")
  }

  let combinedLocator = locators[0]
  for (let i = 1; i < locators.length; i++) {
    combinedLocator = combinedLocator.and(locators[i])
  }

  return combinedLocator
}
