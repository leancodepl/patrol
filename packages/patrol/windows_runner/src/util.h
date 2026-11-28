#pragma once

#include <chrono>
#include <cwctype>
#include <stdexcept>
#include <string>
#include <string_view>

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif

#include <Windows.h>
#include <oleauto.h>

namespace patrol {

class BadRequestError : public std::runtime_error {
 public:
  explicit BadRequestError(const std::string& message)
      : std::runtime_error(message) {}
};

class NotFoundError : public std::runtime_error {
 public:
  explicit NotFoundError(const std::string& message)
      : std::runtime_error(message) {}
};

inline std::wstring Utf8ToWide(std::string_view utf8) {
  if (utf8.empty()) {
    return {};
  }
  const int size = MultiByteToWideChar(
      CP_UTF8,
      0,
      utf8.data(),
      static_cast<int>(utf8.size()),
      nullptr,
      0);
  if (size <= 0) {
    throw BadRequestError("Failed to convert UTF-8 string to UTF-16");
  }
  std::wstring wide(static_cast<size_t>(size), L'\0');
  MultiByteToWideChar(
      CP_UTF8,
      0,
      utf8.data(),
      static_cast<int>(utf8.size()),
      wide.data(),
      size);
  return wide;
}

inline std::string WideToUtf8(std::wstring_view wide) {
  if (wide.empty()) {
    return {};
  }
  const int size = WideCharToMultiByte(
      CP_UTF8,
      0,
      wide.data(),
      static_cast<int>(wide.size()),
      nullptr,
      0,
      nullptr,
      nullptr);
  if (size <= 0) {
    return {};
  }
  std::string utf8(static_cast<size_t>(size), '\0');
  WideCharToMultiByte(
      CP_UTF8,
      0,
      wide.data(),
      static_cast<int>(wide.size()),
      utf8.data(),
      size,
      nullptr,
      nullptr);
  return utf8;
}

inline std::string BstrToUtf8(BSTR value) {
  if (value == nullptr) {
    return {};
  }
  return WideToUtf8(std::wstring_view(value, SysStringLen(value)));
}

inline bool EqualsIgnoreCase(std::wstring_view a, std::wstring_view b) {
  if (a.size() != b.size()) {
    return false;
  }
  for (size_t i = 0; i < a.size(); ++i) {
    if (towlower(a[i]) != towlower(b[i])) {
      return false;
    }
  }
  return true;
}

inline bool ContainsIgnoreCase(std::wstring_view haystack,
                               std::wstring_view needle) {
  if (needle.empty()) {
    return true;
  }
  if (haystack.size() < needle.size()) {
    return false;
  }
  for (size_t i = 0; i + needle.size() <= haystack.size(); ++i) {
    if (EqualsIgnoreCase(haystack.substr(i, needle.size()), needle)) {
      return true;
    }
  }
  return false;
}

inline std::wstring NormalizeProcessName(std::wstring name) {
  while (!name.empty() && iswspace(name.front())) {
    name.erase(name.begin());
  }
  while (!name.empty() && iswspace(name.back())) {
    name.pop_back();
  }
  if (name.size() >= 4) {
    const auto ext = name.substr(name.size() - 4);
    if (EqualsIgnoreCase(ext, L".exe")) {
      name.resize(name.size() - 4);
    }
  }
  return name;
}

template <typename Fn>
bool RetryUntil(std::chrono::milliseconds timeout,
                std::chrono::milliseconds interval,
                Fn&& fn) {
  const auto deadline = std::chrono::steady_clock::now() + timeout;
  for (;;) {
    if (fn()) {
      return true;
    }
    if (std::chrono::steady_clock::now() >= deadline) {
      return false;
    }
    Sleep(static_cast<DWORD>(interval.count()));
  }
}

}  // namespace patrol
