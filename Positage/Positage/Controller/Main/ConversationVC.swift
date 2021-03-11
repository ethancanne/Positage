//
//  OngoingPostVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/7/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class OngoingPostTBViewCell: UITableViewCell{
    
    @IBOutlet weak var msgTxtView: UITextView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    
    func config(reply: Reply){
        usernameLbl.text = reply.username
        msgTxtView.text = reply.message
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: reply.timestamp)
        timestampLbl.text = timestamp
    }
    
}

class OngoingPostVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}

class OngoingPostView: PositageView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var expandBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var msgViewHeightCnstr: NSLayoutConstraint!
    
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var msgTxt: PositageTextField!
    
    var replies: [Reply] = []
    var replyListener: ListenerRegistration!
    var post: Post!
    var UNREAD_REPLY_CONSTANT: String!
    
    
    override func didMoveToSuperview() {
        configureListener()
        messageTxtView.text = post.message

        //Table View
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 124
        tableView.rowHeight = UITableView.automaticDimension
        tableView.startFromBtm()
        
        //Customize this PositageView
        self.cornerRadius = 16
        self.maskedCorners = "3"
        
        self.CustomizeView()
        
        //reset numread for appropriate user (who HAS unread replies)
        UNREAD_REPLY_CONSTANT = (DataService.currentUser?.userId == post.fromUserId) ? NUM_RECIPIENT_UNREAD_REPLIES : NUM_SENDER_UNREAD_REPLIES
       
            //Reverse UNREAD_REPLY_CONSTANT because we are resetting the unready replies of the user who opens the message, not the other user.
        DataService.database.collection(POST_REF).document(self.post.documentId).updateData([
            ((UNREAD_REPLY_CONSTANT == NUM_RECIPIENT_UNREAD_REPLIES) ? NUM_SENDER_UNREAD_REPLIES : NUM_RECIPIENT_UNREAD_REPLIES): 0,
            ], completion: {(error) in
                if let error = error {
                    debugPrint("Error :\(error.localizedDescription)")
                }
        })
    }
    
    func configureListener () {
        replyListener = DataService.database.collection("\(POST_REF)/\(post.documentId)/\(REPLIES_REF)").order(by: TIMESTAMP, descending: false).addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint("Error catching replies:\(error.localizedDescription)")
            }
            else{
                self.replies.removeAll()
                self.replies = Reply.setReply(from: snapshot)
                
                self.tableView.reloadData()
                self.tableView.scrollToBtm()
            }
        })
    }
    
    var isMsgExpanded = false
    @IBAction func expandBtnTapped(_ sender: Any) {
        if !isMsgExpanded { //Expand Msg
            msgViewHeightCnstr.constant += (self.frame.height / 3)
            isMsgExpanded = true
            
        }
        else{//Collapse Msg
            msgViewHeightCnstr.constant -= (self.frame.height / 3)
            isMsgExpanded = false
        }
        
        //perform animations
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
            if !self.isMsgExpanded{ //flip arrow for expanding
                self.expandBtn.transform = CGAffineTransform(rotationAngle: 2*(CGFloat.pi))
            }else { //flip arrow for collapsing
                self.expandBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
            
            self.layoutIfNeeded()
        }, completion: nil)
        
        
    }
    
    
    @IBAction func sendBtnTapped(_ sender: Any) {
        if let messageTxt = msgTxt.text, let user = DataService.currentUser{
            let message = Reply(username: user.username, timestamp: Date(), message: messageTxt, userId: user.userId)
            
            
            DataService.database.runTransaction({ (transaction, err) -> Any? in
                transaction.setData(message.toDictionary(), forDocument: DataService.database.collection("\(POST_REF)/\(self.post.documentId)/\(REPLIES_REF)").document())
                    
                transaction.updateData([self.UNREAD_REPLY_CONSTANT: FieldValue.increment(1.0)], forDocument: DataService.database.collection(POST_REF).document(self.post.documentId))
                
                return message
                
            }) { (object, err) in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    self.msgTxt.text = ""
                }
            }
    
        }
        
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if replies[indexPath.row].userId == DataService.currentUser?.userId{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "outgoingCell") as? OngoingPostTBViewCell {
                cell.config(reply: replies[indexPath.row])
                return cell
            }
        }else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "incomingCell") as? OngoingPostTBViewCell {
                cell.config(reply: replies[indexPath.row])
                
                return cell
            }
            
        }
        
        
        return UITableViewCell()
    }
    
}
