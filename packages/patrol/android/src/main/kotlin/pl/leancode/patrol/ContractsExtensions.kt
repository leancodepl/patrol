package pl.leancode.patrol

import androidx.test.uiautomator.By
import androidx.test.uiautomator.BySelector
import androidx.test.uiautomator.UiSelector
import pl.leancode.patrol.contracts.Contracts
import pl.leancode.patrol.contracts.Contracts.DartTestGroup

private fun Contracts.Selector.isEmpty(): Boolean {
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

fun Contracts.Selector.toUiSelector(): UiSelector {
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
        selector = selector.instance(instance)
    }

    if (hasEnabled()) {
        selector = selector.enabled(enabled)
    }

    if (hasFocused()) {
        selector = selector.focused(focused)
    }

    if (hasPkg()) {
        selector = selector.packageName(pkg)
    }

    return selector
}

fun Contracts.Selector.toBySelector(): BySelector {
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

    var bySelector = if (hasText()) {
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
        By.enabled(enabled)
    } else if (hasFocused()) {
        matchedFocused = true
        By.focused(focused)
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
        bySelector = bySelector.enabled(enabled)
    }

    if (!matchedFocused && hasFocused()) {
        bySelector = bySelector.focused(focused)
    }

    if (!matchedPkg && hasPkg()) {
        bySelector = bySelector.pkg(pkg)
    }

    return bySelector
}

fun DartTestGroup.listFlatDartFiles(): List<String> {
    val files = mutableListOf<String>()
    for (group in groupsList) {
        files.addAll(group.listGroups())
    }

    return files
}

// Recursively lists groups in this group.
private fun DartTestGroup.listGroups(): List<String> {
    val groups = mutableListOf<String>(this.name)
    for (group in groupsList) {
        groups.addAll(group.listGroups())
    }

    return groups
}