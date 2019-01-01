//
//  ReviewPostVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/20/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase
class ReviewPostVC: UIViewController, UITextFieldDelegate {

    
    //Variables
    var postName: String = ""
    var postData: String = ""
    var isCommunity: Bool = false
    
    var cost: Int = 0
    
    
    //Outlets
    @IBOutlet weak var postDataTxt: PositageTextView!
    @IBOutlet weak var recipientsTxt: PositageTextField!
    @IBOutlet weak var postNameLbl: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postNameLbl.text = postName
        postDataTxt.text = postData
        recipientsTxt.delegate = self
        sendBtn.setTitle("(\(cost) Stamps) Send", for: .normal)
        // Do any additional setup after loading the view.
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Show recipients in the table
    }
    
    @IBAction func SendPressed(_ sender: Any) {
        
        if let recipients = recipientsTxt.text {
            Firestore.firestore().collection(POST_REF).addDocument(data: [
                POST_TITLE : postName,
                POST_DATA : postData,
                POST_NUM_STAMPS : 0,
                POST_IS_COMMUNITY : false,
                POST_TIMESTAMP : FieldValue.serverTimestamp(),
                POST_FROM_USERID : "nil",
                POST_TO_USERID : recipients
                
                ]){ (err) in
                if let err = err {
                    debugPrint("Error adding document: \(err)")
                }
                else{
                    self.dismiss(animated: true, completion: nil)
                }
            
            }
        }
    }
}
