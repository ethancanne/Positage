//
//  TrackDetailsVCViewController.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/2/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class TrackDetailsVC: UIViewController{
    
    //Variables
    var post: Post!
    var replies: [Reply] = []
    var replyListener: ListenerRegistration!
    var replyCollectionReference: CollectionReference!
    var postListener: ListenerRegistration!
    var postDocumentReference: DocumentReference!
    var seeMoreIsOpened: Bool = false
    
    
    //Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var seeMoreBtn: UIButton!
    @IBOutlet weak var postDataTxtViewHeightCnstr: NSLayoutConstraint!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var toUsernameLbl: UILabel!
    @IBOutlet weak var postDataTxt: UITextView!
    @IBOutlet weak var viewedImg: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        postDocumentReference = Firestore.firestore().collection(POST_REF).document(post.documentId)
        replyCollectionReference = Firestore.firestore().collection(POST_REF).document(post.documentId).collection(REPLIES_REF)
        
        view.bindToKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleLbl.text = post.title
        toUsernameLbl.text = post.toUsername
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: post.timestamp)
        timestampLbl.text = timestamp
        
        postDataTxt.text = post.data
        
        configurePostListener()
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if replyListener != nil {
            replyListener.remove()
        }
        if postListener != nil {
            postListener.remove()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
    }

    func configurePostListener () {
        postListener = postDocumentReference.addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint("Error catching replies:\(error.localizedDescription)")
            }
            else{
                guard let document = snapshot?.data() else { return }
                self.postDataTxt.text = document[DATA] as? String
                self.titleLbl.text = "Tracking: \(document[TITLE] as? String ?? "Post")"

//                if let didView = document[DID_VIEW] as? Bool {
//                    if didView {
//                        self.viewedImg.image = UIImage(named: "ViewedIcon")
//                    }
//                    else{
//                        self.viewedImg.image = UIImage(named: "NotViewedIcon")
//                    }
//                }
//                else {
//                    debugPrint("Error unwrapping DidView Object for this Post")
//                }
                
            }
        })
    }
    
    
    //Actions
    @IBAction func seeMoreBtnPressed(_ sender: Any) {
        if !seeMoreIsOpened {
            UIView.animate(withDuration: 1.1, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                self.postDataTxtViewHeightCnstr.constant += 100
                self.seeMoreBtn.transform = self.seeMoreBtn.transform.rotated(by: CGFloat((3 * Double.pi) / 2))
                self.view.layoutIfNeeded()
            }, completion: nil)
            seeMoreIsOpened = true
        }
        else{
            UIView.animate(withDuration: 1.1, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                self.postDataTxtViewHeightCnstr.constant -= 100
                self.seeMoreBtn.transform = self.seeMoreBtn.transform.rotated(by: CGFloat(Double.pi / 2))
                self.view.layoutIfNeeded()
            }, completion: nil)
            seeMoreIsOpened = false
        }
        

    }
    
    
    @IBAction func backTapped (_ sender: Any ) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRepliesVC"{
            if let repliesVC = segue.destination as? RepliesVC {
                repliesVC.post = post
            }
        }
        
    }
        
    
}
