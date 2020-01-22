//
//  CreateGroupVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 5/1/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class CreateGroupVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    //Outlets
    @IBOutlet weak var groupTitleTxt: UITextField!
    @IBOutlet weak var groupDescriptionTxt: PositageTextView!
    @IBOutlet weak var reqStampPickerView: UIPickerView!
    @IBOutlet weak var totalCostLbl: UILabel!
    
    //Variables
    var cost: Int = 5
    var stampsToPostSurcharge: Int = 0
    var stampsToPost: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //PickerView
        reqStampPickerView.delegate = self
        reqStampPickerView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        totalCostLbl.text = String(cost)
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        guard let currentUserNumStamps = DataService.instance.currentUserNumStamps else { return }
        if currentUserNumStamps >= cost{
            
            //Update Stamps
            Firestore.firestore().document("\(USERS_REF)/\(user.uid)/").updateData([NUM_STAMPS : currentUserNumStamps - self.cost])
            
            //Add Group to DB
            let groupRef: CollectionReference = Firestore.firestore().collection(GROUPS_REF)
            groupRef.addDocument(data: [
                ADMIN_USERNAME : user.displayName!,
                ADMIN_USERID : user.uid,
                GROUPS_REF: self.groupDescriptionTxt.text,
                GROUP_NAME : self.groupTitleTxt.text,
                GROUP_DESC : self.groupDescriptionTxt.text,
                STAMPS_TO_POST : self.stampsToPost,
                NUM_POSTS: 0
            ]){ (err) in
                if let err = err {
                    debugPrint("Error adding document: \(err)")
                }
                else{
                    //Dismiss View
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
            
        }
        
        
    }
    
    
    
    //PickerView Protocol Stubs
    var stampsToChoose: [Int] = [0, 1, 2, 3, 4, 5, 10, 15]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stampsToChoose.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(stampsToChoose[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stampsToPost = stampsToChoose[row]
        stampsToPostSurcharge = stampsToChoose[row]
        totalCostLbl.text = String(cost + stampsToPostSurcharge)
    }

}
