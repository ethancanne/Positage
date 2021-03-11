//
//  ConversationDetailsVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/5/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase


class ConversationDetailsVC: UIViewController{
    
    //Outlets
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var usernameLbl: UILabel!
    @IBOutlet private weak var timestampLbl: UILabel!
    @IBOutlet private weak var messageTxtView: UITextView!
    @IBOutlet weak var stampsGivenNumLbl: UILabel!
    
    
    
    //Variables
    var post: Post!
        
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        titleLbl.text = post.title
        messageTxtView.text = post.message
        usernameLbl.text = post.fromUsername
        stampsGivenNumLbl.text = String(post.numStampsGiven)
        
        timestampLbl.text = "\(post.timestamp)"
        
        if post.didRead == false {
            Firestore.firestore().document("\(POST_REF)/\(post.documentId)").updateData([DID_READ : true])
        }
    }
    
    

}

