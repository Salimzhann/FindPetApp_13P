//
//  SceneDelegate.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 19.10.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
//        let token = UserDefaults.standard.string(forKey: LoginView.isActive)
        window?.rootViewController = UINavigationController(rootViewController: NavigationViewModel())
        
//        if let token = token, token.isEmpty == false {
//            window?.rootViewController = UINavigationController(rootViewController: NavigationViewModel())
//        } else {
//            window?.rootViewController = UINavigationController(rootViewController: SignInView())
//        }
        window?.makeKeyAndVisible()
    }
}

