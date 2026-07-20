import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    // El storyboard (UISceneStoryboardFile) ya instanció el FlutterViewController
    // en self.window. Lo compartimos con el AppDelegate para que
    // registrar(forPlugin:) pueda resolverlo, y recién entonces registramos plugins.
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
      let window = self.window
    else { return }

    appDelegate.window = window
    appDelegate.registerPlugins()
  }
}
