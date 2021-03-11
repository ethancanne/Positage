//
//  OutboxTBViewCell.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/8/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit


class OutboxTBViewCell: UITableViewCell{
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var toLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusView: PositageView!

    @IBOutlet weak var numUnreadView: PositageView!
    @IBOutlet weak var numUnreadLbl: UILabel!
    
    @IBOutlet weak var detailsContentView: PositageView!
    @IBOutlet weak var detailsViewHeightCnstr: NSLayoutConstraint!
    
    var post: Post!
    func configure(post: Post){
        titleLbl.text = post.title
        toLbl.text = post.toUsername
        statusLbl.text = post.didRead ? "READ" : "UNREAD"
        statusView.backgroundColor = post.didRead ?  #colorLiteral(red: 0.399692744, green: 0.4569146037, blue: 0.5956661105, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        self.post = post
        
        if post is OngoingPost{
            //for numUnread
            let ongoingPost = post as! OngoingPost
            let numUnread: Int = ongoingPost.numSenderUnreadMessages

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
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: post.timestamp)
        timestampLbl.text = timestamp

        
    }
    
    var isDetailsExpanded: Bool = false
    func toggleDetails() -> Bool{
        if !isDetailsExpanded {
            
            var detailsView: UIView!
            detailsView = DetailsVC.getDetailsView(with: post)
            
            detailsView.frame = detailsContentView.frame
            detailsView.translatesAutoresizingMaskIntoConstraints = false
            self.detailsContentView.addSubview(detailsView)

            NSLayoutConstraint.activate([
                detailsView.leadingAnchor.constraint(equalTo: self.detailsContentView.leadingAnchor, constant: 0),
                detailsView.trailingAnchor.constraint(equalTo: self.detailsContentView.trailingAnchor, constant: 0),
                detailsView.topAnchor.constraint(equalTo: self.detailsContentView.topAnchor, constant: 0),
                detailsView.bottomAnchor.constraint(equalTo: self.detailsContentView.bottomAnchor, constant: 0),
            ])
            
            self.layoutIfNeeded()

            detailsViewHeightCnstr.constant += ((getCurrentViewController()?.view.frame.height)! / 2)
        
            isDetailsExpanded = true
            
            return true
        }
        else{//Collapse details
            detailsViewHeightCnstr.constant -= ((getCurrentViewController()?.view.frame.height)! / 2)
            isDetailsExpanded = false
            detailsContentView.subviews[0].removeFromSuperview()
            return false
        }
        
    }
    
}


