import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var coordinator: AppCoordinator?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }
        let w = UIWindow(windowScene: ws)
        w.overrideUserInterfaceStyle = .dark
        let c = AppCoordinator(window: w)
        self.coordinator = c
        self.window = w
        c.start()
        w.makeKeyAndVisible()
    }
}
