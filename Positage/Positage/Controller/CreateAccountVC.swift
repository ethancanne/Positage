//
//  CreateAccountVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 1/2/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountVC: UIViewController {
    //Outlets
    @IBOutlet weak var usernameTxt: PositageTextField!
    
    @IBOutlet weak var emailLbl: UILabel!
    
    @IBOutlet weak var passwordTxtLbl: UITextField!
    @IBOutlet weak var showPswdBtn: UIButton!
    
    @IBOutlet weak var editBtn: PositageButton!
    
    @IBOutlet weak var startBtn: PositageButton!
    
    //Variables
    var email: String = ""
    var password: String = ""
    var pswdHidden: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        emailLbl.text = email
        passwordTxtLbl.text = password
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    @IBAction func showPswdTapped(_ sender: Any) {
        if pswdHidden{
            showPswdBtn.setTitle("Hide", for: .normal)
            passwordTxtLbl.isSecureTextEntry = false
            pswdHidden = false
        }
        else{
            showPswdBtn.setTitle("Show", for: .normal)
            passwordTxtLbl.isSecureTextEntry = true
            pswdHidden = true
        }
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startTapped(_ sender: Any) {
        guard let username = usernameTxt.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (user, err) in
            if let err = err {
                debugPrint("Error creating user \(err)")
            }
            let changeRequest = user?.user.createProfileChangeRequest()
            changeRequest?.displayName = self.usernameTxt.text

            changeRequest?.commitChanges(completion: { (err) in
                if let err = err {
                    debugPrint("Error creating user \(err)")
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "mainTabBarController")
                self.present(mainTabBarController, animated: true, completion: nil)
            })

            guard let userId = user?.user.uid else { return }
            Firestore.firestore().collection(USERS_REF).document(userId).setData([
                USER_USERNAME : username,
                NUM_STAMPS : 0,
                TIMESTAMP : FieldValue.serverTimestamp()
                ], completion: { (err) in
                    if let err = err {
                        debugPrint("Error creating user \(err)")
                    }
            })
        }
    }
    
    
    
    func onSignUpAttempt(didSucceed: Bool) {
        if didSucceed {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "mainTabBarController")
            self.present(mainTabBarController, animated: true, completion: nil)
        }
    }

    
    
    
}
