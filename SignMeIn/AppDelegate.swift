//
//  AppDelegate.swift
//  SignMeIn
//
//  Created by ChenMo on 2/26/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

// TODO: finish the functionality of checking if username
// already exits before entering the name input page

// *************************
// To launch parse dashboard:
// parse-dashboard --appId myAppId --masterKey myMasterKey --serverURL "https://check-me-in-007.herokuapp.com/parse"
// *************************

// TODO:
// 1. Change the TVC to a VC and show the instructor
//      1.1 Class info and check in code
//      1.2 The option to change check in code
//      1.2 The option to change class info (Optional)
// 2. Add VC to the second tab for users to change their first and last name
// 3. Move logout button to the second tab bar
// 4. Add a few more alerts to check in page to propt the user what's wrong
// 4. Add VC to third tab for users to check all signed in classes (Optional)

import UIKit
import CoreData
import Parse
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Initializing Heroku Parse server
        Parse.initialize(
            with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) -> Void in
                configuration.applicationId = "myAppId"
                configuration.server = "https://check-me-in-007.herokuapp.com/parse"
            })
        )
        
        // Skip login flow if user is logged in
        let currentUser = PFUser.current()
        if currentUser != nil {
            // userGroup refers to the user status
            // Either Student or Instructor
            // It will take the user to the storyboard they belong
            let userGroup = currentUser!["status"] as! String
            print(userGroup)
            if userGroup == "Student" {
                let studentHome = UIStoryboard(name: "StudentHome", bundle: nil)
                let studentHomeTabBarController = studentHome.instantiateViewController(withIdentifier: "StudentHomeTabBarController")
                window?.rootViewController = studentHomeTabBarController
            } else {
                let instructorHome = UIStoryboard(name: "InstructorHome", bundle: nil)
                let instructorHomeTabBarController = instructorHome.instantiateViewController(withIdentifier: "InstructorHomeTabBarController")
                window?.rootViewController = instructorHomeTabBarController
            }
            
        }
        return true
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // This is for activating the connection with Heroku to avoid
        // lag when interacting with main thread
        print(Alamofire.request("https://check-me-in-007.herokuapp.com/"))
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SignMeIn")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

