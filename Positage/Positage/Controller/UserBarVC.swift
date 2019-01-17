//
//  UserBarVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 1/6/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class UserBarVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var stampsLbl: UILabel!
    
    //Variables
    var userListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ConfigureListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if userListener != nil {
            userListener.remove()
        }
    }
    
    func ConfigureListener(){
        guard let user = Auth.auth().currentUser else { return }
        let userRef = Firestore.firestore().collection(USERS_REF).document(user.uid)
        
        userListener = userRef.addSnapshotListener
            {(snapshot, error) in
                if let error = error {
                    debugPrint("Error loading UserBarVC due to error: \(error)")
                }
                else{
                    guard let data = snapshot?.data() else { return }
                    self.stampsLbl.text = String(data[NUM_STAMPS] as! Int) + " stamps"
                    self.usernameLbl.text = user.displayName
                    
                    DataService.instance.currentUserNumStamps = data[NUM_STAMPS] as? Int
                }
        }
    }
    
}
