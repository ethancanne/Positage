//
//  InboxTableViewCell.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/23/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit

class InboxTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var postDataLbl: UILabel!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var stampsLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func ConfigureCell(post: Post){
        titleLbl.text = post.title
        fromLbl.text = "from: \(post.fromUserId)"
        stampsLbl.text = "\(String(post.numStamps)) Stamps"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: post.timestamp.dateValue())
        dateLbl.text = timestamp

    }

}
