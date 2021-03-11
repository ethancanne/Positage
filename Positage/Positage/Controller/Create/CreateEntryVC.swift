//
//  CommunityPostPopupVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/16/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase
class CreateEntryVC: UIViewController{
    
}

class CreateEntryView: UIView, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, PaymentDelegate, ChooseGroupDelegate{
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var titleTxt: PositageTextField!
    
    @IBOutlet weak var sortAsView: PositageView!
    @IBOutlet weak var sortAsPickerView: UIPickerView!
    
    @IBOutlet weak var investmentThankYouMsgTxt: PositageTextField!
    
    @IBOutlet weak var investmentChargeTxt: PositageTextField!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet var stampsViewLeadCnstr: [NSLayoutConstraint]!
    
    @IBOutlet var numStampsLbl: [UILabel]!
    
    private var title: String = ""
    private var message: String = ""
    
    private var group: Group? {
        didSet{
            titleLbl.text = group?.title
        }
    }
    
    private var investmentCharge: Int = 0 {
        didSet{
            //if investmentCharge was 0, but is now being set to a value
            if (oldValue == 0) && (investmentCharge > 0){
                animateStampCnstr(identifier: "investmentCharge", isVisible: true)
                
                //if investmentCharge was not 0, but is now being set to 0
            }else if (investmentCharge == 0) && (oldValue != 0) {
                animateStampCnstr(identifier: "investmentCharge", isVisible: false)
            }
        }
    }
    
    private var investmentThankYouMsg: String = ""{
        didSet{
            if (oldValue == "") && (investmentThankYouMsg != ""){
                animateStampCnstr(identifier: "investmentThankYouMsg", isVisible: true)
            }else if (investmentThankYouMsg == ""){
                animateStampCnstr(identifier: "investmentThankYouMsg", isVisible: false)
            }
        }
    }
    
    public var pricingItems: [Price] = []
    
    private var chosenSorting: String = NORMAL_SORTING {
        didSet{
            //Refresh category and pass in previous category selected.
            if chosenSorting == PRIORITY_SORTING && oldValue == NORMAL_SORTING{
                animateStampCnstr(identifier: "sortAs", isVisible: true)
                sortAsView.backgroundColor = #colorLiteral(red: 0.9400489926, green: 0.733499229, blue: 0.7242506146, alpha: 1)
                refreshPrice()
            }else if chosenSorting == NORMAL_SORTING && oldValue == PRIORITY_SORTING {
                animateStampCnstr(identifier: "sortAs", isVisible: false)
                sortAsView.backgroundColor = #colorLiteral(red: 0.8168090582, green: 0.8169469237, blue: 0.8167908788, alpha: 1)
                refreshPrice()
            }
        }
    }
    
    
    override func didMoveToSuperview() {
        self.bindToKeyboard()
        
        sortAsPickerView.delegate = self
        sortAsPickerView.dataSource = self
        
        investmentChargeTxt.delegate = self
        investmentThankYouMsgTxt.delegate = self
        
        
        
        for cnstr in stampsViewLeadCnstr{
            cnstr.constant = -80
        }
        refreshPrice()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    //General Functions
    func animateStampCnstr(identifier: String, isVisible: Bool){
        var deltaX: CGFloat!
        let alpha: CGFloat = isVisible ?  1 : 0
        let alphaDuration:TimeInterval = isVisible ?  1 : 0.1
        
        var stampsLbl: UILabel!
        for lbl in self.numStampsLbl{
            if lbl.restorationIdentifier == identifier{
                stampsLbl = lbl
            }
        }
        if isVisible{
            stampsLbl.alpha = 0
            deltaX = 80
        }else{
            deltaX = -80
        }
        
        for cnstr in stampsViewLeadCnstr{
            if cnstr.identifier == identifier{
                cnstr.constant += deltaX
            }
        }
        
        UIView.animate(withDuration: alphaDuration) {
            stampsLbl.alpha = alpha
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func refreshPrice(oldValue: String = ""){
        pricingItems.removeAll()
        //Start
        pricingItems.append(Price(label: "Entry Fee", numStamps: 0))
        
        
        //SortAs Pricing
        if chosenSorting == PRIORITY_SORTING{
            pricingItems.append(Price(label: "Priority Sorting", numStamps: 5))
        }
        
        //Support Goal Pricing
        if (investmentCharge > 0){
            pricingItems.append(Price(label: "Charge Fee", numStamps: 1))
        }
        
        //Support Msg Pricing
        if (investmentThankYouMsg != ""){
            pricingItems.append(Price(label: "Support Msg Fee", numStamps: 3))
        }
        
        
    }
    
    //If investmentChargeTxt starts editing, remove the "stamps" text
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == investmentChargeTxt{
            investmentChargeTxt.text = ""
        }
    }
    
    //Once text is entered into either investmentThankYouMsg or investmentChargeTxt, update the respective variables
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == investmentThankYouMsgTxt {
            if let investmentThankYouMsg = investmentThankYouMsgTxt.text{
                self.investmentThankYouMsg = (investmentThankYouMsg != "") ? investmentThankYouMsg : ""
                refreshPrice()
            }
        }
            
        else if textField == investmentChargeTxt{
            if let investmentCharge = Int(investmentChargeTxt.text ?? "0"){
                self.investmentCharge = (investmentCharge >= 0) ? investmentCharge : 0
                refreshPrice()
            }
        }
    }
    
    //If investmentChargeTxt ends editing, insert the "stamps" text
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == investmentChargeTxt{
            investmentChargeTxt.text = "\(investmentCharge) Stamps"
        }
    }
    
    
    
