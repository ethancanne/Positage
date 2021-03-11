//
//  TrackTableViewCell.swift
//  Positage
//
//  Created by Ethan Cannelongo on 1/28/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class OngoingPostTableViewCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
     @IBOutlet weak var dateTrailCnstr: NSLayoutConstraint!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var categoryView: PositageView!
    @IBOutlet weak var numUnreadLbl: UILabel!
    @IBOutlet weak var numUnreadView: UIView!
    @IBOutlet weak var stampsLbl: UILabel!
    @IBOutlet weak var stampsStackView: UIStackView!


    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func ConfigureCell(ongoingPost: OngoingPost){
        
        fromLbl.text = ongoingPost.fromUsername
        
        titleLbl.text = ongoingPost.title
        
        //for numStampsGiven
        if ongoingPost.numStampsGiven != 0 {
            stampsLbl.text = String(ongoingPost.numStampsGiven)
        }
        else{
            stampsStackView.isHidden = true
            dateTrailCnstr.constant = 12
            self.layoutIfNeeded()
        }
        
        //for Category
        switch ongoingPost.category {
        case IMPORTANT_CATEGORY:
            categoryView.backgroundColor = #colorLiteral(red: 0.972407043, green: 0.7277194858, blue: 0.7238407135, alpha: 1)
            categoryLbl.text = "Important"
            break
        case CASUAL_CATEGORY:
            categoryView.backgroundColor = #colorLiteral(red: 0.815623343, green: 0.8157219291, blue: 0.815589726, alpha: 1)
            categoryLbl.text = "Casual"
            break
        default: break
        }
        
        //for numUnread
        let numUnread: Int = ongoingPost.numRecipientUnreadMessages

        numUnreadLbl.text = String(numUnread)
        if numUnread >= 25{
            numUnreadView.backgroundColor = #colorLiteral(red: 0.7385402918, green: 0.4625687599, blue: 0.4465906024, alpha: 1)
        }
        else if numUnread >= 10{
            numUnreadView.backgroundColor = #colorLiteral(red: 0.8742756248, green: 0.6583238244, blue: 0.6538267136, alpha: 1)
        }
        else{
            numUnreadView.backgroundColor = #colorLiteral(red: 0.7261201739, green: 0.7633758783, blue: 0.6962124109, alpha: 1)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: ongoingPost.timestamp)
        dateLbl.text = timestamp
        
    }
    
}
