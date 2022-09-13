//
//  AppDelegate.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/03/20.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import OAuthSwift
import FirebaseDynamicLinks


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//         Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        //URLの確認
        print("url : \(url.absoluteString)")
        print("url.scheme:\(url.scheme)")
        print("url.host:\(url.host)")
        print("url.path:\(url.path)")
        print("url.query:\(url.query)")
        
        applicationHandle(url: url)
        return true
    }
}

extension AppDelegate {

    func applicationHandle(url: URL) {
        if (url.host == "oauth-callback") {
            OAuthSwift.handle(url: url)
        } else {
            // Google provider is the only one wuth your.bundle.id url schema.
            OAuthSwift.handle(url: url)
        }
    }
}
