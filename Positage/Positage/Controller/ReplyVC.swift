////
////  ReplyVC.swift
////  Positage
////
////  Created by Ethan Cannelongo on 1/20/19.
////  Copyright © 2019 Ethan Cannelongo. All rights reserved.
////
//
//import UIKit
//import Firebase
//
//class ReplyVC: UIViewController, UITextViewDelegate {
//
//    //Outlets
//    @IBOutlet weak var toUsernameLbl: UILabel!
//    @IBOutlet weak var postTitleLbl: UILabel!
//    @IBOutlet weak var postDataTxtView: UITextView!
//    @IBOutlet weak var replyTitleTxt: UITextField!
//    @IBOutlet weak var replyDataTxtView: PositageTextView!
//    @IBOutlet weak var numStampsLbl: UILabel!
//    @IBOutlet weak var sendBtn: UIButton!
//
//    //Variables
//    var post: Post!
//    var surcharge: Int = 0
//    var toUserId: String!
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        toUsernameLbl.text = "Reply to \(post.fromUsername)"
//        postTitleLbl.text = post.title
//        postDataTxtView.text = post.data
//        replyDataTxtView.delegate = self
//    }
//
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        textView.text = String()
//        textView.textColor = UIColor.darkGray
//    }
//
//    func textViewDidChange(_ textView: UITextView) {
//        replyDataTxtView.layoutIfNeeded()
//        var wordsInTxtData = [String]()
//        wordsInTxtData = replyDataTxtView.text.components(separatedBy: " ")
//
//        if wordsInTxtData.count >= 50{
//            if wordsInTxtData.count <= 100 {
//                surcharge = 1
//            }
//            else{
//                surcharge = 2
//            }
//
//        }
//        else {
//            surcharge = 0
//        }
//        numStampsLbl.text = String(surcharge)
//    }
//
//    @IBAction func backBtnTapped(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func sendBtn(_ sender: Any) {
//        guard let currentUserNumStamps = DataService.instance.currentUserNumStamps,
//                let replyDataTxt = replyDataTxtView.text else { return }
//
//        if currentUserNumStamps >= surcharge {
//            Firestore.firestore().runTransaction({ (transaction, error) -> Any? in
//                let postDocument: DocumentSnapshot
//
//                do {
//                    try postDocument = transaction.getDocument(Firestore.firestore().document("\(POST_REF)/\(self.post.documentId)"))
//                }
//                catch let error as NSError {
//                    debugPrint("Error reading User Document:\(error.localizedDescription)")
//                    return nil
//                }
//
//                guard let postOldNumReplies = postDocument.data()?[NUM_REPLIES] as? Int else { return nil }
//                guard let user = Auth.auth().currentUser else { return nil }
//
//                transaction.updateData([NUM_REPLIES : postOldNumReplies + 1], forDocument: Firestore.firestore().collection(POST_REF).document(self.post.documentId))
//
//                transaction.updateData([NUM_STAMPS : currentUserNumStamps - self.surcharge], forDocument: Firestore.firestore().collection(USERS_REF).document(user.uid))
//
//                transaction.setData([
//                    MESSAGE : replyDataTxt,
//                    FROM_USERID : user.uid,
//                    FROM_USERNAME: user.displayName,
//                    TIMESTAMP : FieldValue.serverTimestamp()
//                    ], forDocument: Firestore.firestore().collection(POST_REF).document(self.post.documentId).collection(REPLIES_REF).document())
//
//                return nil
//            }) { (object, error) in
//                if let error = error {
//                    debugPrint("Error creating reply:\(error.localizedDescription)")
//                }
//                else {
//                    self.dismiss(animated: true, completion: nil)
//                }
//
//            }
//        }
//        else {
//            print("User has an insignificant number of stamps. \(surcharge - currentUserNumStamps) more stamp(s) is/are needed to send this post.")
//            //Present alert
//            let alertView = UIAlertController(title: "Insignificant number of stamps.", message: "\(surcharge - currentUserNumStamps) more stamp(s) is/are needed to send this post.", preferredStyle: .actionSheet)
//            let action = UIAlertAction(title: "OK", style: .default)
//            alertView.addAction(action)
//            self.present(alertView, animated: true, completion: nil)
//        }
//    }
//
//
//
//}
