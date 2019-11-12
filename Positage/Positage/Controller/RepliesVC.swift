//
//  RepliesVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/11/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class RepliesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {


    //Outlets
    @IBOutlet weak var repliesTableView: UITableView!
    @IBOutlet weak var sendReplyTxt: UITextField!
    @IBOutlet weak var sendReplyView: UIView!
    
    //Variables
    var post: Post!
    var replies: [Reply] = []
    var replyListener: ListenerRegistration!
    var replyCollectionReference: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repliesTableView.delegate = self
        repliesTableView.dataSource = self
        
        repliesTableView.estimatedRowHeight = 80
        repliesTableView.rowHeight = UITableView.automaticDimension
        
        //UI
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: sendReplyTxt.frame.height))
        sendReplyTxt.leftView = paddingView
        sendReplyTxt.leftViewMode = UITextField.ViewMode.always
        
        sendReplyView.layer.cornerRadius = 20
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        replyCollectionReference = Firestore.firestore().collection(POST_REF).document(post.documentId).collection(REPLIES_REF)
        configureReplyListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if replyListener != nil {
            replyListener.remove()
        }
    }
    
    
    func configureReplyListener () {
        replyListener = replyCollectionReference.order(by: TIMESTAMP, descending: false).addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint("Error catching replies:\(error.localizedDescription)")
            }
            else{
                self.replies.removeAll()
                self.replies = Reply.setReply(from: snapshot)
                
                self.repliesTableView.reloadData()
                
                self.repliesTableViewScrollToBottom()
                
            }
        })
    }
    
    func repliesTableViewScrollToBottom(){
        DispatchQueue.main.async {
            if self.replies.count != 0 {
                let indexPath = IndexPath(row: self.replies.count - 1, section: 0)
                self.repliesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                self.repliesTableView.backgroundView = nil
            }
            else{
                self.repliesTableView.setEmptyTableViewMessage(message: "This post has not been replied to yet.")
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        if let data = sendReplyTxt.text{
            replyCollectionReference.addDocument(data: [
                MESSAGE : data,
                FROM_USERID : user.uid,
                FROM_USERNAME: user.displayName,
                TIMESTAMP : FieldValue.serverTimestamp()
                ])
            
            self.sendReplyTxt.text = String()
        }
        else {
            print("Reply Text is nil")
        }
        view.endEditing(true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let user = Auth.auth().currentUser else { return UITableViewCell() }
        if replies[indexPath.row].userId == user.uid {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "outgoingCell") as? ReplyTableViewCell {
                cell.configureCell(reply: replies[indexPath.row])
                return cell
            }
            else {
                return UITableViewCell()
            }
        }
        else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "incomingCell") as? ReplyTableViewCell {
                cell.configureCell(reply: replies[indexPath.row])
                return cell
            }
            else{
                return UITableViewCell()
            }
        }
    }

}
