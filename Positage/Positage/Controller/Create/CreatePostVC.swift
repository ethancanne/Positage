//
//  CreatePostVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 1/7/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase


class CreatePostVC: UIViewController{
}

class CreatePostView: UIView, ChooseUserDelegate, PaymentDelegate, UIPickerViewDataSource, UIPickerViewDelegate{
    
    //Post
    @IBOutlet weak var titleTxt: PositageTextField!
    @IBOutlet weak var messageTxtView: UITextView!
    
    //Options
    @IBOutlet weak var categoryView: PositageView!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    @IBOutlet var stampsViewLeadCnstr: [NSLayoutConstraint]!
    
    @IBOutlet var numStampsLbl: [UILabel]!
    @IBOutlet weak var isOngoingPostSwitch: UISwitch!
    
    @IBOutlet weak var recipientNameLbl: UILabel!
    
    public var pricingItems: [Price] = []
    
    private var stampsGiven: Int = 0
    private var toUser: User! {
        //Refresh Recipient Label when a new recipient has been chosen in didSelectRecipient
        didSet{
            recipientNameLbl.text = toUser.username
        }
    }
    
    //Set new category
    private var chosenCategory: String = CASUAL_CATEGORY {
        didSet{
            //Refresh category and pass in previous category selected.
            if chosenCategory == IMPORTANT_CATEGORY && oldValue == CASUAL_CATEGORY{
                animateStampCnstr(identifier: "category", isVisible: true)
                categoryView.backgroundColor = #colorLiteral(red: 0.9400489926, green: 0.733499229, blue: 0.7242506146, alpha: 1)
                refreshPrice()
            }else if chosenCategory == CASUAL_CATEGORY && oldValue == IMPORTANT_CATEGORY {
                animateStampCnstr(identifier: "category", isVisible: false)
                categoryView.backgroundColor = #colorLiteral(red: 0.8168090582, green: 0.8169469237, blue: 0.8167908788, alpha: 1)
                refreshPrice()
            }
        }
    }
    
    
    
    override func didMoveToSuperview() {
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        
        
        for cnstr in stampsViewLeadCnstr{
            cnstr.constant = -80
//            layoutIfNeeded()
        }
        refreshPrice()
        
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
        pricingItems.append(Price(label: "Posting Fee", numStamps: 1))
        //Category Pricing
        if chosenCategory == IMPORTANT_CATEGORY{
            pricingItems.append(Price(label: "Important Category", numStamps: 5))
        }
        
        //OngoingPost Pricing
        if isOngoingPostSwitch.isOn{
            pricingItems.append(Price(label: "OngoingPost", numStamps: 5))
        }
        
        //Give stamps pricing
        if stampsGiven != 0 {
            pricingItems.append(Price(label: "Stamps Given", numStamps: stampsGiven))
            for lbl in numStampsLbl{
                if lbl.restorationIdentifier == "giveStamps"{
                    lbl.text = "+\(stampsGiven)"
                }
            }
        }
        if toUser != nil{
            pricingItems.append(Price(label: "Recipient Fee", numStamps: toUser.numStampsToSend))
            for lbl in numStampsLbl{
                if lbl.restorationIdentifier == "recipient"{
                    lbl.text = "+\(toUser.numStampsToSend)"
                }
            }
        }
    }
    
    //Specific Option Functions
    //OngoingPost Switch Changed function
    @IBAction func isOngoingPostSwitchChanged(_ sender: Any) {
        if isOngoingPostSwitch.isOn{
            animateStampCnstr(identifier: "isOngoingPost", isVisible: true)
        }else{
            animateStampCnstr(identifier: "isOngoingPost", isVisible: false)
        }
        refreshPrice()
    }
    
    //Stamp has been given
    @IBAction func addGiveStampsBtnTapped(_ sender: Any) {
        if stampsGiven == 0{
            animateStampCnstr(identifier: "giveStamps", isVisible: true)
        }
        stampsGiven += 1
        refreshPrice()
    }
    
    //Given stamp has been removed
    @IBAction func removeGiveStampsBtnTapped(_ sender: Any) {
        if stampsGiven == 1{
            animateStampCnstr(identifier: "giveStamps", isVisible: false)
            stampsGiven -= 1
            refreshPrice()
        }else if stampsGiven > 1{
            stampsGiven -= 1
            refreshPrice()
        }
        
    }
    
    //Change recipient btn has bee tapped
    @IBAction func changeRecipientTapped(_ sender: Any) {
        let popupVC = instantiateViewController(fromStoryboard: "Popup", withIdentifier: "popupVC") as! PopupVC
        let recipientVC=instantiateViewController(fromStoryboard: "Popup", withIdentifier: "recipientVC") as! ChooseUserPopupVC
        popupVC.setupPopup(withViewController: recipientVC)
        recipientVC.delegate = self
        popupVC.modalPresentationStyle = .overFullScreen
        getCurrentViewController()?.present(popupVC, animated: false)
    }
    
    //Recipient Delegate
    func didChooseUsers(users: [User]) {
        if toUser == nil{
            animateStampCnstr(identifier: "recipient", isVisible: true)
        }
        toUser = users[0]
        refreshPrice()
    }
    
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        if titleTxt.text != nil && messageTxtView.text != nil && toUser != nil {
            PopupVC.showPaymentPopup(with: pricingItems, from: self)
        }
    }
    
    //Pricing Delegate
    func didReturnFromPayment(isSuccessfull: Bool) {
        if isSuccessfull{
            guard let user = DataService.currentUser else {return}
            if let title = titleTxt.text, let message = messageTxtView.text {
                //Make post from entered data
                let post: Post!
                if isOngoingPostSwitch.isOn{
                    post = OngoingPost(title: title, message: message, numRecipientUnreadMessages: 0, numSenderUnreadMessages: 0, numStampsGiven: stampsGiven, didRead: false, timestamp: Date(), category: chosenCategory, fromUsername: user.username, fromUserId: user.userId, toUsername: toUser.username, toUserId: toUser.userId, documentId: String())
                } else{
                    post = Post(title: title, message: message, numStampsGiven: stampsGiven, didRead: false, timestamp: Date(), category: chosenCategory, fromUsername: user.username, fromUserId: user.userId, toUsername: toUser.username, toUserId: toUser.userId, documentId: String())
                }
                
                //Submit post to database
                DataService.database.collection(POST_REF).document().setData(post.toDictionary())
                { err in
                    LoadingVC.dismissLoadingScreen()
                    
                    if let err = err {
                        NotificationVC.showNotification(withMessage: "There has been an error creating your post.", type: .error)
                        print("Error writing document: \(err)")
                    } else {
                        NotificationVC.showNotification(withMessage: "Your post \(post.title) has been sucessfully sent.", type: .inform)
                        print("Document successfully written!")
                        getCurrentViewController()?.dismiss(animated: true, completion: nil)
                        AppLocation.toggleSubmenu()
                    }
                }
            }
        }else{
            print("Not Successful!")
        }
    }
    
    //PickerView Protocol Stubs
    var categoriesToChoose: [String] = [CASUAL_CATEGORY, IMPORTANT_CATEGORY]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoriesToChoose.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        //Remove pickerview indicators
        pickerView.subviews.forEach({
            $0.isHidden = $0.frame.height < 1.0
        })
        
        return categoriesToChoose[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chosenCategory = categoriesToChoose[row]
    }
    
}
