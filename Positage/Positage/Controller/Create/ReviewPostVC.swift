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
    
    @IBOutlet weak var recipientsTableView: UITableView!
    @IBOutlet weak var dataTxtViewBtmCnstr: NSLayoutConstraint!
    @IBOutlet weak var seeMoreBtn: UIButton!
    
    //Confirm View Outlets
    @IBOutlet var confirmView: UIView!
    @IBOutlet weak var trackSwitch: UISwitch!
   
    
    //Pricing View Outlets
    @IBOutlet var pricingView: UIView!
    @IBOutlet weak var costBreakdownLbl: UILabel!
     @IBOutlet weak var totalCostLbl: UILabel!
    
    
    
    //PopUpVariables
    var backgroundView: UIView!
    
    
    //Variables
    var postName: String = ""
    var postData: String = ""
    var postStampsGiven: Int = 0
    var postToUserId: String?
    var seeMoreIsOpened: Bool = false
    var isCommunity: Bool = false
    
    var cost: Int = 0
    var sendSurcharge: Int = 0
    
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
        
        self.view.bindToKeyboard()
        
        
        //FOR POPUP
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        backgroundView.backgroundColor = #colorLiteral(red: 0.656727016, green: 0.6533910036, blue: 0.6593027115, alpha: 0.65703125)
        backgroundView.alpha = 0
        
        //END FOR POPUP
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPopUpView)))

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        postNameLbl.text = postName
        postDataTxt.text = postData
        totalCostLbl.text = String(cost)
        Firestore.firestore().collection(USERS_REF).getDocuments { (snapshot, error) in
            if let error = error{
                debugPrint("Error updating recipient tableView:\(error.localizedDescription)")
            }
            else {
                self.allUsers = User.set(from: snapshot)
                
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        dismissPopUpView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    func updateRecipientTableView() {
        self.users = allUsers.filter({$0.username.contains(self.recipientsTxt.text!) && $0.username != Auth.auth().currentUser?.displayName})
        self.recipientsTableView.reloadData()
    }
    
    
    
    //ACTIONS
    
    @IBAction func seeMoreBtnPressed(_ sender: Any) {
        if !seeMoreIsOpened {
            UIView.animate(withDuration: 1.1, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                self.dataTxtViewBtmCnstr.constant -= 200
                self.seeMoreBtn.transform = self.seeMoreBtn.transform.rotated(by: CGFloat((3 * Double.pi) / 2))
                self.view.layoutIfNeeded()
            }, completion: nil)
            seeMoreIsOpened = true
        }
        else{
            UIView.animate(withDuration: 1.1, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                self.dataTxtViewBtmCnstr.constant += 200
                self.seeMoreBtn.transform = self.seeMoreBtn.transform.rotated(by: CGFloat(Double.pi / 2))
                self.view.layoutIfNeeded()
            }, completion: nil)
            seeMoreIsOpened = false
        }
 
    }
    
    
    @IBAction func nextPressed(_ sender: Any) {

        updateCostLbl()
        
        guard let window = UIApplication.shared.keyWindow else {return}
        
        window.addSubview(backgroundView)
        
        //Create confirm View
        self.confirmView.frame = CGRect(x: 0, y:  window.frame.height, width: window.frame.width, height: 300)
        window.addSubview(self.confirmView)
        
        //Create the pricing Popup
        pricingView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 147)
        pricingView.center.x = view.center.x
        window.addSubview(pricingView)
        
        //Animate them all into view
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
            self.backgroundView.alpha = 1
            self.pricingView.frame.origin.y -= (window.frame.height / 2)
            self.confirmView.frame.origin.y -= self.confirmView.frame.height

        }, completion: nil)
        
    }
    
    //ConfirmView Actions
    @IBAction func confirmPressed(_ sender: Any){
        guard let user = Auth.auth().currentUser else { return }
        let currentUserNumStamps = DataService.currentUserNumStamps
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
                        
                        let fromUserOldNumStamps = DataService.currentUserNumStamps
                        guard let toUserOldNumStamps = toUserDocument.data()?[NUM_STAMPS] as? Int else { return nil }
                        
                        guard let toUsername = toUserDocument.data()?[USER_USERNAME] as? String else { return nil }
                        
                        transaction.updateData([NUM_STAMPS : fromUserOldNumStamps - self.cost], forDocument:
                            self.firestore.document("\(USERS_REF)/\(user.uid)"))
                        
                        
                        transaction.updateData([NUM_STAMPS : toUserOldNumStamps + self.postStampsGiven], forDocument: self.firestore.document("\(USERS_REF)/\(toUserId)"))
                        
                        
                        let postRef = self.firestore.collection(POST_REF).document()
                        
                        transaction.setData([
                            TITLE : self.postName,
                            MESSAGE : self.postData,
                            NUM_STAMPS : self.postStampsGiven,
                            TIMESTAMP : FieldValue.serverTimestamp(),
                            FROM_USERNAME : user.displayName!,
                            FROM_USERID : user.uid,
                            TO_USERID : toUserId,
                            TO_USERNAME : toUsername,
                            DID_READ: false
                            ]
                            , forDocument: postRef)
                        
                        
                        return nil
                        
                        
                    }) { (object, error) in
                        if let error = error {
                            debugPrint("Error Creating Post:\(error.localizedDescription)")
                        }
                        else{
                            self.dismiss(animated: true, completion: nil)
                            self.pricingView.removeFromSuperview()
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
    
    @IBAction func giveStampBtnTapped(_ sender: Any) {
        postStampsGiven += 1
        cost += 1
        updateCostLbl()
    }
    
    
    @IBAction func removeStampBtnTapped(_ sender: Any) {
        if postStampsGiven != 0 {
            postStampsGiven -= 1
            cost -= 1
            updateCostLbl()
        }
    }
 
    //SELECTORS
    
    @objc func dismissPopUpView(){
        guard let window = UIApplication.shared.keyWindow else {return}
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                self.confirmView.frame.origin.y += self.confirmView.frame.height
                self.pricingView.frame.origin.y = window.frame.height
                self.backgroundView.alpha = 0
            }, completion: { (worked) in
                self.confirmView.removeFromSuperview()
                self.pricingView.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
            })

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
    
    
    @objc func textFieldDidChange(){
        if recipientsTxt.text == ""{
            users = []
            recipientsTableView.reloadData()
        }
        else{
            self.updateRecipientTableView()
        }
    }
    
    //END SELECTORS
    
    //GENERAL FUNCTIONS
    func updateCostLbl(){
 
        costBreakdownLbl.text = "Send Surcharge: \(cost)\n"
        if trackSwitch.isOn == true {
            costBreakdownLbl.text?.append("Post Tracked: 5\n")
        }
        
        if postStampsGiven > 0 {
            costBreakdownLbl.text?.append("Stamps Given: \(postStampsGiven)\n")
        }
        
        
        totalCostLbl.text = String(cost)
        
    }
    //END GENERAL FUNCTIONS
    
    
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
