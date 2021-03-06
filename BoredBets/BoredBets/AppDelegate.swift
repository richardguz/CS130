//
//  AppDelegate.swift
//  BoredBets
//
//  Created by Markus Notti on 10/23/16.
//  Copyright © 2016 SauceKitchen. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().barTintColor = UIColor.rgb(red: 35, green: 135, blue: 35)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        UITextField.appearance().tintColor = UIColor.rgb(red: 35, green: 135, blue: 35)
        UITextView.appearance().tintColor = UIColor.rgb(red: 35, green: 135, blue: 35)

        
        
        FIRApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        GMSServices.provideAPIKey("AIzaSyANWMeqlz41cyR6ju-BGDKfDOL0bjNb7zY")
        GMSPlacesClient.provideAPIKey("AIzaSyANWMeqlz41cyR6ju-BGDKfDOL0bjNb7zY")
        // Override point for customization after application launch.
    
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        let rootViewController = self.window!.rootViewController as! UINavigationController
        let view = rootViewController.visibleViewController?.view
        let overlay = BBUtilities.showOverlay(view: view!)
        
        if let error = error {
            BBUtilities.removeOverlay(overlay: overlay)
            print(error.localizedDescription)
            return
        }
        
        print("User signed into Google")
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                BBUtilities.removeOverlay(overlay: overlay)
                print(error.localizedDescription)
                return
            }
            
            UserDefaults.standard.set((user?.uid)!, forKey: "user_id")
            
            User.usersRef().child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild("username"){
                    let rootViewController = self.window!.rootViewController as! UINavigationController
                    rootViewController.visibleViewController?.performSegue(withIdentifier: "login", sender: nil)
                }
                else{
                    let rootViewController = self.window!.rootViewController as! UINavigationController
                    rootViewController.visibleViewController?.performSegue(withIdentifier: "createProfileSegue", sender: nil)
                }
                
            }) { (error) in
                BBUtilities.removeOverlay(overlay: overlay)
                print(error.localizedDescription)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
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
    }


}

