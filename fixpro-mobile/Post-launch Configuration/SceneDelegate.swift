import RIBs
import UIKit



/// Handles the view lifecycle of the app.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    
    /// The `UIWindow` of where this application is running on.
    var window: UIWindow?
    
    
    /// The ancestral RIB unit, where the rest of the RIBs will attach on.
    var rootRouter: LaunchRouting?
    
    
    /// Configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    /// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    /// 
    /// This delegate does not imply the connecting scene or session are new.
    /// Refer to `application:configurationForConnectingSceneSession` instead.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let wscene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: wscene)
        self.window = window
        
        let rootRouter = RootBuilder().build()
        FPRIBService_UIKitBridge.global.notificationResponder.setRootInteractor(rootRouter.interactable as! RootInteractable)
        
        self.rootRouter = rootRouter
        rootRouter.launch(from: window)
    }
    
}



extension SceneDelegate {
    
    
    /// Called as the scene is being released by the system.
    /// This occurs shortly after the scene enters the background, or when its session is discarded.
    /// 
    /// Release any resources associated with this scene that can be re-created the next time the scene connects.
    /// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    func sceneDidDisconnect(_ scene: UIScene) {}
    
    
    /// Called when the scene has moved from an inactive state to an active state.
    /// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    
    /// Called when the scene will move from an active state to an inactive state.
    /// This may occur due to temporary interruptions (ex. an incoming phone call).
    func sceneWillResignActive(_ scene: UIScene) {}
    
    
    /// Called as the scene transitions from the background to the foreground.
    /// Use this method to undo the changes made on entering the background.
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    
    /// Called as the scene transitions from the foreground to the background.
    /// Use this method to save data, release shared resources, and store enough scene-specific state information
    /// to restore the scene back to its current state.
    func sceneDidEnterBackground(_ scene: UIScene) {}
    
}
