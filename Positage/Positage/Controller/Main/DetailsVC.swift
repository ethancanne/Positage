//
//  DetailsVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/27/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase


class DetailsVC: UIViewController{
    
    //Outlets
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var fromUserLbl: UILabel!
    @IBOutlet private weak var timestampLbl: UILabel!
    @IBOutlet private weak var dataTxtView: PositageTextView!
    @IBOutlet weak var stampsNumLbl: UILabel!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var dataViewBtmCnstr: NSLayoutConstraint!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var optionsView: UIView!
    
    //Reply Outlets
    @IBOutlet public var replyView: UIView!
    
    
    //Variables
    var post: Post!
    var replies: [Reply] = []
    var replyListener: ListenerRegistration!
    var replyCollectionRef: CollectionReference!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI
        
        view.bindToKeyboard()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        titleLbl.text = post.title
        dataTxtView.text = post.data
        fromUserLbl.text = post.fromUsername
        stampsNumLbl.text = String(post.numStamps)
        replyBtn.isEnabled = false
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: post.timestamp)
        timestampLbl.text = timestamp
        
        if post.allowsTracking {
            replyBtn.isEnabled = true
            if post.didView == false {
                Firestore.firestore().document("\(POST_REF)/\(post.documentId)").updateData([DID_VIEW : true])
            }
        }
        
    }
    
    
    //Actions
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    let yValue: Int? = nil
    let replyHeight: CGFloat? = nil
    
    @IBAction func replyTapped(_ sender: Any) {
        replyView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 352)
        view.addSubview(replyView)
        
        view.bringSubviewToFront(dataTxtView)

        let replyHeight: CGFloat = 352
        let yValue = (view.frame.height - replyHeight)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
            self.optionsView.alpha = 1
            self.replyView.frame = CGRect(x: 0, y: yValue, width: self.replyView.frame.width, height: self.replyView.frame.height)
            
        }, completion: nil)
        
        UIView.animate(withDuration: 1.1, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
            self.dataViewBtmCnstr.constant += self.replyView.frame.height - self.optionsView.frame.height
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        self.dataTxtView.textContainer.maximumNumberOfLines = 1
        self.dataTxtView.textContainer.lineBreakMode = .byTruncatingTail

        
    }
    
    @IBAction func dismissReplyViewTapped(_ sender: Any) {
        UIView.animate(withDuration: 1, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
            self.optionsView.alpha = 1
            self.replyView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.replyView.frame.width, height: self.replyView.frame.height)
        }, completion: nil)
        
        UIView.animate(withDuration: 1.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
            self.dataViewBtmCnstr.constant -= self.replyView.frame.height - self.optionsView.frame.height
            self.view.layoutIfNeeded()
        }, completion: { worked in
            self.dataTxtView.textContainer.maximumNumberOfLines = 0
            self.dataTxtView.textContainer.lineBreakMode = .byWordWrapping
            
        })
        
        

    }
    
    @IBAction func deleteTapped (_ sender: Any) {
        let alert = UIAlertController(title: "Delete?", message: "Are you sure you want to delete this post? \(post.title)", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alert) in
            Firestore.firestore().collection(POST_REF).document(self.post.documentId).delete(completion: { (error) in
                if let error = error {
                    debugPrint("Error deleting document:\(error.localizedDescription)")
                }
                else {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRepliesVC"{
            if let repliesVC = segue.destination as? RepliesVC {
                repliesVC.post = post
            }
        }
        
    }
    

    
    
    
    
}
