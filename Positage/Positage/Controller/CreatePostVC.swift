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
    @IBOutlet weak var costLbl: UILabel!
    @IBOutlet weak var stampsGivenLbl: UILabel!
    @IBOutlet weak var addStampBtn: UIButton!
    @IBOutlet weak var removeStampBtn: UIButton!
    @IBOutlet weak var reviewBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postDataTxt.delegate = self
    }
    
    //Actions
    @IBAction func CancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = String()
        textView.textColor = UIColor.darkGray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ReviewSegue" && postNameTxt.text != nil && postDataTxt.text != nil{
            
            if postToCommunitySwitch.isOn {
                guard let postName = postNameTxt.text, let postData = postDataTxt.text else {return}
                Firestore.firestore().collection(POST_REF).addDocument(data: [
                    
                    POST_TITLE : postName,
                    POST_DATA : postData,
                    POST_NUM_STAMPS : 0,
                    POST_IS_COMMUNITY : true,
                    POST_TIMESTAMP : FieldValue.serverTimestamp(),
                    POST_FROM_USERID : "Username" //this user
                    
                ]){ (err) in
                    if let err = err {
                        debugPrint("Error adding document: \(err)")
                    }
                    else{
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }
            }
            else if !postToCommunitySwitch.isOn{
                let reviewVC = segue.destination as! ReviewPostVC
                reviewVC.postName = self.postNameTxt.text!
                reviewVC.postData = self.postDataTxt.text!
                reviewVC.cost = Int(costLbl.text!)!
            }
            
        }
        else {
            return
        }
        
        
    }


}
