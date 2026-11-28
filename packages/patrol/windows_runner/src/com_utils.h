#pragma once

#include "util.h"

#include <UIAutomation.h>
#include <objbase.h>

#include <stdexcept>
#include <string>

namespace patrol {

template <typename T>
class ComPtr {
 public:
  ComPtr() = default;
  explicit ComPtr(T* ptr) : ptr_(ptr) {}
  ComPtr(const ComPtr&) = delete;
  ComPtr& operator=(const ComPtr&) = delete;
  ComPtr(ComPtr&& other) noexcept : ptr_(other.ptr_) { other.ptr_ = nullptr; }
  ComPtr& operator=(ComPtr&& other) noexcept {
    if (this != &other) {
      reset();
      ptr_ = other.ptr_;
      other.ptr_ = nullptr;
    }
    return *this;
  }
  ~ComPtr() { reset(); }

  T* get() const { return ptr_; }
  T** put() {
    reset();
    return &ptr_;
  }
  T* operator->() const { return ptr_; }
  explicit operator bool() const { return ptr_ != nullptr; }

  void reset(T* ptr = nullptr) {
    if (ptr_) {
      ptr_->Release();
    }
    ptr_ = ptr;
  }

 private:
  T* ptr_ = nullptr;
};

class ComApartment {
 public:
  ComApartment() {
    const HRESULT hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    if (hr == RPC_E_CHANGED_MODE) {
      throw std::runtime_error(
          "CoInitializeEx: thread is already MTA; UIA requires STA");
    }
    if (FAILED(hr)) {
      throw std::runtime_error("CoInitializeEx failed");
    }
    initialized_ = true;
  }

  ~ComApartment() {
    if (initialized_) {
      CoUninitialize();
    }
  }

  ComApartment(const ComApartment&) = delete;
  ComApartment& operator=(const ComApartment&) = delete;

 private:
  bool initialized_ = false;
};

inline ComPtr<IUIAutomation> CreateAutomation() {
  ComPtr<IUIAutomation> automation;
  const HRESULT hr = CoCreateInstance(
      CLSID_CUIAutomation,
      nullptr,
      CLSCTX_INPROC_SERVER,
      IID_PPV_ARGS(automation.put()));
  if (FAILED(hr) || !automation) {
    throw std::runtime_error("Failed to create UI Automation instance");
  }
  return automation;
}

inline void ThrowIfFailed(HRESULT hr, const char* what) {
  if (FAILED(hr)) {
    throw std::runtime_error(std::string(what) + " failed");
  }
}

}  // namespace patrol
