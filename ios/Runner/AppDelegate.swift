import UIKit
import Flutter
import GoogleMaps  // ✅ N'oublie pas cette ligne !

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    /// ✅ Fournit ta clé API Google Maps ici
    GMSServices.provideAPIKey("TON_API_KEY_ICI")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
