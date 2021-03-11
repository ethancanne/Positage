//
//  PostMsgVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/7/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit

class PostMsgVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class PostMsgView: PositageView{
    var post: Post!
    
    @IBOutlet weak var msgTxtView: UITextView!
    
    override func didMoveToSuperview() {
        msgTxtView.text = post.message
        
        //Customize this PositageView
        self.cornerRadius = 16
        self.maskedCorners = "3"
        
        self.CustomizeView()
    }
    
    
}
