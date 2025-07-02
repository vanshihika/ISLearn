//
//  SceneDelegate.swift
//  islearn
//
//  Created by student-2 on 06/12/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
//        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
//        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        guard let _ = (scene as? UIWindowScene) else { return }
//        
//        window?.overrideUserInterfaceStyle = .dark
//        
//        
//    }

//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//
//        window = UIWindow(windowScene: windowScene)
//        window?.overrideUserInterfaceStyle = .dark
//        
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//        // Since this is an async function, we must use `Task` to handle it
//        Task {
//            do {
//                // Attempt to restore session asynchronously
//                try await SupabaseManager.shared.restoreSession()
//
//                // Now check if session exists and if user is valid
//                // Check if the session is valid and the user is available
//                if SupabaseManager.shared.auth.session.user != nil {
//                    // Session exists and user is valid, show the main screen
//                    let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
//                    window?.rootViewController = tabBarVC
//                } else {
//                    // No valid session, show the login screen
//                    let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
//                    window?.rootViewController = loginVC
//                }
//            } catch {
//                // If session restoration fails, show the login screen
//                print("Failed to restore session: \(error)")
//                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
//                window?.rootViewController = loginVC
//            }
//
//            window?.makeKeyAndVisible()
//        }
//    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.overrideUserInterfaceStyle = .dark

        // Show Splash screen
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()

        // Load Main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        Task {
            // 1. Delay to allow splash to show for a while (e.g., 2.5 seconds)
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            do {
                // 2. Try restoring session
                try await SupabaseManager.shared.restoreSession()

                let rootVC: UIViewController

                if SupabaseManager.shared.auth.session.user != nil {
                    // User session is valid
                    rootVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                } else {
                    // No session or invalid user
                    rootVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                }

                // 3. Switch root view controller
                await MainActor.run {
                    window.rootViewController = rootVC
                }

            } catch {
                print("Failed to restore session: \(error)")
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController

                await MainActor.run {
                    window.rootViewController = loginVC
                }
            }
        }
    }

    
    

    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

