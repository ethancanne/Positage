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
    @IBOutlet weak var inboxView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var stampsLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inboxView.layer.cornerRadius = 9
        inboxView.clipsToBounds = true
    }

    func ConfigureCell(post: Post){
        if Auth.auth().currentUser?.displayName == post.fromUsername {
            fromLbl.text = "from: (You)"
        }
        else{
            fromLbl.text = "from: \(post.fromUsername)"
        }
        titleLbl.text = post.title
        stampsLbl.text = "\(String(post.numStamps)) Stamps"
        
        if post.numStamps >= 10 {
            backgroundColor = #colorLiteral(red: 0.9721066356, green: 0.9671644568, blue: 0.9759197831, alpha: 1)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: post.timestamp)
        dateLbl.text = timestamp

    }

}
