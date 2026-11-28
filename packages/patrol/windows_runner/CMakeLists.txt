cmake_minimum_required(VERSION 3.16)
project(patrol_windows_runner LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(patrol_windows_runner
  src/main.cpp
  src/automator_server.cpp
  src/test_orchestrator.cpp
  src/patrol_app_service_client.cpp
  src/dart_test_tree.cpp
  src/native/windows_input.cpp
  src/native/windows_app_control.cpp
  src/native/windows_ui_automation.cpp
)

target_include_directories(patrol_windows_runner PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/src
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party
)

target_compile_definitions(patrol_windows_runner PRIVATE
  WIN32_LEAN_AND_MEAN
  NOMINMAX
  _CRT_SECURE_NO_WARNINGS
  WINVER=0x0A00
  _WIN32_WINNT=0x0A00
)

if(MSVC)
  target_compile_options(patrol_windows_runner PRIVATE /W3 /EHsc /utf-8)
endif()

target_link_libraries(patrol_windows_runner PRIVATE
  ole32
  oleaut32
  user32
  shell32
  ws2_32
  UIAutomationCore
)

set_target_properties(patrol_windows_runner PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${CMAKE_BINARY_DIR}/bin"
)
