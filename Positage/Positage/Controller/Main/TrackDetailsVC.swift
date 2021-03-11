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
    var ongoingPost: OngoingPost!
    var replies: [Reply] = []
    var replyListener: ListenerRegistration!
    var replyCollectionReference: CollectionReference!
    var ongoingPostListener: ListenerRegistration!
    var ongoingPostDocumentRef: DocumentReference!
    var seeMoreIsOpened: Bool = false
    
    
    //Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var seeMoreBtn: UIButton!
    @IBOutlet weak var postDataTxtViewHeightCnstr: NSLayoutConstraint!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var toUsernameLbl: UILabel!
    @IBOutlet weak var postDataTxt: UITextView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ongoingPostDocumentRef = Firestore.firestore().collection(ONGOING_POST_REF).document(ongoingPost.documentId)
        replyCollectionReference = Firestore.firestore().collection("CONVERSATIONS").document(ongoingPost.documentId).collection(REPLIES_REF)
        
        view.bindToKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleLbl.text = ongoingPost.title
        toUsernameLbl.text = ongoingPost.toUsername
        
        timestampLbl.text = "\(ongoingPost.timestamp)"
        
        postDataTxt.text = ongoingPost.message
        
        configurePostListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if replyListener != nil {
            replyListener.remove()
        }
        if ongoingPostListener != nil {
            ongoingPostListener.remove()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func configurePostListener () {
        ongoingPostListener = ongoingPostDocumentRef.addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint("Error catching replies:\(error.localizedDescription)")
            }
            else{
                guard let document = snapshot?.data() else { return }
                self.postDataTxt.text = document[MESSAGE] as? String
                self.titleLbl.text = "Tracking: \(document[TITLE] as? String ?? "Post")"
                
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

    
}
