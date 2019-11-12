//
//  CreatePostVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/19/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase
class CreatePostVC: UIViewController, UITextViewDelegate{
    
    //Outlets
    @IBOutlet weak var postToCommunitySwitch: UISwitch!
    @IBOutlet weak var postNameTxt: UITextField!
    @IBOutlet weak var postDataTxt: UITextView!
    @IBOutlet weak var totalCostLbl: UILabel!
    @IBOutlet weak var stampsGivenLbl: UILabel!
    @IBOutlet weak var reviewBtn: UIButton!
    @IBOutlet weak var costView: UIView!
    
    //Confirm View
    @IBOutlet var confirmView: UIView!
    @IBOutlet weak var totalCostConfirmLbl: UILabel!
    @IBOutlet weak var promotedSwitch: UISwitch!
    
    var stampsGiven: Int = 0
    var cost: Int = 0
    let firestore = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postDataTxt.delegate = self
        postToCommunitySwitch.addTarget(self, action: #selector(communitySwitchDidChange), for: .valueChanged)
        self.title = ""
        reviewBtn.bindToKeyboard()
        
        promotedSwitch.addTarget(self, action: #selector(promoteSwitchDidChange), for: .valueChanged)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //Actions
    @IBAction func CancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func giveStampBtnTapped(_ sender: Any) {
        if let cost = totalCostLbl.text {
            stampsGiven += 1
            stampsGivenLbl.text = String(stampsGiven)
            totalCostLbl.text = String(Int(cost)! + 1)
        }
        else {
            print("Error giving stamps")
        }
    }
    
    
    @IBAction func removeStampBtnTapped(_ sender: Any) {
        if stampsGiven != 0 {
            stampsGiven -= 1
            stampsGivenLbl.text = String(stampsGiven)
            totalCostLbl.text = String(stampsGiven + cost)
        }
    }
    
    @IBAction func reviewBtnTapped(_ sender: Any) {
        if postToCommunitySwitch.isOn {
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
        else {
            performSegue(withIdentifier: "ToReviewSegue", sender: self)
        }
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        
        guard let user = Auth.auth().currentUser else { return }
        guard let currentUserNumStamps = DataService.instance.currentUserNumStamps else { return }
        let isPromoted = promotedSwitch.isOn
        if currentUserNumStamps >= cost{
            
            guard let fromUserOldNumStamps = DataService.instance.currentUserNumStamps else { return }
            firestore.document("\(USERS_REF)/\(user.uid)").updateData([NUM_STAMPS : fromUserOldNumStamps - self.cost])
            
            guard let postName = postNameTxt.text, let postData = postDataTxt.text else {return}
            Firestore.firestore().collection(POST_REF).addDocument(data: [
                TITLE : postName,
                DATA : postData,
                NUM_STAMPS : 0,
                POST_IS_COMMUNITY : true,
                POST_IS_PROMOTED : isPromoted,
                TIMESTAMP : FieldValue.serverTimestamp(),
                FROM_USERNAME : Auth.auth().currentUser?.displayName ?? "anonomys", //this user
                FROM_USERID : Auth.auth().currentUser?.uid ?? ""
                
            ]){ (err) in
                if let err = err {
                    debugPrint("Error adding document: \(err)")
                }
                else{
                    self.dismiss(animated: true, completion: nil)
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
    
    //Delegates
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = String()
        textView.textColor = UIColor.darkGray
    }
    
    func textViewDidChange(_ textView: UITextView) {
        postDataTxt.layoutIfNeeded()
        var wordsInTxtData = [String]()
        wordsInTxtData = postDataTxt.text.components(separatedBy: " ")
        
        if wordsInTxtData.count >= 50{
            if wordsInTxtData.count <= 100 {
                cost = 2
            }
            else{
                cost = 3
            }
            
        }
        else {
            cost = 1
        }
        totalCostLbl.text = String(stampsGiven + cost)
    }
    
    @objc func communitySwitchDidChange(communitySwitch: UISwitch){
        if communitySwitch.isOn {
            UIView.animate(withDuration: 0.4, animations: { () in
                self.costView.alpha = 0
            }) { (worked) in
                self.reviewBtn.setTitle("Post", for: .normal)
                
            }
        }
        else{
            UIView.animate(withDuration: 0.4, animations: { () in
                self.costView.alpha = 1
            }) { (worked) in
                self.reviewBtn.setTitle("Review", for: .normal)
            }
        }
    }
    
    @objc func promoteSwitchDidChange() {
        if promotedSwitch.isOn {
            cost += 7
        }
        else{
            cost -= 7
        }
        updateCostLbl()
    }
    
    
    func updateCostLbl(){
        totalCostConfirmLbl.text = String(cost)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToReviewSegue" && postNameTxt.text != nil && postDataTxt.text != nil{
            
            if !postToCommunitySwitch.isOn{
                let reviewVC = segue.destination as! ReviewPostVC
                
                if let postName = postNameTxt.text,
                    let postData = postDataTxt.text,
                    let totalCost = totalCostLbl.text {
                    reviewVC.postName = postName
                    reviewVC.postData = postData
                    reviewVC.postStampsGiven = stampsGiven
                    reviewVC.cost = Int(totalCost) ?? 0
                }
                else {
                    print("Error creating post: nil value")
                }
            }
            
        }
        else {
            return
        }
        
        
    }
    
    
}

