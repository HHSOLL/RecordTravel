import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private func hasGoogleMapsKey() -> Bool {
    guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String
    else {
      return false
    }
    return !apiKey.isEmpty && apiKey != "$(GOOGLE_MAPS_API_KEY)"
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String,
      hasGoogleMapsKey()
    {
      GMSServices.provideAPIKey(apiKey)
    } else {
      NSLog("record: GOOGLE_MAPS_API_KEY is missing. Google Maps tiles will not load.")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: "travel_atlas/runtime_capabilities",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "hasGoogleMapsKey":
        result(self?.hasGoogleMapsKey() ?? false)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
