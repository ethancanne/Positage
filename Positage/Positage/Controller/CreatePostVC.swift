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
    
    var stampsGiven: Int = 0
    var surcharge: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postDataTxt.delegate = self
        postToCommunitySwitch.addTarget(self, action: #selector(communitySwitchDidChange), for: .valueChanged)
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
            totalCostLbl.text = String(stampsGiven + surcharge)
        }
    }
    
    @IBAction func reviewBtnTapped(_ sender: Any) {
        if postToCommunitySwitch.isOn {
            guard let postName = postNameTxt.text, let postData = postDataTxt.text else {return}
            Firestore.firestore().collection(POST_REF).addDocument(data: [
                
                POST_TITLE : postName,
                POST_DATA : postData,
                NUM_STAMPS : 0,
                POST_IS_COMMUNITY : true,
                POST_TIMESTAMP : FieldValue.serverTimestamp(),
                POST_FROM_USERNAME : Auth.auth().currentUser?.displayName ?? "anonomys", //this user
                POST_FROM_USERID : Auth.auth().currentUser?.uid ?? ""
                
            ]){ (err) in
                if let err = err {
                    debugPrint("Error adding document: \(err)")
                }
                else{
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        }
        else {
            performSegue(withIdentifier: "ToReviewSegue", sender: self)
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
                surcharge = 2
            }
            else{
                surcharge = 3
            }
            
        }
        else {
            surcharge = 1
        }
        totalCostLbl.text = String(stampsGiven + surcharge)
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
