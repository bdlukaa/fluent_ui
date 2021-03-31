cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "fluent_ui")
project(${PROJECT_NAME} LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)

set(PLUGIN_NAME "fluent_ui_plugin")

include_directories(
  ${PLUGIN_NAME}
  INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}"
)

set(SYSTEM_THEME_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/SystemTheme")
set(SYSTEM_THEME_DEPENDENCY "https://github.com/res2k/Windows10Colors/archive/master.zip")
set(SYSTEM_THEME_ARCHIVE "${CMAKE_CURRENT_SOURCE_DIR}/SystemTheme/Windows10Colors.zip")
set(SYSTEM_THEME_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/SystemTheme/Windows10Colors-master/Windows10Colors")
if (NOT EXISTS "${SYSTEM_THEME_ARCHIVE}")
  file(DOWNLOAD "${SYSTEM_THEME_DEPENDENCY}" "${SYSTEM_THEME_ARCHIVE}")
endif()
add_custom_target(EXTRACT ALL)
add_custom_command(
  TARGET EXTRACT PRE_BUILD
  COMMAND ${CMAKE_COMMAND} -E tar xzf \"${SYSTEM_THEME_ARCHIVE}\"
  WORKING_DIRECTORY "${SYSTEM_THEME_DIRECTORY}"
  DEPENDS "${SYSTEM_THEME_ARCHIVE}"
)

add_library(${PLUGIN_NAME} SHARED
  "fluent_ui_plugin.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(
  ${PLUGIN_NAME}
  PROPERTIES
  CXX_VISIBILITY_PRESET
  hidden
)
target_compile_definitions(
  ${PLUGIN_NAME}
  PRIVATE
  FLUTTER_PLUGIN_IMPL
)
target_include_directories(
  ${PLUGIN_NAME}
  INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${SYSTEM_THEME_SOURCE}"
)
target_link_libraries(
  ${PLUGIN_NAME}
  PRIVATE
  flutter
  flutter_wrapper_plugin
  "Advapi32.lib"
)

set(fluent_ui_bundled_libraries
  ""
  PARENT_SCOPE
)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4458 /wd4244 /wd4701")
