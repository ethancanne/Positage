//
//  JoinVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 4/3/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class JoinVC: UIViewController {

    //Outlets
    @IBOutlet weak var emailTxt: PositageTextField!
    @IBOutlet weak var usernameTxt: PositageTextField!
    
    @IBOutlet weak var passwordTxt: PositageTextField!
    @IBOutlet weak var confirmPasswordTxt: PositageTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func joinTapped(_ sender: Any) {
        if passwordTxt.text == confirmPasswordTxt.text{
            if let email = emailTxt.text, let password = passwordTxt.text, let username = usernameTxt.text{
                
                let user = User(username: username, userId: "", numStamps: 0, numSupportsRemaining: 10, numStampsToSend: 0, timestamp: Date())
                
                LoadingVC.showLoadingScreen(withMessage: "Creating User")
                Auth.auth().createUser(withEmail: email, password: password) { (resultUser, error) in
                    if let error = error{
                        if let error = (error as NSError?){
                            
                            let errCode = AuthErrorCode(rawValue: error.code)
                            switch errCode{
                            case .emailAlreadyInUse:
                                print("Email Used")
                                NotificationVC.showNotification(withMessage: "So SO sorry!  YOUR EMAIL IS ALREADY USED (YOU KNEW THAT)!", type: .error)
                                
                            default: break
                                
                            }
                            
                        }
                        
                    }else{
                        DataService.database.collection(USERS_REF).document((resultUser?.user.uid)!).setData(user.toDictionary())
                        self.dismiss(animated: true, completion: nil)
                    }
                    LoadingVC.dismissLoadingScreen()
                }
            }
            
        }else{
            //Passwords don't match
        }
    }
    

}
