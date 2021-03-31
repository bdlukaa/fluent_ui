cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "fluent_ui")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "fluent_ui_plugin")

add_library(${PLUGIN_NAME} SHARED
  "fluent_ui_plugin.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

set(fluent_ui_bundled_libraries
  ""
  PARENT_SCOPE
)
