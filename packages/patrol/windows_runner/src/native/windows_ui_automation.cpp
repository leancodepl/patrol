#include "native/windows_ui_automation.h"

#include <iostream>
#include <sstream>

#include "com_utils.h"
#include "native/windows_app_control.h"
#include "native/windows_input.h"
#include "util.h"

namespace patrol {
namespace {

constexpr auto kDefaultFindTimeout = std::chrono::seconds(10);

class ScopedVariant {
 public:
  explicit ScopedVariant(int value) {
    VariantInit(&v_);
    v_.vt = VT_I4;
    v_.lVal = value;
  }
  explicit ScopedVariant(const wchar_t* value) {
    VariantInit(&v_);
    v_.vt = VT_BSTR;
    v_.bstrVal = SysAllocString(value);
  }
  ~ScopedVariant() { VariantClear(&v_); }
  ScopedVariant(const ScopedVariant&) = delete;
  ScopedVariant& operator=(const ScopedVariant&) = delete;
  VARIANT* get() { return &v_; }

 private:
  VARIANT v_{};
};

ComPtr<IUIAutomationCondition> BuildCondition(IUIAutomation* automation,
                                              const UiSelector& selector) {
  ComPtr<IUIAutomationCondition> condition;

  auto and_with = [&](ComPtr<IUIAutomationCondition> next) {
    if (!condition) {
      condition = std::move(next);
      return;
    }
    ComPtr<IUIAutomationCondition> combined;
    ThrowIfFailed(
        automation->CreateAndCondition(
            condition.get(), next.get(), combined.put()),
        "CreateAndCondition");
    condition = std::move(combined);
  };

  if (selector.name.has_value()) {
    ScopedVariant value(selector.name->c_str());
    ComPtr<IUIAutomationCondition> part;
    ThrowIfFailed(
        automation->CreatePropertyCondition(
            UIA_NamePropertyId, *value.get(), part.put()),
        "CreatePropertyCondition(Name)");
    and_with(std::move(part));
  }
  if (selector.automation_id.has_value()) {
    ScopedVariant value(selector.automation_id->c_str());
    ComPtr<IUIAutomationCondition> part;
    ThrowIfFailed(
        automation->CreatePropertyCondition(
            UIA_AutomationIdPropertyId, *value.get(), part.put()),
        "CreatePropertyCondition(AutomationId)");
    and_with(std::move(part));
  }
  if (selector.class_name.has_value()) {
    ScopedVariant value(selector.class_name->c_str());
    ComPtr<IUIAutomationCondition> part;
    ThrowIfFailed(
        automation->CreatePropertyCondition(
            UIA_ClassNamePropertyId, *value.get(), part.put()),
        "CreatePropertyCondition(ClassName)");
    and_with(std::move(part));
  }

  if (!condition) {
    throw BadRequestError("Selector produced no condition");
  }
  return condition;
}

bool TryGetSearchRoot(IUIAutomation* automation,
                      const UiSelector& selector,
                      ComPtr<IUIAutomationElement>& root) {
  if (!selector.within.has_value() || selector.within->empty()) {
    ThrowIfFailed(automation->GetRootElement(root.put()), "GetRootElement");
    return true;
  }

  const auto& scope = *selector.within;
  root = WindowsAppControl::TryFindWindow(
      automation, scope.process_name, scope.window_name, scope.process_id);
  return static_cast<bool>(root);
}

ComPtr<IUIAutomationElement> FindElement(
    IUIAutomation* automation,
    const UiSelector& selector,
    std::chrono::milliseconds find_timeout) {
  ComPtr<IUIAutomationElement> match;
  const bool found = RetryUntil(
      find_timeout, std::chrono::milliseconds(200), [&] {
        try {
          ComPtr<IUIAutomationElement> root;
          if (!TryGetSearchRoot(automation, selector, root)) {
            return false;
          }

          auto condition = BuildCondition(automation, selector);
          ComPtr<IUIAutomationElementArray> matches;
          if (FAILED(root->FindAll(
                  TreeScope_Descendants, condition.get(), matches.put())) ||
              !matches) {
            return false;
          }
          int length = 0;
          if (FAILED(matches->get_Length(&length)) ||
              length <= selector.index) {
            return false;
          }
          if (FAILED(matches->GetElement(selector.index, match.put())) ||
              !match) {
            return false;
          }
          return true;
        } catch (const BadRequestError&) {
          throw;
        } catch (...) {
          // Transient UIA failures: keep polling until timeout → 404.
          return false;
        }
      });

  if (!found || !match) {
    throw NotFoundError(
        "No UI element found (" + selector.to_string() + ") within timeout");
  }
  return match;
}

void ClickElement(IUIAutomationElement* element, const UiSelector& selector) {
  RECT rect{};
  ThrowIfFailed(element->get_CurrentBoundingRectangle(&rect),
                "get_CurrentBoundingRectangle");
  if (rect.right <= rect.left || rect.bottom <= rect.top) {
    throw NotFoundError(
        "UI element (" + selector.to_string() +
        ") has an empty bounding rectangle");
  }

  std::cout << "WindowsUiAutomation: tap(" << selector.to_string() << ")\n";

  ComPtr<IUIAutomationInvokePattern> invoke;
  if (SUCCEEDED(element->GetCurrentPatternAs(
          UIA_InvokePatternId, IID_PPV_ARGS(invoke.put()))) &&
      invoke) {
    ThrowIfFailed(invoke->Invoke(), "Invoke");
    return;
  }

  ComPtr<IUIAutomationTogglePattern> toggle;
  if (SUCCEEDED(element->GetCurrentPatternAs(
          UIA_TogglePatternId, IID_PPV_ARGS(toggle.put()))) &&
      toggle) {
    ThrowIfFailed(toggle->Toggle(), "Toggle");
    return;
  }

  element->SetFocus();
  const int pixel_x = static_cast<int>((rect.left + rect.right) / 2);
  const int pixel_y = static_cast<int>((rect.top + rect.bottom) / 2);
  WindowsInput::TapAtPixels(pixel_x, pixel_y);
}

UiElementInfo ToInfo(IUIAutomationElement* element) {
  UiElementInfo info;
  BSTR name = nullptr;
  if (SUCCEEDED(element->get_CurrentName(&name)) && name != nullptr) {
    info.name = BstrToUtf8(name);
    SysFreeString(name);
  }
  BSTR class_name = nullptr;
  if (SUCCEEDED(element->get_CurrentClassName(&class_name)) &&
      class_name != nullptr) {
    info.class_name = BstrToUtf8(class_name);
    SysFreeString(class_name);
  }
  BSTR automation_id = nullptr;
  if (SUCCEEDED(element->get_CurrentAutomationId(&automation_id)) &&
      automation_id != nullptr) {
    const auto value = BstrToUtf8(automation_id);
    SysFreeString(automation_id);
    if (!value.empty()) {
      info.automation_id = value;
    }
  }

  RECT rect{};
  if (SUCCEEDED(element->get_CurrentBoundingRectangle(&rect))) {
    info.x = rect.left;
    info.y = rect.top;
    info.width = rect.right - rect.left;
    info.height = rect.bottom - rect.top;
  }
  return info;
}

}  // namespace

std::string UiSelector::to_string() const {
  std::ostringstream oss;
  bool first = true;
  auto add = [&](const char* key, const std::wstring& value) {
    if (!first) {
      oss << ", ";
    }
    first = false;
    oss << key << "=\"" << WideToUtf8(value) << "\"";
  };
  if (name.has_value()) {
    add("name", *name);
  }
  if (automation_id.has_value()) {
    add("automationId", *automation_id);
  }
  if (class_name.has_value()) {
    add("className", *class_name);
  }
  if (index != 0) {
    if (!first) {
      oss << ", ";
    }
    first = false;
    oss << "index=" << index;
  }
  return oss.str();
}

void WindowsUiAutomation::WaitUntilVisible(
    const UiSelector& selector,
    std::optional<std::chrono::milliseconds> find_timeout) {
  ComApartment apartment;
  auto automation = CreateAutomation();
  (void)FindElement(
      automation.get(),
      selector,
      find_timeout.value_or(kDefaultFindTimeout));
}

bool WindowsUiAutomation::IsElementVisible(
    const UiSelector& selector,
    std::optional<std::chrono::milliseconds> find_timeout) {
  ComApartment apartment;
  auto automation = CreateAutomation();
  try {
    (void)FindElement(
        automation.get(),
        selector,
        find_timeout.value_or(std::chrono::milliseconds(500)));
    return true;
  } catch (const NotFoundError&) {
    return false;
  }
}

void WindowsUiAutomation::Tap(
    const UiSelector& selector,
    std::optional<std::chrono::milliseconds> find_timeout) {
  ComApartment apartment;
  auto automation = CreateAutomation();
  auto element = FindElement(
      automation.get(),
      selector,
      find_timeout.value_or(kDefaultFindTimeout));
  ClickElement(element.get(), selector);
}

void WindowsUiAutomation::EnterText(
    const UiSelector& selector,
    const std::string& text,
    std::optional<std::chrono::milliseconds> find_timeout) {
  ComApartment apartment;
  auto automation = CreateAutomation();
  auto element = FindElement(
      automation.get(),
      selector,
      find_timeout.value_or(kDefaultFindTimeout));
  element->SetFocus();

  const std::wstring wide = Utf8ToWide(text);
  ComPtr<IUIAutomationValuePattern> value;
  if (SUCCEEDED(element->GetCurrentPatternAs(
          UIA_ValuePatternId, IID_PPV_ARGS(value.put()))) &&
      value) {
    BSTR bstr = SysAllocString(wide.c_str());
    const HRESULT hr = value->SetValue(bstr);
    SysFreeString(bstr);
    ThrowIfFailed(hr, "SetValue");
  } else {
    throw std::runtime_error(
        "Element does not support ValuePattern for enterText");
  }

  std::cout << "WindowsUiAutomation: enterText(" << selector.to_string()
            << ", length=" << text.size() << ")\n";
}

std::optional<UiElementInfo> WindowsUiAutomation::FindElementInfo(
    const UiSelector& selector,
    std::optional<std::chrono::milliseconds> find_timeout) {
  ComApartment apartment;
  auto automation = CreateAutomation();
  try {
    auto element = FindElement(
        automation.get(),
        selector,
        find_timeout.value_or(kDefaultFindTimeout));
    return ToInfo(element.get());
  } catch (const NotFoundError&) {
    return std::nullopt;
  }
}

void WindowsUiAutomation::PressKey(int key_code,
                                   bool shift,
                                   bool ctrl,
                                   bool alt) {
  WindowsInput::PressKey(key_code, shift, ctrl, alt);
  std::cout << "WindowsUiAutomation: pressKey(keyCode=" << key_code << ")\n";
}

}  // namespace patrol
