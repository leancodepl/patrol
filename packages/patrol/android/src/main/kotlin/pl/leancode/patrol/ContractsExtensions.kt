package pl.leancode.patrol

import androidx.test.uiautomator.By
import androidx.test.uiautomator.BySelector
import androidx.test.uiautomator.UiSelector
import pl.leancode.patrol.contracts.Contracts.AndroidSelector
import pl.leancode.patrol.contracts.Contracts.DartGroupEntry
import pl.leancode.patrol.contracts.Contracts.GroupEntryType
import pl.leancode.patrol.contracts.Contracts.Selector

private fun Selector.isEmpty(): Boolean {
    return (
        !hasText() &&
            !hasTextStartsWith() &&
            !hasTextContains() &&
            !hasClassName() &&
            !hasContentDescription() &&
            !hasContentDescriptionStartsWith() &&
            !hasContentDescriptionContains() &&
            !hasResourceId() &&
            !hasInstance() &&
            !hasEnabled() &&
            !hasFocused() &&
            !hasPkg()
        )
}

fun Selector.toUiSelector(): UiSelector {
    var selector = UiSelector()

    if (hasText()) {
        selector = selector.text(text)
    }

    if (hasTextStartsWith()) {
        selector = selector.textStartsWith(textStartsWith)
    }

    if (hasTextContains()) {
        selector = selector.textContains(textContains)
    }

    if (hasClassName()) {
        selector = selector.className(className)
    }

    if (hasContentDescription()) {
        selector = selector.description(contentDescription)
    }

    if (hasContentDescriptionStartsWith()) {
        selector = selector.descriptionStartsWith(contentDescriptionStartsWith)
    }

    if (hasContentDescriptionContains()) {
        selector = selector.descriptionContains(contentDescriptionContains)
    }

    if (hasResourceId()) {
        selector = selector.resourceId(resourceId)
    }

    if (hasInstance()) {
        selector = selector.instance(instance!!.toInt())
    }

    if (hasEnabled()) {
        selector = selector.enabled(enabled!!)
    }

    if (hasFocused()) {
        selector = selector.focused(focused!!)
    }

    if (hasPkg()) {
        selector = selector.packageName(pkg)
    }

    return selector
}

fun Selector.toBySelector(): BySelector {
    if (isEmpty()) {
        throw PatrolException("Selector is empty")
    }

    var matchedText = false
    var matchedTextStartsWith = false
    var matchedTextContains = false
    var matchedClassName = false
    var matchedContentDescription = false
    var matchedContentDescriptionStartsWith = false
    var matchedContentDescriptionContains = false
    var matchedResourceId = false
    var matchedEnabled = false
    var matchedFocused = false
    var matchedPkg = false

    var bySelector =
        if (hasText()) {
            matchedText = true
            By.text(text)
        } else if (hasTextStartsWith()) {
            matchedTextStartsWith = true
            By.textStartsWith(textStartsWith)
        } else if (hasTextContains()) {
            matchedTextContains = true
            By.textContains(textContains)
        } else if (hasClassName()) {
            matchedClassName = true
            By.clazz(className)
        } else if (hasContentDescription()) {
            matchedContentDescription = true
            By.desc(contentDescription)
        } else if (hasContentDescriptionStartsWith()) {
            matchedContentDescriptionStartsWith = true
            By.descStartsWith(contentDescriptionStartsWith)
        } else if (hasContentDescriptionContains()) {
            matchedContentDescriptionContains = true
            By.descContains(contentDescriptionContains)
        } else if (hasResourceId()) {
            matchedResourceId = true
            By.res(resourceId)
        } else if (hasInstance()) {
            throw IllegalArgumentException("instance() argument is not supported for BySelector")
        } else if (hasEnabled()) {
            matchedEnabled = true
            By.enabled(enabled!!)
        } else if (hasFocused()) {
            matchedFocused = true
            By.focused(focused!!)
        } else if (hasPkg()) {
            matchedPkg = true
            By.pkg(pkg)
        } else {
            throw IllegalArgumentException("SelectorQuery is empty")
        }

    if (!matchedText && hasText()) {
        bySelector = By.copy(bySelector).text(text)
    }

    if (!matchedTextStartsWith && hasTextStartsWith()) {
        bySelector = By.copy(bySelector).textStartsWith(textStartsWith)
    }

    if (!matchedTextContains && hasTextContains()) {
        bySelector = By.copy(bySelector).textContains(textContains)
    }

    if (!matchedClassName && hasClassName()) {
        bySelector = By.copy(bySelector).clazz(className)
    }

    if (!matchedContentDescription && hasContentDescription()) {
        bySelector = By.copy(bySelector).desc(contentDescription)
    }

    if (!matchedContentDescriptionStartsWith && hasContentDescriptionStartsWith()) {
        bySelector = By.copy(bySelector).descStartsWith(contentDescriptionStartsWith)
    }

    if (!matchedContentDescriptionContains && hasContentDescriptionContains()) {
        bySelector = By.copy(bySelector).descContains(contentDescriptionContains)
    }

    if (!matchedResourceId && hasResourceId()) {
        bySelector = By.copy(bySelector).res(resourceId)
    }

    if (hasInstance()) {
        // We handle the index (aka "instance") ourselves
    }

    if (!matchedEnabled && hasEnabled()) {
        bySelector = bySelector.enabled(enabled!!)
    }

    if (!matchedFocused && hasFocused()) {
        bySelector = bySelector.focused(focused!!)
    }

    if (!matchedPkg && hasPkg()) {
        bySelector = bySelector.pkg(pkg)
    }

    return bySelector
}

