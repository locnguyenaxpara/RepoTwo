//
//  AppDelegate.swift
//  SimpleApp
//
//  Created by loc on 05/07/2023.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
        
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        return true
    }

}

