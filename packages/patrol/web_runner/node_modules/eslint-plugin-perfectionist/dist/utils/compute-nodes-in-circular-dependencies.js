'use strict'
Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' })
function computeNodesInCircularDependencies(elements) {
  let elementsInCycles = /* @__PURE__ */ new Set()
  let visitingElements = /* @__PURE__ */ new Set()
  let visitedElements = /* @__PURE__ */ new Set()
  function depthFirstSearch(element, path) {
    if (visitedElements.has(element)) {
      return
    }
    if (visitingElements.has(element)) {
      let cycleStartIndex = path.indexOf(element)
      if (cycleStartIndex !== -1) {
        for (let cycleElements of path.slice(cycleStartIndex)) {
          elementsInCycles.add(cycleElements)
        }
      }
      return
    }
    visitingElements.add(element)
    path.push(element)
    for (let dependency of element.dependencies) {
      let dependencyElement = elements
        .filter(currentElement => currentElement !== element)
        .find(currentElement =>
          currentElement.dependencyNames.includes(dependency),
        )
      if (dependencyElement) {
        depthFirstSearch(dependencyElement, [...path])
      }
    }
    visitingElements.delete(element)
    visitedElements.add(element)
  }
  for (let element of elements) {
    if (!visitedElements.has(element)) {
      depthFirstSearch(element, [])
    }
  }
  return elementsInCycles
}
exports.computeNodesInCircularDependencies = computeNodesInCircularDependencies
