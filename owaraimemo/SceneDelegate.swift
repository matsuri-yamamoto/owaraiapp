//
//  SceneDelegate.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/03/20.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // ログイン判定
        //        if Auth.auth().currentUser?.uid != nil {
        
        // ログインしている場合
        let window = UIWindow(windowScene: scene as! UIWindowScene)
        self.window = window
        window.makeKeyAndVisible()
        
        // Main.storyboardを指定
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        // storyboardのidentifierで名付けたVCをインスタンス化
//        let tabbarVC = storyBoard.instantiateViewController(identifier: "Tabbar")
//        // 上記をrootのコントローラとしてインスタンス化
//        let navVC = UINavigationController(rootViewController: tabbarVC)
//
//        window.rootViewController = navVC
        
        let onboardVC = storyBoard.instantiateViewController(identifier: "OnboardPage")
        // 上記をrootのコントローラとしてインスタンス化
        let navVC = UINavigationController(rootViewController: onboardVC)

        window.rootViewController = navVC

        
        //        } else {
        //
        //            // ログインしてない場合
        //            let window = UIWindow(windowScene: scene as! UIWindowScene)
        //            self.window = window
        //            window.makeKeyAndVisible()
        //
        //            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        //            let startVC = storyBoard.instantiateViewController(identifier: "Start")
        //            let navVC = UINavigationController(rootViewController: startVC)
        //            window.rootViewController = navVC
        //        }
        
        // ナビゲージョンアイテムの文字色
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 0.2442787347, green: 0.2442787347, blue: 0.2442787347, alpha: 1)

        UINavigationBar.appearance().titleTextAttributes =
            // ナビゲーションバーのタイトルの文字色
            [.foregroundColor: #colorLiteral(red: 0.3338265567, green: 0.3338265567, blue: 0.3338265567, alpha: 1),
             // フォントの種類
             .font: UIFont.boldSystemFont(ofSize: 16)]

        // ナビゲーションバーの背景色
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.white
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance


        
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
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
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        
    }
 
    
    
}

