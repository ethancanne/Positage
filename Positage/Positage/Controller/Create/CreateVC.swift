//
//  CreatePostVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/19/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//


import UIKit
import Firebase

let createConstants: [String] = ["Post", "Community Post", "Group"]

class CreateView: UIView{
    @IBOutlet weak var swipeChangeView: PositageView!
    @IBOutlet weak var createLbl: UILabel!
    @IBOutlet weak var createLblLeadCnstr: NSLayoutConstraint!
    @IBOutlet weak var swipeArrow: UILabel!
    
    
    var currentCreateSelected: String = createConstants[0] {
        didSet{
            //change view to match currentCreateSelected
        }
    }
    override func didMoveToSuperview() {
        var panGestrRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        swipeChangeView.addGestureRecognizer(panGestrRecognizer)
    }
    
    
    func setNextCreate(){
        
        if let createTxt = self.createLbl.text {
            var i = createConstants.firstIndex(of: createTxt) ?? 0
            if i == (createConstants.count - 1){
                i = -1
            }
            var nextCreate = createConstants[i+1]
            self.createLbl.text = nextCreate
            currentCreateSelected = nextCreate
        }
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer){
        var normalLeadCnstrConst: CGFloat = 16
        switch recognizer.state{
        case .began:
            print("Pan Began")
        case .changed:
            let translation = recognizer.translation(in: self)
            //Going left from normal
            if createLblLeadCnstr.constant <= normalLeadCnstrConst{
                createLblLeadCnstr.constant += translation.x
                createLbl.alpha += (translation.x/150)
                self.swipeArrow.alpha += (translation.x/150)
                self.layoutIfNeeded()
                recognizer.setTranslation(.zero, in: self)
            }
            //Going right from normal
            if createLblLeadCnstr.constant >= normalLeadCnstrConst{
                createLblLeadCnstr.constant += translation.x / 4
                self.layoutIfNeeded()
                recognizer.setTranslation(.zero, in: self)
            }
            
        case .ended:
            let velocity = recognizer.velocity(in: self).x
            print(velocity)
            if createLblLeadCnstr.constant <= -(self.createLbl.frame.width / 2) || velocity <= -250{
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    self.createLblLeadCnstr.constant = -(self.createLbl.frame.width)
                    self.createLbl.alpha = 0
                    self.swipeArrow.alpha = 0
                    self.layoutIfNeeded()
                }, completion: {(worked) in
                    self.createLblLeadCnstr.constant = self.swipeChangeView.frame.width
                    self.layoutIfNeeded()
                    
                    self.setNextCreate()
                    
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                        self.createLblLeadCnstr.constant = normalLeadCnstrConst
                        self.layoutIfNeeded()
                        self.createLbl.alpha = 1
                        self.swipeArrow.alpha = 1
                    }, completion: nil)
                })
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                    self.createLblLeadCnstr.constant = normalLeadCnstrConst
                    self.createLbl.alpha = 1
                    self.swipeArrow.alpha = 1
                    self.layoutIfNeeded()
                }, completion: nil)
            }
            
            
        default:
            print("Pan Error")
        }
        
        
    }
    func getCurrentViewController() -> UIViewController? {
        
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
        
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Popup", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "popupVC")
        popupVC.modalPresentationStyle = .overFullScreen
        getCurrentViewController()?.present(popupVC, animated: false)
        print("hello")
        
        
    }
    
}
class CreateVC: UIViewController, UITextViewDelegate{
    
    //Outlets
    @IBOutlet weak var postToCommunitySwitch: UISwitch!
    @IBOutlet weak var postNameTxt: UITextField!
    @IBOutlet weak var postDataTxt: UITextView!
    @IBOutlet weak var mainNextBtn: UIButton!
    
    //Pricing View
    @IBOutlet var pricingView: UIView!
    @IBOutlet weak var totalCostPopupLbl: UILabel!
    @IBOutlet weak var costBreakdownPopupLbl: UILabel!
    
    
    
