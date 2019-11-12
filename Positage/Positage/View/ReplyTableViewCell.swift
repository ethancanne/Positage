//
//  ReplyTableViewCell.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/3/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class ReplyTableViewCell: UITableViewCell {

    //Outlets
    //Outgoing
    @IBOutlet weak var usernameOutLbl: UILabel!
    @IBOutlet weak var timestampOutLbl: UILabel!
    @IBOutlet weak var messageOutLbl: UILabel!
    
    //Incoming
    @IBOutlet weak var usernameInLbl: UILabel!
    @IBOutlet weak var timestampInLbl: UILabel!
    @IBOutlet weak var messageInLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(reply: Reply){
        guard let user = Auth.auth().currentUser else { return }
        if reply.userId == user.uid {
            usernameOutLbl.text = reply.username
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, hh:mm"
            let timestamp = formatter.string(from: reply.timestamp)
            
            timestampOutLbl.text = timestamp
            
            messageOutLbl.text = reply.message
            
        }
        else {
            usernameInLbl.text = reply.username
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, hh:mm"
            let timestamp = formatter.string(from: reply.timestamp)
            
            timestampInLbl.text = timestamp
            
            messageInLbl.text = reply.message
        }
    }
}
