//
//  LoginVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/30/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class AuthVC: UIViewController {
    //Outlets
    @IBOutlet weak var loginEmailTxt: PositageTextField!
    
    @IBOutlet weak var loginPswdTxt: PositageTextField!
    
    @IBOutlet var createAccountView: UIView!
    
    @IBOutlet weak var createAccountEmailTxt: PositageTextField!
    
    @IBOutlet weak var createAccountPswdTxt: PositageTextField!
    
    @IBOutlet weak var createAccountConfirmPswdTxt: PositageTextField!
    
    @IBOutlet weak var createAccountLbl: UILabel!
    
    @IBOutlet weak var createAccountBtn: PositageGeneralButton!
    
    @IBOutlet weak var loginView: PositageView!
    
    //Variables
    var loginViewIsShown: Bool = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
//        DataService.instance.signInUser(email: loginEmailTxt.text, password: loginPswdTxt.text, delegate: self)
        guard let email = loginEmailTxt.text,
           let password = loginPswdTxt.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint("Error signing in: \(error)")
            }
            else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "mainTabBarController")
                self.present(mainTabBarController, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func createAccountTapped(_ sender: Any) {
    
        if loginViewIsShown{
            self.createAccountView.frame = self.loginView.frame
            self.createAccountView.center = self.loginView.center
            self.createAccountView.alpha = 0
            self.view.addSubview(self.createAccountView)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.loginView.alpha = 0
                self.createAccountView.alpha = 1
                }) {(worked) in
            }
            
            createAccountBtn.setTitle("Login", for: .normal)
            createAccountLbl.text = "Have an account?"
            self.loginViewIsShown = false
        }
        else{
            self.loginView.alpha = 0

            UIView.animate(withDuration: 0.3, animations: {
                self.loginView.alpha = 1
                self.createAccountView.alpha = 0
            }) {(worked) in
            }
            createAccountBtn.setTitle("Create account", for: .normal)
            createAccountLbl.text = "Don't have an account?"
            self.loginViewIsShown = true
        }
    }
    
    @IBAction func createAccountNxtBtn(_ sender: Any) {
        if createAccountPswdTxt.text == createAccountConfirmPswdTxt.text{
            performSegue(withIdentifier: "createAccountSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "createAccountSegue" {
            let email = createAccountEmailTxt.text
            let password = createAccountPswdTxt.text
            
            let createAccountVC = segue.destination as? CreateAccountVC
            createAccountVC?.email = email!
            createAccountVC?.password = password!
        }
    }

}
