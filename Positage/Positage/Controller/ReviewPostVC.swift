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
    
   
    //Outlets
    @IBOutlet weak var postDataTxt: PositageTextView!
    @IBOutlet weak var recipientsTxt: PositageTextField!
    @IBOutlet weak var postNameLbl: UILabel!
    @IBOutlet weak var numStampsGivenLbl: UILabel!
    @IBOutlet weak var recipientsTableView: UITableView!
    
    //Confirm View Outlets
    @IBOutlet var confirmView: UIView!
    @IBOutlet weak var trackSwitch: UISwitch!
    @IBOutlet weak var promoteSwitch: UISwitch!
    @IBOutlet weak var totalCostLbl: UILabel!
    
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipientsTxt.delegate = self
        recipientsTxt.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        recipientsTableView.delegate = self
        recipientsTableView.dataSource = self
        trackSwitch.addTarget(self, action: #selector(trackSwitchDidChange), for: .valueChanged)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        postNameLbl.text = postName
        postDataTxt.text = postData
        numStampsGivenLbl.text = "Stamps Given: \(String(postStampsGiven))"
//        sendBtn.setTitle("(\(cost) Stamps) Send", for: .normal)

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
    
    @objc func trackSwitchDidChange (trackSwitch: UISwitch) {
        if trackSwitch.isOn {
            cost += 5
        }
        else{
            cost -= 5
        }
        updateCostLbl()
    }
    
    @objc func promoteSwitchDidChange (trackSwitch: UISwitch) {
        if promoteSwitch.isOn {
            cost += 7
        }
        else{
            cost -= 7
        }
        updateCostLbl()
    }
    
    func updateCostLbl(){
        totalCostLbl.text = String(cost)
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
    
    
    
    
    @IBAction func nextPressed(_ sender: Any) {
        //Show confirm View
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        backgroundView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3002387153)
        backgroundView.alpha = 0
        view.addSubview(backgroundView)
        confirmView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 300)
        view.addSubview(confirmView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
            backgroundView.alpha = 1
            self.confirmView.frame.origin.y -= self.confirmView.frame.height

        }, completion: nil)
        
    }
    
    //ConfirmView Actions
    @IBAction func confirmPressed(_ sender: Any){
        guard let user = Auth.auth().currentUser else { return }
        guard let currentUserNumStamps = DataService.instance.currentUserNumStamps else { return }
        let isTrackOn = trackSwitch.isOn
        if postToUserId != nil {
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
                        
                        guard let toUsername = toUserDocument.data()?[USER_USERNAME] as? String else { return nil }
                        
                        transaction.updateData([NUM_STAMPS : fromUserOldNumStamps - self.cost], forDocument:
                            self.firestore.document("\(USERS_REF)/\(user.uid)"))
                        
                        
                        transaction.updateData([NUM_STAMPS : toUserOldNumStamps + self.postStampsGiven], forDocument: self.firestore.document("\(USERS_REF)/\(toUserId)"))
                        
                        
                        let postRef = self.firestore.collection(POST_REF).document()
                        
                        transaction.setData([
                            TITLE : self.postName,
                            DATA : self.postData,
                            NUM_STAMPS : self.postStampsGiven,
                            POST_IS_COMMUNITY : false,
                            POST_ALLOWS_TRACKING: isTrackOn,
                            TIMESTAMP : FieldValue.serverTimestamp(),
                            FROM_USERNAME : user.displayName!,
                            FROM_USERID : user.uid,
                            TO_USERID : toUserId,
                            TO_USERNAME : toUsername,
                            NUM_REPLIES : 0,
                            DID_VIEW: false
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
        }
        else{
            print("User needs to enter intended recipient for post.")
            //Present alert
            let alertView = UIAlertController(title: "No intended recipient for this post.", message: "To send the post: \(postName), you need to provide the intended recipient.", preferredStyle: .actionSheet)
            let action = UIAlertAction(title: "OK", style: .default)
            alertView.addAction(action)
            self.present(alertView, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func dismissConfirmView(_ sender: Any) {
        
    }
    
    //TableView Stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if users[indexPath.row].username == Auth.auth().currentUser?.displayName {
                cost = 0
//                sendBtn.setTitle("(\(cost) Stamps) Send", for: .normal)
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
