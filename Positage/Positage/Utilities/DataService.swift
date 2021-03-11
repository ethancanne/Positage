//
//  DataService.swift
//  Positage
//
//  Created by Ethan Cannelongo on 1/11/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

protocol UserListenerDelegate {
    func currentUserDataDidChange(user: User)
}

import Foundation
import Firebase

class DataService {
    static var currentUserNumStamps: Int = 0
    static var currentUser: User? = nil
    static let database: Firestore! = Firestore.firestore()
    static var userListenerDelegate: UserListenerDelegate?
    static var userListener: ListenerRegistration!

    
    static func signOut(){
        LoadingVC.showLoadingScreen()
        do{
            if DataService.currentUser != nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "signIn")
                loginVC.modalPresentationStyle = .overFullScreen

                getCurrentViewController()?.present(loginVC, animated: true){
                        LoadingVC.dismissLoadingScreen()
                        NotificationVC.showNotification(withMessage: "Successfully Signed Out", type: .inform)
                        DataService.userListener.remove() //IMPORTANT
                        DataService.currentUser = nil
                }
            }
            try Auth.auth().signOut()
        } catch let error as NSError {
            debugPrint("Error signing out: \(error.localizedDescription)")
        }
    }
    
    
    static func configureUserListener(){
        guard let user = Auth.auth().currentUser else {return}
        
        print(user.uid)
        
        let userRef = Firestore.firestore().collection(USERS_REF).document(user.uid)
        
        userListener = userRef.addSnapshotListener
            {(snapshot, error) in
                if let error = error {
                    debugPrint("Error receiving stamps from DataService:  \(error)")
                }
                else{
                    guard let data = snapshot?.data() else { return }
                    DataService.currentUserNumStamps = data[NUM_STAMPS] as? Int ?? 0
                    DataService.currentUser = User.set(from: snapshot)
                    AppLocation.updateMenu()
                    
                    if let userListenerDelegate = userListenerDelegate{
                        userListenerDelegate.currentUserDataDidChange(user: DataService.currentUser!)
                    }
                    
                    print(DataService.currentUserNumStamps)
                }
        }
    }
}

