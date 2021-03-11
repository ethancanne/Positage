//
//  InboxTableViewCell.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/23/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class InboxTableViewCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var stampsLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var categoryView: PositageView!
    @IBOutlet weak var stampsStackView: UIStackView!
    @IBOutlet weak var dateTrailCnstr: NSLayoutConstraint!
    @IBOutlet weak var didReadLbl: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func ConfigureCell(post: Post?){
        
        if let post = post{
            fromLbl.text = post.fromUsername
            titleLbl.text = post.title
            
            //for numStampsGiven
            if post.numStampsGiven != 0 {
                stampsLbl.text = String(post.numStampsGiven)
            }
            else{
                stampsStackView.isHidden = true
                dateTrailCnstr.constant = 12
                self.layoutIfNeeded()
            }
            
            //for Category
            switch post.category {
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
            
            //for DidRead
            if !post.didRead{
                didReadLbl.text = "*"
            }
            else{
                didReadLbl.text = "READ"
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, hh:mm"
            let timestamp = formatter.string(from: post.timestamp)
            dateLbl.text = timestamp
        }
    }
    
}
