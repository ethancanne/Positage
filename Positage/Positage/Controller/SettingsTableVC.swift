//
//  SettingsTableVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 3/29/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class SettingsTableVC: UITableViewController {

    @IBOutlet weak var logOutTBItem: UITableViewCell!
    
    private var authHandle: AuthStateDidChangeListenerHandle!
    override func viewDidLoad() {
        super.viewDidLoad()
        logOutTBItem.isUserInteractionEnabled = true
        logOutTBItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logOut)))
        
    }
    
    
    
    @objc func logOut() {
        let firebaseAuth = Auth.auth()
        do{
            try firebaseAuth.signOut()
            authHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
                if let user = user {
                }
                else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
                    self.present(loginVC, animated: true, completion: nil)
                }
            })
        
        } catch let signOutError as NSError {
            debugPrint("Error signing out: \(signOutError)")
        }
        
    }

}
