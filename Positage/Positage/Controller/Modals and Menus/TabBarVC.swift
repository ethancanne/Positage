//
//  TabBarVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 11/27/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit

class TabBarVC: UIViewController {

    
    @IBOutlet weak var inboxBtn: UIButton!
    @IBOutlet weak var communityBtn: UIButton!
    @IBOutlet weak var conversationsBtn: UIButton!
    
    override func viewDidLoad() {
        view.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 20
        view.layer.shadowOpacity = 0.3
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        switch tabBarController?.selectedIndex {
        case 0:
            //Set Font
            inboxBtn.titleLabel?.font = UIFont(name: "Cambria", size: 20)
        inboxBtn.setTitleColor(UIColor.black, for: .normal)
            communityBtn.titleLabel?.font = UIFont(name: "Cambria Math", size: 20)
            conversationsBtn.titleLabel?.font = UIFont(name: "Cambria Math", size: 20)
            break
        case 1:
            //Set Font
            inboxBtn.titleLabel?.font = UIFont(name: "Cambria Math", size: 20)
            communityBtn.titleLabel?.font = UIFont(name: "Cambria", size: 20)
            communityBtn.setTitleColor(UIColor.black, for: .normal)
            conversationsBtn.titleLabel?.font = UIFont(name: "Cambria Math", size: 20)
            break
        case 2:
            //Set Font
            inboxBtn.titleLabel?.font = UIFont(name: "Cambria Math", size: 20)
            communityBtn.titleLabel?.font = UIFont(name: "Cambria Math", size: 20)
            conversationsBtn.titleLabel?.font = UIFont(name: "Cambria", size: 20)
            conversationsBtn.setTitleColor(UIColor.black, for: .normal)
            
            break
        default:
            print("Tab Bar Controller did not fall in one of the expected indicies")
        }
    }
        
    @IBAction func InboxTapped(_ sender: Any) {
        //Change View
        tabBarController?.selectedIndex = 0
        
        
        
        
    }
    
    @IBAction func CommunityTapped(_ sender: Any) {
        //Change View
        tabBarController?.selectedIndex = 1
        
        
        
        

    }
    @IBAction func ConversationsTapped(_ sender: Any) {
        //Change View
        tabBarController?.selectedIndex = 2
        
        

    }
}
