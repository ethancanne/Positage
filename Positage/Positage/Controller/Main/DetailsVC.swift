//
//  DetailsVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/27/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase


class DetailsVC: UIViewController, ChooseUserDelegate{
    
    //Outlets
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var usernameLbl: UILabel!
    @IBOutlet private weak var timestampLbl: UILabel!
    @IBOutlet weak var stampsGivenNumLbl: UILabel!
    @IBOutlet weak var stampsGivenView: PositageView!
    @IBOutlet weak var claimBtn: PositageButton!
    
    @IBOutlet weak var contentView: PositageView!
    
    //Variables
    var post: Post!
    
    override func viewWillAppear(_ animated: Bool) {
        
        if post.didRead == false {
            DataService.database.document("\(POST_REF)/\(post.documentId)").updateData([DID_READ : true])
        }
        
        
        AppLocation.currentMenuVC.toggleTabBar()
        
        AppLocation.currentUserLocation = "Details"
        AppLocation.locationHidden = false
        titleLbl.text = post.title
        usernameLbl.text = post.fromUsername
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: post.timestamp)
        timestampLbl.text = timestamp
        
        stampsGivenNumLbl.text = String(post.numStampsGiven)
        
        if post.numStampsGiven != 0 {
            stampsGivenView.alpha = 1
        }else{
            stampsGivenView.alpha = 0
        }
        
        loadContentView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !(AppLocation.currentMenuVC.isMenuOpen) || AppLocation.currentMenuVC.isSearching{
            AppLocation.currentMenuVC.toggleTabBar()
        }
    }
    
    static func getDetailsView(with post: Post) -> UIView {
        //Expand details
        
        if post is OngoingPost {
            let ongoingPostVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "ongoingPostVC") as! OngoingPostVC
            
            let ongoingPostView = ongoingPostVC.view as! OngoingPostView
            ongoingPostView.post = post
            
            return ongoingPostView
            
        }else{
            let postMsgVC = instantiateViewController(fromStoryboard: "Main", withIdentifier: "postMsgVC") as! PostMsgVC
            let postMsgView = postMsgVC.view as! PostMsgView
            
            postMsgView.post = post
            return postMsgView
        }
    }
    
    func loadContentView(){
        var detailsView: UIView!
        detailsView = DetailsVC.getDetailsView(with: post)
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(detailsView)
        
        NSLayoutConstraint.activate([
            detailsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            detailsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            detailsView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            detailsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
        ])
        
        
        
        
    }
    @IBAction func claimStampsGivenBtnTapped(_ sender: Any) {
        
        if let user = DataService.currentUser {
            
            DataService.database.runTransaction({ (transaction, err) -> Any? in
                transaction.updateData([NUM_STAMPS_GIVEN: 0], forDocument: DataService.database.collection(POST_REF).document(self.post.documentId))
                
                transaction.updateData([NUM_STAMPS: FieldValue.increment(Double((self.post.numStampsGiven)))], forDocument: DataService.database.collection(USERS_REF).document((user.userId)))
                
                return nil
                
            }) { (object, err) in
                if let err = err {
                    print("Error claiming stamps: \(err)")
                } else {
                    print("Stamps successfully claimed!")
                    self.claimBtn.isEnabled = false
                    self.claimBtn.setTitle("CLAIMED", for: .normal)
                }
            }
        }
    }
    @IBAction func deleteBtnTapped(_ sender: Any) {
        
        //TODO: modify actionsheet
        let alert = UIAlertController(title: "Delete?", message: "Are you sure you want to delete this post? \(post.title)", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alert) in
            DataService.database.collection(POST_REF).document(self.post.documentId).delete(completion: { (error) in
                if let error = error {
                    debugPrint("Error deleting document:\(error.localizedDescription)")
                }
                else{
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func transferBtnTapped(_ sender: Any) {
        PopupVC.showChooseUserPopup(from: self, allowMultiple: false)
    }
    
    @IBAction func screenWasSwiped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func didChooseUsers(users: [User]) {
        let user = users[0]
        print(user.username)
        //Get this post and update its toUserID and ToUsername to the selected user
        DataService.database.collection(POST_REF).document(post.documentId).updateData(
            [
                TO_USERID : user.userId,
                TO_USERNAME : user.username
        ]) { (err) in
            if let err = err {
                print("ERROR - TODO: Make this a better message to the user - " + err.localizedDescription)
            }else{
                print("post transfered from\(self.post.fromUsername) to \(user.username)")
            }
        }
        //Go back
        navigationController?.popViewController(animated: true)
        
    }
    
}































//Actions
//    @IBAction func backPressed(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    let yValue: Int? = nil
//    let replyHeight: CGFloat? = nil
//
//    @IBAction func replyTapped(_ sender: Any) {
//        replyView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 352)
//        view.addSubview(replyView)
//
//        view.bringSubviewToFront(dataTxtView)
//
//        let replyHeight: CGFloat = 352
//        let yValue = (view.frame.height - replyHeight)
//
//        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
//            self.optionsView.alpha = 1
//            self.replyView.frame = CGRect(x: 0, y: yValue, width: self.replyView.frame.width, height: self.replyView.frame.height)
//
//        }, completion: nil)
//
//        UIView.animate(withDuration: 1.1, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
//            self.dataViewBtmCnstr.constant += self.replyView.frame.height - self.optionsView.frame.height
//            self.view.layoutIfNeeded()
//        }, completion: nil)
//
//        self.dataTxtView.textContainer.maximumNumberOfLines = 1
//        self.dataTxtView.textContainer.lineBreakMode = .byTruncatingTail
//
//
//    }
//
//    @IBAction func dismissReplyViewTapped(_ sender: Any) {
//        UIView.animate(withDuration: 1, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
//            self.optionsView.alpha = 1
//            self.replyView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.replyView.frame.width, height: self.replyView.frame.height)
//        }, completion: nil)
//
//        UIView.animate(withDuration: 1.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
//            self.dataViewBtmCnstr.constant -= self.replyView.frame.height - self.optionsView.frame.height
//            self.view.layoutIfNeeded()
//        }, completion: { worked in
//            self.dataTxtView.textContainer.maximumNumberOfLines = 0
//            self.dataTxtView.textContainer.lineBreakMode = .byWordWrapping
//
//        })
//
//
//
//    }
//
//    @IBAction func deleteTapped (_ sender: Any) {
//        let alert = UIAlertController(title: "Delete?", message: "Are you sure you want to delete this post? \(post.title)", preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alert) in
//            Firestore.firestore().collection(POST_REF).document(self.post.documentId).delete(completion: { (error) in
//                if let error = error {
//                    debugPrint("Error deleting document:\(error.localizedDescription)")
//                }
//                else {
//                    self.dismiss(animated: true, completion: nil)
//                }
//            })
//        }))
//        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//
//        present(alert, animated: true, completion: nil)
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toRepliesVC"{
//            if let repliesVC = segue.destination as? RepliesVC {
//                repliesVC.post = post
//            }
//        }
//
//    }