fun AndroidSelector.toUiSelector(): UiSelector {
    var selector = UiSelector()

    if (hasClassName()) {
        selector = selector.className(className)
    }
    if (hasIsCheckable()) {
        selector = selector.checkable(isCheckable!!)
    }
    if (hasIsChecked()) {
        selector = selector.checked(isChecked!!)
    }
    if (hasIsClickable()) {
        selector = selector.clickable(isClickable!!)
    }
    if (hasIsEnabled()) {
        selector = selector.enabled(isEnabled!!)
    }
    if (hasIsFocusable()) {
        selector = selector.focusable(isFocusable!!)
    }
    if (hasIsFocused()) {
        selector = selector.focused(isFocused!!)
    }
    if (hasIsLongClickable()) {
        selector = selector.longClickable(isLongClickable!!)
    }
    if (hasIsScrollable()) {
        selector = selector.scrollable(isScrollable!!)
    }
    if (hasIsSelected()) {
        selector = selector.selected(isSelected!!)
    }
    if (hasApplicationPackage()) {
        selector = selector.packageName(applicationPackage)
    }
    if (hasContentDescription()) {
        selector = selector.description(contentDescription)
    }
    if (hasContentDescriptionStartsWith()) {
        selector = selector.descriptionStartsWith(contentDescriptionStartsWith)
    }
    if (hasContentDescriptionContains()) {
        selector = selector.descriptionContains(contentDescriptionContains)
    }
    if (hasText()) {
        selector = selector.text(text)
    }
    if (hasTextStartsWith()) {
        selector = selector.textStartsWith(textStartsWith)
    }
    if (hasTextContains()) {
        selector = selector.textContains(textContains)
    }
    if (hasResourceName()) {
        selector = selector.resourceId(resourceName)
    }
    if (hasInstance()) {
        selector = selector.instance(instance!!.toInt())
    }

    return selector
}

fun AndroidSelector.toBySelector(): BySelector {
    if (hasInstance()) {
        throw IllegalArgumentException("instance() argument is not supported for BySelector")
    }

    var selector: BySelector? = null

    if (hasClassName()) {
        selector = By.clazz(className)
    }
    if (hasIsCheckable()) {
        selector = selector?.checkable(isCheckable!!) ?: By.checkable(isCheckable!!)
    }
    if (hasIsChecked()) {
        selector = selector?.checked(isChecked!!) ?: By.checked(isChecked!!)
    }
    if (hasIsClickable()) {
        selector = selector?.clickable(isClickable!!) ?: By.clickable(isClickable!!)
    }
    if (hasIsEnabled()) {
        selector = selector?.enabled(isEnabled!!) ?: By.enabled(isEnabled!!)
    }
    if (hasIsFocusable()) {
        selector = selector?.focusable(isFocusable!!) ?: By.focusable(isFocusable!!)
    }
    if (hasIsFocused()) {
        selector = selector?.focused(isFocused!!) ?: By.focused(isFocused!!)
    }
    if (hasIsLongClickable()) {
        selector = selector?.longClickable(isLongClickable!!) ?: By.longClickable(isLongClickable!!)
    }
    if (hasIsScrollable()) {
        selector = selector?.scrollable(isScrollable!!) ?: By.scrollable(isScrollable!!)
    }
    if (hasIsSelected()) {
        selector = selector?.selected(isSelected!!) ?: By.selected(isSelected!!)
    }
    if (hasApplicationPackage()) {
        selector = selector?.pkg(applicationPackage) ?: By.pkg(applicationPackage)
    }
    if (hasContentDescription()) {
        selector = selector?.desc(contentDescription) ?: By.desc(contentDescription)
    }
    if (hasContentDescriptionStartsWith()) {
        selector = selector?.descStartsWith(contentDescriptionStartsWith) ?: By.descStartsWith(
            contentDescriptionStartsWith
        )
    }
    if (hasContentDescriptionContains()) {
        selector = selector?.descContains(contentDescriptionContains) ?: By.descContains(
            contentDescriptionContains
        )
    }
    if (hasText()) {
        selector = selector?.text(text) ?: By.text(text)
    }
    if (hasTextStartsWith()) {
        selector = selector?.textStartsWith(textStartsWith) ?: By.textStartsWith(textStartsWith)
    }
    if (hasTextContains()) {
        selector = selector?.textContains(textContains) ?: By.textContains(textContains)
    }
    if (hasResourceName()) {
        selector = selector?.res(resourceName) ?: By.res(resourceName)
    }

    if (selector == null) {
        throw PatrolException("Selector is empty")
    }

    return selector
}

/**
 * Flattens the structure of a DartTestSuite into a flat list of tests.
 */
fun DartGroupEntry.listTestsFlat(parentGroupName: String = ""): List<DartGroupEntry> {
    val tests = mutableListOf<DartGroupEntry>()

    for (test in entries) {
        if (test.type == GroupEntryType.test) {
            if (parentGroupName.isEmpty()) {
                // This case is invalid, because every test will have at least 1 named group - its filename.
                throw IllegalStateException("Invariant violated: test $test has no named parent group")
            }

            tests.add(test.copy(name = "$parentGroupName ${test.name}"))
        } else if (test.type == GroupEntryType.group) {
            if (parentGroupName.isEmpty()) {
                tests.addAll(test.listTestsFlat(parentGroupName = test.name))
            } else {
                tests.addAll(test.listTestsFlat(parentGroupName = "$parentGroupName ${test.name}"))
            }
        }
    }

    return tests
}
