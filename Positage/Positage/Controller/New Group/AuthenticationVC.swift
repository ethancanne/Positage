//
//  LoginVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/30/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class AuthenticationVC: UIViewController, UITextFieldDelegate {
    //Outlets
    @IBOutlet weak var emailTxt: PositageTextField!
    
    @IBOutlet weak var passwordTxt: PositageTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTxt.delegate = self
        passwordTxt.delegate = self
        
        //Google auth
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("workied")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            didAuthenticate()
        }
    }
    
    func didAuthenticate(){
        DataService.configureUserListener()
        performSegue(withIdentifier: "toInbox", sender: self)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        if let email = emailTxt.text, let password = passwordTxt.text{
            if email != "" && password != ""{
                LoadingVC.showLoadingScreen(withMessage: "Trying to Log in.")
                Auth.auth().signIn(withEmail: email, password: password){ (user, error) in
                    if let error = (error as NSError?){
                        
                        let errCode = AuthErrorCode(rawValue: error.code)
                        switch errCode{
                        case .invalidEmail:
                                print("invaild EMAIL")
                                NotificationVC.showNotification(withMessage: "YOUR EMAIL IS BADDD!", type: .error)
                            
                        default: break
                            
                        }

                    }else{
                        self.didAuthenticate()
                    }
                    
                    LoadingVC.dismissLoadingScreen()
                }
            }else{
                //Password and/or emails field is/are empty
                emailTxt.shadowColor = (email != "") ? #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1) : #colorLiteral(red: 0.6078431373, green: 0.6745098039, blue: 0.7450980392, alpha: 1)
                emailTxt.CustomizeView()
                emailTxt.text = ""
                
                passwordTxt.shadowColor = (password != "") ? #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1) : #colorLiteral(red: 0.6078431373, green: 0.6745098039, blue: 0.7450980392, alpha: 1)
                passwordTxt.CustomizeView()
                passwordTxt.text = ""

                
                
                //Show popup
                

            }
        }else{
        }
        
    }
    
    @IBAction func joinTapped(_ sender: Any) {
        performSegue(withIdentifier: "toJoin", sender: self)
    }
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        emailTxt.shadowColor = #colorLiteral(red: 0.6078431373, green: 0.6745098039, blue: 0.7450980392, alpha: 1)
        emailTxt.CustomizeView()
        
        passwordTxt.shadowColor = #colorLiteral(red: 0.6078431373, green: 0.6745098039, blue: 0.7450980392, alpha: 1)
        passwordTxt.CustomizeView()
    }
    


}
