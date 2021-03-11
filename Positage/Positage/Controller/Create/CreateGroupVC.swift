//
//  CreateGroupVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 1/7/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit

class CreateGroupVC: UIViewController {
}

class CreateGroupView: UIView, PaymentDelegate, ChooseUserDelegate{
    
    @IBOutlet var stampsViewLeadCnstr: [NSLayoutConstraint]!
    
    @IBOutlet var numStampsLbl: [UILabel]!
    
    @IBOutlet weak var addStampToJoin: PositageButton!
    @IBOutlet weak var removeStampToJoin: PositageButton!
    @IBOutlet weak var privateGroupSwitch: UISwitch!
    @IBOutlet weak var stampsToJoinNumLbl: UILabel!
    @IBOutlet weak var inviteesNumLbl: UILabel!
    @IBOutlet weak var nameOfGroupTxt: PositageTextField!
    @IBOutlet weak var descriptionTxtView: UITextView!
    
    public var pricingItems: [Price] = []
    
    private var stampsToJoin: Int = 0
    private var invitees: [String] = []
    
    override func didMoveToSuperview() {
        for cnstr in stampsViewLeadCnstr{
            cnstr.constant = -80
            layoutIfNeeded()
        }
        refreshPrice()
    }
    
    func animateStampCnstr(identifier: String, isVisible: Bool){
        var deltaX: CGFloat!
        let alpha: CGFloat = isVisible ?  1 : 0
        let alphaDuration:TimeInterval = isVisible ?  1 : 0.1
        
        var stampsLbl: UILabel?
        
        for lbl in self.numStampsLbl{
            if lbl.restorationIdentifier == identifier{
                stampsLbl = lbl
            }
        }
        if isVisible{
            stampsLbl?.alpha = 0
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
            stampsLbl?.alpha = alpha
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    func refreshPrice(oldValue: String = ""){
        pricingItems.removeAll()
        //Start
        pricingItems.append(Price(label: "Group Fee", numStamps: 5))
        
        //Private Group Pricing
        if privateGroupSwitch.isOn{
            pricingItems.append(Price(label: "Private Group", numStamps: 5))
        }
        
        //Give stamps pricing
        if stampsToJoin != 0 {
            pricingItems.append(Price(label: "Stamps To Join Fee", numStamps: (stampsToJoin/5)))
            for lbl in numStampsLbl{
                if lbl.restorationIdentifier == "stampsToJoin"{
                    lbl.text = "+\(stampsToJoin/5)"
                }
            }
        }
        stampsToJoinNumLbl.text = String(stampsToJoin)
        
        //Invitees pricing
        if !(invitees == []){
            let numOfInvitees = invitees.count
            pricingItems.append(Price(label: "Invitees", numStamps: (numOfInvitees * 2)))
            for lbl in numStampsLbl{
                if lbl.restorationIdentifier == "invitees"{
                    lbl.text = "+\(numOfInvitees * 2)"
                }
            }
        }
        
    }

    @IBAction func privateGroupSwitchChanged(_ sender: Any) {
        if privateGroupSwitch.isOn{
            animateStampCnstr(identifier: "isPrivateGroup", isVisible: true)
        }else{
            animateStampCnstr(identifier: "isPrivateGroup", isVisible: false)
        }
        refreshPrice()
    }
    
    
    
    @IBAction func addStampsToJoinBtnTapped(_ sender: Any) {
        stampsToJoin += 1
        if stampsToJoin == 5{
            animateStampCnstr(identifier: "stampsToJoin", isVisible: true)
        }
        refreshPrice()
    }
    
    //Given stamp has been removed
    @IBAction func removeStampsToJoinBtnTapped(_ sender: Any) {
        if stampsToJoin > 0{
            stampsToJoin -= 1
            refreshPrice()
        }
        if stampsToJoin == 4{
            animateStampCnstr(identifier: "stampsToJoin", isVisible: false)
        }
        
    }
    
    @IBAction func changeInviteesBtnTapped(_ sender: Any) {
        //present recipient view
        PopupVC.showChooseUserPopup(from: self, allowMultiple: true)
    }
    
    
    //Recipient Delegate
    func didChooseUsers(users: [User]) {
        if (invitees == []){
            animateStampCnstr(identifier: "invitees", isVisible: true)
        }
        invitees.removeAll()
        for user in users {
            invitees.append(user.userId)
        }
        inviteesNumLbl.text = String(users.count) + " Users"
        refreshPrice()
    }
  
    @IBAction func nextBtnTapped(_ sender: Any) {
        if nameOfGroupTxt.text != nil && descriptionTxtView.text != nil && stampsToJoin != nil {
            PopupVC.showPaymentPopup(with: pricingItems, from: self)
        }
    }
    
    func didReturnFromPayment(isSuccessfull: Bool) {
        if isSuccessfull{
            if let name: String = nameOfGroupTxt.text, let description: String = descriptionTxtView.text, let user = DataService.currentUser{
                let group: Group = Group(adminUsername: user.username, adminUserId: DataService.currentUser!.userId, joinedUsers: [user.userId], invitedUsers: invitees, isPrivate: privateGroupSwitch.isOn, numEntries: 0, title: name, description: description, stampsToPost: stampsToJoin, timestamp: Date(), documentId: String())
                DataService.database.collection(GROUPS_REF).document().setData(group.toDictionary())
                { err in
                    LoadingVC.dismissLoadingScreen()
                    
                    if let err = err {
                        NotificationVC.showNotification(withMessage: "There has been an error creating your group.", type: .error)
                        print("Error writing document: \(err)")
                    } else {
                        NotificationVC.showNotification(withMessage: "Your group: \(group.title) has been sucessfully created.", type: .inform)
                        print("Document successfully written!")
                        getCurrentViewController()?.dismiss(animated: true, completion: nil)
                        AppLocation.toggleSubmenu()
                    }
                }
                
            }
            
        }
    }
    
}

