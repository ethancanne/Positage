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

    @IBOutlet weak var communityView: UIView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var postDataLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var numStampsLbl: UILabel!
    @IBOutlet weak var addStampImgBtn: UIImageView!
    @IBOutlet weak var addStampStackView: UIStackView!
    @IBOutlet weak var communityViewTrailCnstr: NSLayoutConstraint!
    @IBOutlet weak var promotedLbl: UILabel!
    
    //Variables
    private var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let addStampTap = UITapGestureRecognizer(target: self, action: #selector(addStampBtnTapped))
    
        addStampImgBtn.addGestureRecognizer(addStampTap)
        addStampImgBtn.isUserInteractionEnabled = true
        
        communityView.layer.cornerRadius = 9
        communityView.clipsToBounds = true
        
    }

    
    @objc func addStampBtnTapped(){
        print("addStampBtn has been Tapped")
        
        let firestore = Firestore.firestore()
    
        
        if DataService.instance.currentUserNumStamps! >= 1{
            
            firestore.runTransaction({ (transaction, error) -> Any? in
                let fromUserDocument: DocumentSnapshot
                let fromUserId = self.post.fromUserId
                guard let currentUser = Auth.auth().currentUser else { return nil }
                
                do {
                    try fromUserDocument = transaction.getDocument(firestore.collection(USERS_REF).document(fromUserId))
                }
                catch let error as NSError {
                    debugPrint("Error reading User Document:\(error.localizedDescription)")
                    return nil
                }
                
                guard let fromUserOldNumStamps = fromUserDocument.data()?[NUM_STAMPS] as? Int else { return nil }
                guard let currentUserOldNumStamps = DataService.instance.currentUserNumStamps else { return nil }
                
                transaction.updateData([NUM_STAMPS : fromUserOldNumStamps + 1], forDocument: firestore.document("\(USERS_REF)/\(fromUserId)"))
                
                transaction.updateData([NUM_STAMPS : self.post.numStamps + 1], forDocument: firestore.document("\(POST_REF)/\(self.post.documentId)"))
                
                transaction.updateData([NUM_STAMPS :  currentUserOldNumStamps - 1], forDocument: firestore.document("\(USERS_REF)/\(currentUser.uid)"))
                
                
                return nil
            }) { (object, error) in
                if let error = error {
                    debugPrint("Error fetching User Document:\(error.localizedDescription)")
                }
            }
        }
        else {
            print("User has an insignificant number of stamps:\(DataService.instance.currentUserNumStamps)")
        }
        
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
        usernameLbl.text = "\(post.fromUsername)"
        numStampsLbl.text = "\(String(post.numStamps)) Stamps"
        
        if post.isPromoted {
            communityView.backgroundColor = #colorLiteral(red: 0.8861480355, green: 0.9316738248, blue: 0.9467076659, alpha: 1)
            promotedLbl.isHidden = false
        }
        else{
            communityView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        if post.fromUserId != Auth.auth().currentUser?.uid {
            addStampImgBtn.isHidden = false
        }
        else {
            addStampImgBtn.isHidden = true
        }
            

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: post.timestamp)
        timestampLbl.text = timestamp
    }

}
