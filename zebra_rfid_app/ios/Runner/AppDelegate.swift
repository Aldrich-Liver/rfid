import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Con UISceneDelegate adoptado, self.window (y por lo tanto el
    // FlutterViewController) todavía no existe aquí: lo crea la Scene vía
    // storyboard. El registro de plugins se hace en SceneDelegate una vez
    // que ese window está disponible.
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func registerPlugins() {
    GeneratedPluginRegistrant.register(with: self)

    // Plugin RFID Zebra (custom, no auto-registrado por GeneratedPluginRegistrant)
    if let registrar = self.registrar(forPlugin: "ZebraRfidPlugin") {
      ZebraRfidPlugin.register(with: registrar)
    }
  }
}
