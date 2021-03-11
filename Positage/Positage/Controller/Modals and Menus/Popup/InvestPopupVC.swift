//
//  InvestPopupVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 5/4/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class InvestPopupVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, PaymentDelegate {
    
    
    @IBOutlet weak var earningsPickerView: UIPickerView!
    @IBOutlet weak var earningsStampsLbl: UILabel!
    @IBOutlet weak var entryTitleLbl: UILabel!
    @IBOutlet weak var entryCreatedByLbl: UILabel!
    @IBOutlet weak var entryMessageLbl: UITextView!
    @IBOutlet weak var entrySupportsNumLbl: UILabel!
    
    var earningsToChoose: [Int] = [1, 2, 3]
    
    var chosenEarning: Int! {
        didSet{
            earningsStampsLbl.text = ((chosenEarning == earningsToChoose[0]) ? "+5" : ((chosenEarning == earningsToChoose[1]) ? "+10" : "+20"))
        }
    }
    
    
    
    var group: Group!
    var entry: Entry!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        earningsPickerView.delegate = self
        earningsPickerView.dataSource = self
        
        chosenEarning = earningsToChoose[0]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        entryTitleLbl.text = entry.title
        
        entryCreatedByLbl.text = entry.username
        
        entryMessageLbl.text = entry.message
        
        
        //TODO: Need listener for changing supports
        entrySupportsNumLbl.text = String(entry.numSupports)
    }
    
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        var pricingArr: [Price] =
            [Price(label: "Creator Fee", numStamps: entry.investmentCharge),
             Price(label: "Support Amount Fee", numStamps: (entry.numSupports / 2)),
             Price(label: "Investment Charge", numStamps: (chosenEarning == earningsToChoose[0]) ? 5 : ((chosenEarning == earningsToChoose[1]) ? 10 : 20))]
        PopupVC.showPaymentPopup(with: pricingArr, from: self)
    }
    
    func didReturnFromPayment(isSuccessfull: Bool) {
        if isSuccessfull{
            if let user = DataService.currentUser {
                DataService.database.runTransaction({ (transaction, err) -> Any? in
                    
                    //Pay the creator the Creator set fee the investor payed
                    transaction.updateData([NUM_STAMPS: FieldValue.increment(Double(self.entry.investmentCharge))], forDocument: DataService.database.collection(USERS_REF).document(self.entry.userId))
                    
                    //Add the investor as a new firestore map entry
                    //Dictionary with array for users invested: [User Id : [Earnings/10Supports, AmountEarned]]
                    transaction.updateData([USERS_INVESTED: [user.userId : ([self.chosenEarning, 0])]], forDocument: DataService.database.collection(GROUPS_REF).document(self.group.documentId).collection(ENTRY_REF).document(self.entry.documentId))
                    
                    return nil
                }, completion: { (object, err) in
                    LoadingVC.dismissLoadingScreen()
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        NotificationVC.showNotification(withMessage: "Successfully invested: " + self.entry.investmentThankYouMsg, type: .inform)
                        getCurrentViewController()?.dismiss(animated: true){
                            getCurrentViewController()?.dismiss(animated: true, completion: nil)
                        }

                        print("Document successfully written!")
                    }
                })

            }
        }
    }
    
    //PickerView Protocol Stubs
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return earningsToChoose.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        //Remove pickerview indicators
        pickerView.subviews.forEach({
            $0.isHidden = $0.frame.height < 1.0
        })
        
        return "\(earningsToChoose[row]) Stamps"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chosenEarning = earningsToChoose[row]
    }


}
