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

    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var postDataLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var numStampsLbl: UILabel!
    @IBOutlet weak var addStampImgBtn: UIImageView!
    
    private var post: Post!
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(addStampBtnTapped))
        addStampImgBtn.addGestureRecognizer(tap)
        addStampImgBtn.isUserInteractionEnabled = true
    }

    
    @objc func addStampBtnTapped(){
        print("addStampBtn has been Tapped")
        Firestore.firestore().document("\(POST_REF)/\(post.documentId)")
            .updateData([POST_NUM_STAMPS : post.numStamps + 1])
        
        UIView.animate(withDuration: 0.5, animations: {
            self.numStampsLbl.alpha = 0.5
        })
        { (worked) in
            UIView.animate(withDuration: 0.3, animations: {
                self.numStampsLbl.alpha = 1
            })
        }
        
    }
    
    func ConfigureCell(post: Post){
        self.post = post
        titleLbl.text = post.title
        postDataLbl.text = post.data
        usernameLbl.text = "\(post.fromUserId)"
        numStampsLbl.text = "\(String(post.numStamps)) Stamps"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: post.timestamp.dateValue())
        timestampLbl.text = timestamp
    }

}
