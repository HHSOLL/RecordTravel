import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private func bundleString(forKey key: String) -> String? {
    guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
      return nil
    }

    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, !trimmed.hasPrefix("$(") else {
      return nil
    }
    return trimmed
  }

  private func hasGoogleMapsKey() -> Bool {
    return bundleString(forKey: "GOOGLE_MAPS_API_KEY") != nil
  }

  private func naverMapClientId() -> String? {
    return bundleString(forKey: "NAVER_MAP_CLIENT_ID")
  }

  private func hasNaverMapClientId() -> Bool {
    return naverMapClientId() != nil
  }

  private func runtimeMapConfig() -> [String: Any] {
    [
      "hasGoogleMapsKey": hasGoogleMapsKey(),
      "hasNaverMapClientId": hasNaverMapClientId(),
      "naverMapClientId": naverMapClientId() as Any,
    ]
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let apiKey = bundleString(forKey: "GOOGLE_MAPS_API_KEY"), hasGoogleMapsKey() {
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
      case "getMapConfig":
        result(self?.runtimeMapConfig())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
