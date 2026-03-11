//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_acrylic/flutter_acrylic_plugin.h>
#include <screen_retriever_linux/screen_retriever_linux_plugin.h>
#include <system_theme/system_theme_plugin.h>
#include <window_manager/window_manager_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) flutter_acrylic_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterAcrylicPlugin");
  flutter_acrylic_plugin_register_with_registrar(flutter_acrylic_registrar);
  g_autoptr(FlPluginRegistrar) screen_retriever_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ScreenRetrieverLinuxPlugin");
  screen_retriever_linux_plugin_register_with_registrar(screen_retriever_linux_registrar);
  g_autoptr(FlPluginRegistrar) system_theme_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SystemThemePlugin");
  system_theme_plugin_register_with_registrar(system_theme_registrar);
  g_autoptr(FlPluginRegistrar) window_manager_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WindowManagerPlugin");
  window_manager_plugin_register_with_registrar(window_manager_registrar);
}
