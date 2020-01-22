//
//  CreateGroupVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 1/7/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit

class CreateGroupVC: UIViewController {

    
        @IBOutlet var stampsViewLeadCnstr: [NSLayoutConstraint]!
        
        @IBOutlet var numStampsLbl: [UILabel]!
        
        
        public var post: CommunityPost!
        public var pricingItems: [Price] = []
        
        private var cost: Int = 0
        
        
        private var chosenSorting: String = NORMAL_SORTING {
            didSet{
                if chosenSorting == NORMAL_SORTING && oldValue == PRIORITY_SORTING {
                    cost -= 5
                }
                else if chosenSorting == PRIORITY_SORTING{
                    cost += 5
                    pricingItems.append(Price(label: "Priority sorting", numStamps: 5))
                }
            }
        }
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
    //        performSegue(withIdentifier: "toPricing", sender: self)
            sortAsPickerView.delegate = self
            supportMessageTxt.delegate = self
        }
        
        @IBAction func changeGroupBtnTapped(_ sender: Any) {
        }
        @IBAction func nextBtnTapped(_ sender: Any) {
            if let supportGoal = supportGoalTxt.text{
                if supportGoal != ""{
                    post.setSupportGoal(supportGoal: supportGoal)
                }
                else{
                    //throw Error("A support goal must be specified.")
                }
            }
            if let supportMsg = supportMessageTxt.text {
                if supportMsg != ""{
                    post.setSupportMessage(message: supportMsg)
                }
            }
            
        }
        
        func animateStampCnstr(identifier: String){
            let deltaX: CGFloat = -40
            if identifier == SORTING {
                stampsViewLeadCnstr[0].constant += deltaX
            }
            else if identifier == SUPPORT_GOAL {
                stampsViewLeadCnstr[1].constant += deltaX
            }
            else if identifier == CUSTOM_SUPPORT_MESSAGE {
                stampsViewLeadCnstr[2].constant += deltaX
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "toPricing"{
    //            let pricingVC = segue.destination as! PaymentPopupVC
    //            pricingVC.cost = cost
    //            pricingVC.communityPost = post
    //            pricingVC.pricingItems = pricingItems
    //
    //        }
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
            return sortingsToChoose[row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            chosenSorting = sortingsToChoose[row]
        }
        
        //TextView Protocol Stubs
        var didApplyPricing: Bool = true
        func textViewDidChange(_ textView: UITextView) {
            if (supportMessageTxt.text != nil || supportMessageTxt.text != "") && !(didApplyPricing){
                cost += 3
                didApplyPricing = true
                pricingItems.append(Price(label: "Custom Support Msg", numStamps: 3))
            } else {
                cost -= 3
                didApplyPricing = false
            }
        }

}
