#define NOMINMAX

#include <string>
#include <map>

#include <windows.h>
#include "include/fluent_ui/fluent_ui_plugin.h"
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <SystemTheme/Windows10Colors-master/Windows10Colors/Windows10Colors.cpp>


flutter::EncodableMap getRGBA(windows10colors::RGBA _color) {
    /* Converts windows10colors::RGBA to Flutter readable map of following structure.
     *
     * {
     *      'R': 0,
     *      'G': 120,
     *      'B': 215,
     *      'A': 1
     * }
     * 
     */
    using namespace windows10colors;
    flutter::EncodableMap color = flutter::EncodableMap();
    color[flutter::EncodableValue("R")] = flutter::EncodableValue(static_cast<int>(GetRValue(_color)));
    color[flutter::EncodableValue("G")] = flutter::EncodableValue(static_cast<int>(GetGValue(_color)));
    color[flutter::EncodableValue("B")] = flutter::EncodableValue(static_cast<int>(GetBValue(_color)));
    color[flutter::EncodableValue("A")] = flutter::EncodableValue(static_cast<int>(GetAValue(_color)));
    return color;
}


namespace {


    class FluentUiPlugin : public flutter::Plugin {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

        FluentUiPlugin();

        virtual ~FluentUiPlugin();

        private:
        void HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue> &method_call, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    };


    void FluentUiPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar) {
        auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(registrar->messenger(), "fluent_ui", &flutter::StandardMethodCodec::GetInstance());
        auto plugin = std::make_unique<FluentUiPlugin>();
        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto &call, auto result) {
                plugin_pointer->HandleMethodCall(call, std::move(result));
            }
        );
        registrar->AddPlugin(std::move(plugin));
    }

    FluentUiPlugin::FluentUiPlugin() {}

    FluentUiPlugin::~FluentUiPlugin() {}

    void FluentUiPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (method_call.method_name() == "SystemTheme.darkMode") {
            bool darkMode = false;
            windows10colors::GetDarkModeEnabled(darkMode);
            result->Success(flutter::EncodableValue(darkMode));
        }
        else if (method_call.method_name() == "SystemTheme.accentColor") {
            windows10colors::AccentColor accentColors;
            windows10colors::GetAccentColor(accentColors);
            flutter::EncodableMap colors = flutter::EncodableMap();
            colors[flutter::EncodableValue("accent")] = flutter::EncodableValue(
                getRGBA(accentColors.accent)
            );
            colors[flutter::EncodableValue("light")] = flutter::EncodableValue(
                getRGBA(accentColors.light)
            );
            colors[flutter::EncodableValue("lighter")] = flutter::EncodableValue(
                getRGBA(accentColors.lighter)
            );
            colors[flutter::EncodableValue("lightest")] = flutter::EncodableValue(
                getRGBA(accentColors.lightest)
            );
            colors[flutter::EncodableValue("dark")] = flutter::EncodableValue(
                getRGBA(accentColors.dark)
            );
            colors[flutter::EncodableValue("darker")] = flutter::EncodableValue(
                getRGBA(accentColors.darker)
            );
            colors[flutter::EncodableValue("darkest")] = flutter::EncodableValue(
                getRGBA(accentColors.darkest)
            );
            result->Success(flutter::EncodableValue(colors));
        }
        else {
            result->NotImplemented();
        }
    }

}


void FluentUiPluginRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
    FluentUiPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()->GetRegistrar<flutter::PluginRegistrarWindows>(registrar)
    );
}
