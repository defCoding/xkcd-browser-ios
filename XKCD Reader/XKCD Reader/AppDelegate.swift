//
//  AppDelegate.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/11/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Register settings bundle
        registerSettingsBundle()
        
        // If disk caching is disabled, then clear disk cache and disable it.
        if UserDefaults.standard.bool(forKey: "disableDiskCaching") {
            ComicsDataManager.sharedInstance.disableDiskCaching()
        } else {
            ComicsDataManager.sharedInstance.enableDiskCaching()
        }
        
        // Keep track of how often user has launched app.
        var launchCount = UserDefaults.standard.integer(forKey: "launchCount")
        launchCount += 1
        UserDefaults.standard.set(launchCount, forKey: "launchCount")
       
        // Save initial launch date
        if launchCount == 1 {
            UserDefaults.standard.set(NSDate.now, forKey:"Initial Launch")
        }
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
  
    // https://github.com/Abstract45/SettingsExample
    /// Registers the default values from the settings bundle.
    func registerSettingsBundle() {
        guard let settingsBundle = Bundle.main.url(forResource: "Settings", withExtension:"bundle") else {
            NSLog("%@", "ERROR -- could not find Settings.bundle")
            return;
        }
        
        guard let settings = NSDictionary(contentsOf: settingsBundle.appendingPathComponent("Root.plist")) else {
            NSLog("%@", "ERROR - could not find Root.plist in settings bundle")
            return
        }
        
        guard let preferences = settings.object(forKey: "PreferenceSpecifiers") as? [[String: AnyObject]] else {
            NSLog("%@", "ERROR - Root.plist has invalid format")
            return
        }
        
        var defaultsToRegister = [String: AnyObject]()
        for p in preferences {
            if let k = p["Key"] as? String, let v = p["DefaultValue"] {
                defaultsToRegister[k] = v
            }
        }
        
        UserDefaults.standard.register(defaults: defaultsToRegister)
    }
}