    //Choose group btn has been tapped
    @IBAction func chooseGroupBtnTapped(_ sender: Any) {
        //present chooseGroup view
        PopupVC.showChooseGroupPopup(from: self)
    }
    
    func didChooseGroup(group: Group) {
        self.group = group
    }
    
    
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        PopupVC.showPaymentPopup(with: pricingItems, from: self)
    }
    
    func didReturnFromPayment(isSuccessfull: Bool) {
        if isSuccessfull{
            guard let user = DataService.currentUser else { return }
            if let title = titleTxt.text, let message = messageTxtView.text, let supportMsg = investmentThankYouMsgTxt.text, let group = group{
                
                //Make entry from entered data
                let entry:Entry = Entry(title: title, message: message, sorting: chosenSorting, numSupports: 0, usersSupported: [], usersInvested: [:], investmentThankYouMsg: investmentThankYouMsg, investmentCharge: investmentCharge, username: user.username, userId: user.userId, timestamp: Date(), documentId: "")
                
                
                DataService.database.runTransaction({ (transaction, err) -> Any? in
                    
                    transaction.setData(entry.toDictionary(), forDocument: DataService.database.collection("\(GROUPS_REF)/\(group.documentId)/\(ENTRY_REF)").document())
                    
                    transaction.updateData([NUM_ENTRIES : FieldValue.increment(1.0)], forDocument: DataService.database.collection(GROUPS_REF).document(group.documentId))
                    
                    return nil
                }, completion: { (object, err) in
                    
                    LoadingVC.dismissLoadingScreen()
                    
                    if let err = err {
                        
                        print("Error writing document: \(err)")
                        NotificationVC.showNotification(withMessage: "There has been an error publishing your entry", type: .error)
                        
                    } else {
                        print("Document successfully written!")
                        getCurrentViewController()?.dismiss(animated: true, completion: nil)
                        AppLocation.toggleSubmenu()
                        NotificationVC.showNotification(withMessage: "Entry successfully published.", type: .inform)
                        
                    }
                })
            }
        } else{
           print("Not Successful")
        }
    }
    
    
                
            
    
    
    
    //PickerView Protocol Stubs
    var sortingsToChoose: [String] = [NORMAL_SORTING, PRIORITY_SORTING]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortingsToChoose.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        //Remove pickerview indicators
        pickerView.subviews.forEach({
            $0.isHidden = $0.frame.height < 1.0
        })
        
        return sortingsToChoose[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chosenSorting = sortingsToChoose[row]
    }
    
}
