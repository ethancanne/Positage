//
//  SettingsTableVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 3/29/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class SettingsView: UIView {
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        DataService.signOut()
    }
    
    
}
