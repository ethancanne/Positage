//
//  TrackTableViewCell.swift
//  Positage
//
//  Created by Ethan Cannelongo on 1/28/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var toUsernameLbl: UILabel!
    @IBOutlet weak var didViewImg: UIImageView!
    @IBOutlet weak var numRepliesLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func ConfigureCell(post: Post) {
        titleLbl.text = post.title
        toUsernameLbl.text = post.toUsername
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: post.timestamp)
        timestampLbl.text = timestamp
        
        didViewImg.image = post.didView == true ? UIImage(named: "ViewedIcon") : UIImage(named: "NotViewedIcon")
        
        numRepliesLbl.text = "\(String(post.numReplies)) Replies"
        
    }

}
