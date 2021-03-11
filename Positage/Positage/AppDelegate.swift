//
//  AppDelegate.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/19/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//
import UIKit
import Firebase
import GoogleSignIn

struct AppLocation {
    static var currentMenuVC: MenuVC!
    static var currentTabBarVC: UITabBarController!
    static var currentUserLocation: String? = nil {
        didSet {
            updateMenu()
        }
    }
    
    static var locationHidden: Bool = false {
        didSet {
            updateMenu()
        }
    }
    
    static func updateMenu() {
        //        if let window = UIApplication.shared.keyWindow {
        //            for view in window.subviews{
        //                if view.restorationIdentifier == "menu"{
        //                    view.didMoveToSuperview()
        //                }
        //            }
        //        }
        if currentMenuVC != nil{
            currentMenuVC.updateMenu()
        }
    }
    
    static func toggleSubmenu(){
        //        if let window = UIApplication.shared.keyWindow {
        //            for view in window.subviews{
        //                if view.restorationIdentifier == "menu"{
        //                    (view as? MenuView)?.toggleSubmenu(withView: nil)
        //                }
        //            }
        //        }
        if currentMenuVC != nil{
            currentMenuVC.toggleSubmenu()
        }
    }
    
    static func toggleBackBtn(){
        //        if let window = UIApplication.shared.keyWindow {
        //            for view in window.subviews{
        //                if view.restorationIdentifier == "menu"{
        //                    (view as? MenuView)?.toggleBackBtn()
        //                }
        //            }
        //        }
        if currentMenuVC != nil{
            currentMenuVC.toggleBackBtn()
        }
    }
    
    static func isTabViewVisible() -> Bool{
        if AppLocation.currentUserLocation == INBOX || AppLocation.currentUserLocation == COMMUNITY || AppLocation.currentUserLocation == OUTBOX{
            return true
        }else{
            return false
        }
    }
    
}

func instantiateViewController(fromStoryboard storyboard: String, withIdentifier id: String) -> UIViewController {
    guard let window = UIApplication.shared.keyWindow else { return UIViewController() }
    let storyboard = UIStoryboard(name: storyboard, bundle: nil)
    let VC = storyboard.instantiateViewController(withIdentifier: id)
    return VC
}

func getCurrentViewController() -> UIViewController? {
    if let rootController = UIApplication.shared.keyWindow?.rootViewController {
        var currentController: UIViewController! = rootController
        while( currentController.presentedViewController != nil ) {
            currentController = currentController.presentedViewController
        }
        return currentController
    }
    return nil
}





@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    
    
    var window: UIWindow?
    private var authHandle: AuthStateDidChangeListenerHandle!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Firebase and Google auth
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        
        // Override point for customization after application launch.
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url)
    }
    
    //After user returns from google sign in screen after sucessfully signing in:
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if getCurrentViewController() != nil {
            LoadingVC.showLoadingScreen()
        }
        if let error = error {
            // ...
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error signing in with Google")
            } else{
                
                let user = User(username: (authResult?.user.email?.components(separatedBy: CharacterSet(charactersIn: "@")).first)!, userId: "", numStamps: 0, numSupportsRemaining: 10, numStampsToSend: 0, timestamp: Date())
                DataService.database.collection(USERS_REF).document(((authResult?.user.uid)!)).setData(user.toDictionary(), mergeFields: [USERNAME])
                
                getCurrentViewController()!.performSegue(withIdentifier: "toInbox", sender: getCurrentViewController())
                DataService.configureUserListener()
                LoadingVC.dismissLoadingScreen()
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
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