    //Addtional Options/Confirm View
    @IBOutlet weak var enableSupportsViewHeightCnstr: NSLayoutConstraint!
    @IBOutlet weak var supportOptionsStackView: UIStackView!
    @IBOutlet weak var supportThankYouMsgTxt: PositageTextField!
    @IBOutlet var confirmView: UIView!
    @IBOutlet weak var promotedSwitch: UISwitch!
    @IBOutlet weak var enableSupportsSwitch: UISwitch!
    @IBOutlet weak var supportGoalTxt: PositageTextField!
    
    
    //PopUpVariables
    var chooseGroupVC: ChooseGroupVC!
    var backgroundView: UIView!
    
    //Variables
    var cost: Int = 0
    var sendSurcharge: Int = 0
    let firestore = Firestore.firestore()
    var selectedGroup: Group!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        postDataTxt.delegate = self
        //
        //
        //        postToCommunitySwitch.addTarget(self, action: #selector(communitySwitchDidChange), for: .valueChanged)
        //
        //        promotedSwitch.addTarget(self, action: #selector(promoteSwitchDidChange), for: .valueChanged)
        //
        //        enableSupportsSwitch.addTarget(self, action: #selector(enableSupportsSwitchDidChange), for: .valueChanged)
        //
        //        mainNextBtn.bindToKeyboard()
        //
        //        let groupsSB = UIStoryboard(name: "Groups", bundle: nil)
        //        chooseGroupVC = groupsSB.instantiateViewController(withIdentifier: "ChooseGroupVC") as? ChooseGroupVC
        //        chooseGroupVC.delegate = self
        //
        //        //FOR POPUP
        //        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        //        backgroundView.backgroundColor = #colorLiteral(red: 0.656727016, green: 0.6533910036, blue: 0.6593027115, alpha: 0.65703125)
        //        backgroundView.alpha = 0
        //
        //        //END FOR POPUP
        //        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPopUpView)))
        //
    }
    override func viewWillAppear(_ animated: Bool) {
        //
    }
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        dismissPopUpView()
    //    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //    //Actions
    //    @IBAction func CancelPressed(_ sender: Any) {
    //        dismiss(animated: true, completion: nil)
    //    }
    //
    //
    
    
    
    
    //    //Choose the group for Post
    //    @IBAction func mainNextBtnTapped(_ sender: Any) {
    //
    //
    //        if postToCommunitySwitch.isOn {
    //            updateCostLbl()
    //
    //            guard let window = UIApplication.shared.keyWindow else {return}
    //
    //            window.addSubview(backgroundView)
    //
    //
    //            //Create the pricing Popup
    //           pricingView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 147)
    //
    //            pricingView.center.x = view.center.x
    //            window.addSubview(pricingView)
    //
    //            //Create the chooseGroupView based on the chooseGroupVC
    //            guard let chooseGroupView = chooseGroupVC.view else {return}
    //            chooseGroupView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: window.frame.height / 2)
    //            window.addSubview(chooseGroupView)
    //
    //            //Animate them all into view
    //            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
    //                self.backgroundView.alpha = 1
    //                self.pricingView.frame.origin.y -= (window.frame.height / 2) + 110
    //                chooseGroupView.frame.origin.y -= chooseGroupView.frame.height
    //
    //            }, completion: nil)
    //
    //
    //        }
    //        else {
    //            performSegue(withIdentifier: "ToReviewSegue", sender: self)
    //        }
    //    }
    ////
    ////    @IBAction func confirmTapped(_ sender: Any) {
    ////
    ////        guard let user = Auth.auth().currentUser else { return }
    ////        guard let currentUserNumStamps = DataService.instance.currentUserNumStamps else { return }
    ////        guard let supportGoal = supportGoalTxt.text else { return }
    ////        guard let supportThankYouMsg = supportThankYouMsgTxt.text else { return }
    ////        let isPromoted = promotedSwitch.isOn
    ////        let supportsEnabled = enableSupportsSwitch.isOn
    ////        if currentUserNumStamps >= cost{
    ////
    ////            guard let postName = self.postNameTxt.text, let postData = self.postDataTxt.text else {return}
    ////
    ////            firestore.runTransaction({ (transaction, error) -> Any? in
    ////
    ////                let groupAdminUserDocument: DocumentSnapshot
    ////                if self.selectedGroup.documentId != "main" {
    ////                    do {
    ////                        try groupAdminUserDocument = transaction.getDocument(self.firestore.collection(USERS_REF).document(self.selectedGroup.adminUserId))
    ////                    }
    ////                    catch let error as NSError {
    ////                        debugPrint("Error reading User Document:\(error.localizedDescription)")
    ////                        return nil
    ////                    }
    ////
    ////                    guard let groupAdminOldNumStamps = groupAdminUserDocument.data()?[NUM_STAMPS] as? Int else { return nil }
    ////
    ////                    transaction.updateData([NUM_STAMPS : groupAdminOldNumStamps + self.selectedGroup.stampsToPost], forDocument:
    ////                        self.firestore.document("\(USERS_REF)/\(self.selectedGroup.adminUserId)"))
    ////
    ////                }
    ////
    ////
    ////                transaction.updateData([NUM_STAMPS : DataService.instance.currentUserNumStamps! - self.cost], forDocument:
    ////                    self.firestore.document("\(USERS_REF)/\(user.uid)"))
    ////
    ////                transaction.updateData([NUM_POSTS : self.selectedGroup.numPosts + 1], forDocument:
    ////                    self.firestore.document("\(GROUPS_REF)/\(self.selectedGroup.documentId)"))
    ////
    ////                let postRef = self.firestore.collection("\(GROUPS_REF)/\(self.selectedGroup.documentId)/\(POST_REF)").document()
    ////
    ////
    ////                transaction.setData([
    ////                    TITLE : postName,
    ////                    MESSAGE : postData,
    ////                    NUM_SUPPORTS : 0,
    ////                    USERS_SUPPORTED: [],
    ////                    SUPPORT_GOAL : Int(supportGoal),
    ////                    CUSTOM_SUPPORT_MESSAGE : supportThankYouMsg,
    ////                    TIMESTAMP : FieldValue.serverTimestamp(),
    ////                    FROM_USERNAME : Auth.auth().currentUser?.displayName ?? "anonomys", //this user
    ////                    FROM_USERID : Auth.auth().currentUser?.uid ?? ""
    ////                    ]
    ////                    , forDocument: postRef)
    ////
    ////
    ////                return nil
    ////
    ////
    ////            }) { (object, error) in
    ////                if let error = error {
    ////                    debugPrint("Error Creating Post:\(error.localizedDescription)")
    ////                }
    ////                else{
    ////                    self.dismiss(animated: true, completion: nil)
    ////                }
    ////            }
    ////        }
    ////
    ////        else{
    ////            print("User has an insignificant number of stamps. \(cost - currentUserNumStamps) more stamp(s) is/are needed to send this post.")
    ////            //Present alert
    ////            let alertView = UIAlertController(title: "Insignificant number of stamps.", message: "\(cost - currentUserNumStamps) more stamp(s) is/are needed to send this post.", preferredStyle: .actionSheet)
    ////            let action = UIAlertAction(title: "OK", style: .default)
    ////            alertView.addAction(action)
    ////            self.present(alertView, animated: true, completion: nil)
    ////        }
    ////
    ////    }
    ////
    ////    //END ACTIONS
    ////
    ////    //SELECTORS
    ////    @objc func dismissChooseGroupView(){
    ////        guard let chooseGroupView = chooseGroupVC.view else {return}
    ////
    ////        guard let window = UIApplication.shared.keyWindow else {return}
    ////
    ////        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
    ////            chooseGroupView.frame.origin.y += chooseGroupView.frame.height
    ////        }, completion: { (worked) in
    ////            chooseGroupView.removeFromSuperview()
    ////            // Show Confirm View
    ////            self.confirmView.frame = CGRect(x: 0, y:  window.frame.height, width: window.frame.width, height: 300)
    ////
    ////
    ////            window.addSubview(self.confirmView)
    ////
    ////
    ////            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
    ////                self.pricingView.frame.origin.y += 100
    ////                self.confirmView.frame.origin.y -= self.confirmView.frame.height
    ////
    ////            })
    ////        })
    ////
    ////    }
    
    //    @objc func dismissPopUpView(){
    //        guard let window = UIApplication.shared.keyWindow else {return}
    //        guard let chooseGroupView = chooseGroupVC.view else {return}
    //
    //        if chooseGroupView.isDescendant(of: window){
    //            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
    //                chooseGroupView.frame.origin.y += chooseGroupView.frame.height
    //                self.pricingView.frame.origin.y = window.frame.height
    //                self.backgroundView.alpha = 0
    //            }, completion: { (worked) in
    //                chooseGroupView.removeFromSuperview()
    //                self.pricingView.removeFromSuperview()
    //                self.backgroundView.removeFromSuperview()
    //            })
    //        }
    //        else{
    //            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
    //                self.confirmView.frame.origin.y += self.confirmView.frame.height
    //                self.pricingView.frame.origin.y = window.frame.height
    //                self.backgroundView.alpha = 0
    //            }, completion: { (worked) in
    //                self.confirmView.removeFromSuperview()
    //                self.pricingView.removeFromSuperview()
    //                self.backgroundView.removeFromSuperview()
    //
    //                if self.enableSupportsSwitch.isOn {
    //                    self.enableSupportsSwitch.setOn(false, animated: true)
    //                    self.enableSupportsSwitchDidChange()
    //                }
    //
    //                if self.promotedSwitch.isOn {
    //                    self.promotedSwitch.setOn(false, animated: true)
    //                    self.promoteSwitchDidChange()
    //                }
    //
    //            })
    //        }
    //
    //        if selectedGroup != nil {
    //            cost -= selectedGroup.stampsToPost
    //            selectedGroup = nil
    //        }
    //    }
    
    //    @objc func communitySwitchDidChange(communitySwitch: UISwitch){
    //        if communitySwitch.isOn {
    //            cost -= sendSurcharge
    //            self.mainNextBtn.setTitle("Post", for: .normal)
    //        }
    //        else{
    //            cost += sendSurcharge
    //            self.mainNextBtn.setTitle("Review", for: .normal)
    //        }
    //    }
    
    //    @objc func promoteSwitchDidChange() {
    //        if promotedSwitch.isOn {
    //            cost += 7
    //        }
    //        else{
    //            cost -= 7
    //        }
    //        updateCostLbl()
    //    }
    //
    //    @objc func enableSupportsSwitchDidChange(){
    //        if enableSupportsSwitch.isOn {
    //            cost += 0
    //
    //            self.supportOptionsStackView.alpha = 0
    //            supportOptionsStackView.isHidden = false
    //
    //            enableSupportsViewHeightCnstr.constant += 100
    //            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
    //                self.confirmView.layoutIfNeeded()
    //                self.confirmView.frame = CGRect(x: self.confirmView.frame.minX, y: self.confirmView.frame.minY, width: self.confirmView.frame.width, height: self.confirmView.frame.height + 100)
    //                self.confirmView.frame.origin.y -= 100
    //                self.pricingView.frame.origin.y -= 100
    //                self.supportOptionsStackView.alpha = 1
    //            })
    //        }
    //
    //        else{
    //            cost += 0
    //
    //            supportGoalTxt.text = "0"
    //            supportThankYouMsgTxt.text = ""
    //
    //            enableSupportsViewHeightCnstr.constant -= 100
    //            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
    //                self.confirmView.layoutIfNeeded()
    //                self.confirmView.frame = CGRect(x: self.confirmView.frame.minX, y: self.confirmView.frame.minY, width: self.confirmView.frame.width, height: self.confirmView.frame.height - 100)
    //                self.confirmView.frame.origin.y += 100
    //                self.pricingView.frame.origin.y += 100
    //                self.supportOptionsStackView.alpha = 0
    //
    //            }, completion: {(worked) in
    //                self.supportOptionsStackView.isHidden = true
    //            })
    //
    //            supportGoalTxt.text = "0"
    //        }
    //        updateCostLbl()
    //
    //
    //
    //    }
    //
    //    //END SELECTORS
    //
    //
    //    //TEXTVIEW PROTOCOL STUBS
    //    func textViewDidBeginEditing(_ textView: UITextView) {
    //        textView.text = String()
    //        textView.textColor = UIColor.darkGray
    //
    //        view.addSubview(backgroundView)
    //        view.bringSubviewToFront(postDataTxt)
    //
    //
    ////        UIView.animate(withDuration: 1) {
    ////            self.postDataTopCnstr.constant -= 200
    ////            self.backgroundView.alpha = 1
    ////        }
    //
    //    }
    //
    //    func textViewDidChange(_ textView: UITextView) {
    //        postDataTxt.layoutIfNeeded()
    //        var wordsInTxtData = [String]()
    //        wordsInTxtData = postDataTxt.text.components(separatedBy: " ")
    //
    //        if wordsInTxtData.count >= 50{
    //            if wordsInTxtData.count <= 100 {
    //                sendSurcharge = 2
    //            }
    //            else{
    //                sendSurcharge = 3
    //            }
    //        }
    //        else {
    //            sendSurcharge = 1
    //        }
    //        updateCostLbl()
    //    }
    //
    //    //END TEXTVIEW PROTOCOL STUBS
    //
    //
    //    //GENERAL FUNCTIONS
    //    func updateCostLbl(){
    //
    //        if !postToCommunitySwitch.isOn{
    //            cost = sendSurcharge
    //        }
    //        costBreakdownPopupLbl.text = ""
    //        if promotedSwitch.isOn == true {
    //            costBreakdownPopupLbl.text?.append("Post Promoted: 7\n")
    //        }
    //        if enableSupportsSwitch.isOn == true{
    //            costBreakdownPopupLbl.text?.append("Supports Enabled: 0\n")
    //
    //        }
    //        if selectedGroup != nil {
    //            costBreakdownPopupLbl.text?.append("\(selectedGroup.groupName): \(selectedGroup.stampsToPost)\n")
    //        }
    //
    //
    //        totalCostPopupLbl.text = String(cost)
    //
    //    }
    //    //END GENERAL FUNCTIONS
    //
    //
    //
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "ToReviewSegue" && postNameTxt.text != nil && postDataTxt.text != nil{
    //
    //            if !postToCommunitySwitch.isOn{
    //                let reviewVC = segue.destination as! ReviewPostVC
    //
    //                if let postName = postNameTxt.text,
    //                    let postData = postDataTxt.text {
    //                    reviewVC.postName = postName
    //                    reviewVC.postData = postData
    //                    reviewVC.cost = Int(sendSurcharge)
    //                    reviewVC.sendSurcharge = Int(sendSurcharge)
    //                }
    //                else {
    //                    print("Error creating post: nil value")
    //                }
    //            }
    //
    //        }
    //        else {
    //            return
    //        }
    //
    //
    //    }
    //
    //
    //}
    //
    //extension CreatePostVC: GroupDelegate {
    //    func didSelectGroup(group: Group) {
    //        selectedGroup = group
    //        cost += group.stampsToPost
    //        dismissChooseGroupView()
    //        updateCostLbl()
    //
    //    }
    //
    //
}



