//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <app_links_linux/app_links_plugin_linux.h>
#include <file_saver/file_saver_plugin.h>
#include <file_selector_linux/file_selector_plugin.h>
#include <flutter_timezone/flutter_timezone_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) app_links_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AppLinksPluginLinux");
  app_links_plugin_linux_register_with_registrar(app_links_linux_registrar);
  g_autoptr(FlPluginRegistrar) file_saver_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FileSaverPlugin");
  file_saver_plugin_register_with_registrar(file_saver_registrar);
  g_autoptr(FlPluginRegistrar) file_selector_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FileSelectorPlugin");
  file_selector_plugin_register_with_registrar(file_selector_linux_registrar);
  g_autoptr(FlPluginRegistrar) flutter_timezone_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterTimezonePlugin");
  flutter_timezone_plugin_register_with_registrar(flutter_timezone_registrar);
}
