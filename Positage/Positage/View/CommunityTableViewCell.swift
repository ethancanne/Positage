//
//  CommunityTableViewCell.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/27/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class CommunityTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var postMessageTextView: UITextView!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var numSupportLbl: UILabel!
    @IBOutlet weak var numInvestorsLbl: UILabel!
    @IBOutlet weak var stampsEarnedStckView: UIStackView!
    @IBOutlet weak var stampsEarnedNum: UILabel!
    
    @IBOutlet weak var investBtn: UIButton!
    @IBOutlet weak var giveSupportBtn: UIButton!
    
    //Variables
    private var entry: Entry!
    private var group: Group!
    
    var entryListener: ListenerRegistration!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    @IBAction func investBtnTapped(_ sender: Any) {
        PopupVC.showInvestPopup(entry: entry, group: group, from: getCurrentViewController())
    }
    
    @IBAction func giveSupportBtnTapped(_ sender: Any) {
        if let user = DataService.currentUser {
            if user.numSupportsRemaining >= 1{
                DataService.database.runTransaction({ (transaction, err) -> Any? in
                    
                    transaction.updateData([NUM_SUPPORTS_REMAINING : FieldValue.increment(-1.0)], forDocument: DataService.database.collection(USERS_REF).document(user.userId))
                    
                    transaction.updateData([NUM_SUPPORTS: FieldValue.increment(1.0)], forDocument: DataService.database.collection(GROUPS_REF).document(self.group.documentId).collection(ENTRY_REF).document(self.entry.documentId))
                    
                    transaction.updateData([USERS_SUPPORTED: FieldValue.arrayUnion([user.userId])], forDocument: DataService.database.collection(GROUPS_REF).document(self.group.documentId).collection(ENTRY_REF).document(self.entry.documentId))
                    
                    return nil
                }, completion: { (object, err) in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                })
            }
        }
    }
    

    
    
    func ConfigureCell(entry: Entry, group: Group){
        self.entry = entry
        self.group = group
        
        //Set data to cell
        titleLbl.text = entry.title
        print(entry.message)
        postMessageTextView.text = entry.message
        usernameLbl.text = "\(entry.username)"
        numSupportLbl.text = "\(entry.numSupports)"
        numInvestorsLbl.text = "\(entry.usersInvested.count)"
        
//        //for Category
//        switch entry.sorting {
//        case PRIORITY_SORTING:
//            cellView.backgroundColor = #colorLiteral(red: 0.7702729702, green: 0.8320232034, blue: 0.8880168796, alpha: 0.8514221557)
//            break
//        case NORMAL_SORTING:
//            cellView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//            break
//        default: break
//        }
        
        //User Specific settings
        guard let user = Auth.auth().currentUser else { return }

        let investment = entry.usersInvested[user.uid]
        
        let isInvested = (investment != nil)
        let isSupported = (entry.usersSupported.contains(String(user.uid)))
        let isCreator = (entry.userId == user.uid)
        
        
        

        giveSupportBtn.isHidden = (isInvested || isCreator) ? true : false //Only hide add support btn if user has invested or is the creator
        investBtn.isHidden = (isInvested || isSupported || isCreator) ? true : false
        stampsEarnedStckView.isHidden = (isInvested) ? false : true
        stampsEarnedNum.text = String(investment?[1] ?? 0) 
        
        

        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: entry.timestamp)
        timestampLbl.text = timestamp
    }

    
}

