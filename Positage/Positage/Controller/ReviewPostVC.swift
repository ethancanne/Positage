//
//  ReviewPostVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/20/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase
class ReviewPostVC: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    
    //Variables
    var postName: String = ""
    var postData: String = ""
    var postStampsGiven: Int = 0
    var postToUserId: String?
    
    var isCommunity: Bool = false
    
    var cost: Int = 0
    
    var users = [User]()
    
    let firestore = Firestore.firestore()
    var allUsers = [User]()
    
    //Outlets
    @IBOutlet weak var postDataTxt: PositageTextView!
    @IBOutlet weak var recipientsTxt: PositageTextField!
    @IBOutlet weak var postNameLbl: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var recipientsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postNameLbl.text = postName
        postDataTxt.text = postData
        recipientsTxt.delegate = self
        recipientsTxt.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        sendBtn.setTitle("(\(cost) Stamps) Send", for: .normal)
        recipientsTableView.delegate = self
        recipientsTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Firestore.firestore().collection(USERS_REF).getDocuments { (snapshot, error) in
            if let error = error{
                debugPrint("Error updating recipient tableView:\(error.localizedDescription)")
            }
            else {
                self.allUsers = User.setUser(from: snapshot)
                
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(){
        if recipientsTxt.text == ""{
            users = []
            recipientsTableView.reloadData()
        }
        else{
            self.updateRecipientTableView()
        }
    }
    
    
    func updateRecipientTableView() {
        self.users = allUsers.filter({$0.username.contains(self.recipientsTxt.text!) && $0.username != Auth.auth().currentUser?.displayName})
        self.recipientsTableView.reloadData()
    }
    
    
    
    
    @IBAction func SendPressed(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        guard let currentUserNumStamps = DataService.instance.currentUserNumStamps else { return }

        if currentUserNumStamps >= cost{
            if let toUserId = postToUserId {
                firestore.runTransaction({ (transaction, error) -> Any? in
                    
                    let toUserDocument: DocumentSnapshot
                    
                    do {
                        try toUserDocument = transaction.getDocument(self.firestore.collection(USERS_REF).document(toUserId))
                    }
                    catch let error as NSError {
                        debugPrint("Error reading User Document:\(error.localizedDescription)")
                        return nil
                    }
                    
                    guard let fromUserOldNumStamps = DataService.instance.currentUserNumStamps else { return nil }
                    guard let toUserOldNumStamps = toUserDocument.data()?[NUM_STAMPS] as? Int else { return nil }
                    
                    
                    transaction.updateData([NUM_STAMPS : fromUserOldNumStamps - self.cost], forDocument:
                        self.firestore.document("\(USERS_REF)/\(user.uid)"))
                    
                    
                    transaction.updateData([NUM_STAMPS : toUserOldNumStamps + self.postStampsGiven], forDocument: self.firestore.document("\(USERS_REF)/\(toUserId)"))
                    
                    
                    let postRef = self.firestore.collection(POST_REF).document()
                    
                    transaction.setData([
                        POST_TITLE : self.postName,
                        POST_DATA : self.postData,
                        NUM_STAMPS : self.postStampsGiven,
                        POST_IS_COMMUNITY : false,
                        POST_TIMESTAMP : FieldValue.serverTimestamp(),
                        POST_FROM_USERNAME : user.displayName!,
                        POST_FROM_USERID : user.uid,
                        POST_TO_USERID : toUserId
                        ]
                        , forDocument: postRef)
                    
                    
                    return nil
                    
                    
                }) { (object, error) in
                    if let error = error {
                        debugPrint("Error Creating Post:\(error.localizedDescription)")
                    }
                    else{
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        else{
            print("User has an insignificant number of stamps. \(cost - currentUserNumStamps) more stamp(s) is/are needed to send this post.")
            //Present alert
            
            let alertView = UIAlertController(title: "Insignificant number of stamps.", message: "\(cost - currentUserNumStamps) more stamp(s) is/are needed to send this post.", preferredStyle: .actionSheet)
            let action = UIAlertAction(title: "OK", style: .default)
            alertView.addAction(action)
            self.present(alertView, animated: true, completion: nil)
        }

//       if let recipients = recipientsTxt.text {
//            Firestore.firestore().collection(POST_REF).addDocument(data: [
//                POST_TITLE : postName,
//                POST_DATA : postData,
//                POST_NUM_STAMPS : postStampsGiven,
//                POST_IS_COMMUNITY : false,
//                POST_TIMESTAMP : FieldValue.serverTimestamp(),
//                POST_FROM_USERNAME : user.displayName!,
//                POST_FROM_USERID : user.uid,
//                POST_TO_USERID : recipients
//
//            ]){ (err) in
//                if let err = err {
//                    debugPrint("Error adding document: \(err)")
//                }
//                else{
//                    self.dismiss(animated: true, completion: nil)
//                }
//
//            }
//        }
    }
    
    
    
    
    //TableView Stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if users[indexPath.row].username == Auth.auth().currentUser?.displayName {
                cost = 0
                sendBtn.setTitle("(\(cost) Stamps) Send", for: .normal)
            }
            
            postToUserId = users[indexPath.row].userId
            cell.accessoryType = .checkmark
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            postToUserId = nil
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "recipientCell"){
            cell.textLabel?.text = users[indexPath.row].username
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
            cell.textLabel?.textColor = UIColor.darkGray
            return cell
        }
        else{
            return UITableViewCell()
        }
    }
}
