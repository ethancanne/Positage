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
    @IBOutlet weak var outboxBtn: UIButton!
    
    override func viewDidLoad() {
        view.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 20
        view.layer.shadowOpacity = 0.3
        
        
    }
    
    func updateTabBar(){
        switch AppLocation.currentTabBarVC.selectedIndex{
        case 0:
            //Set Font
            inboxBtn.titleLabel?.font = UIFont(name: "Cambria-Bold", size: 20)
            outboxBtn.titleLabel?.font = UIFont(name: "Cambria", size: 20)
            communityBtn.titleLabel?.font = UIFont(name: "Cambria", size: 20)
            break
        case 1:
            //Set Font
            inboxBtn.titleLabel?.font = UIFont(name: "Cambria", size: 20)
             outboxBtn.titleLabel?.font = UIFont(name: "Cambria-Bold", size: 20)
            communityBtn.titleLabel?.font = UIFont(name: "Cambria", size: 20)
            
            break
        case 2:
            //Set Font
            inboxBtn.titleLabel?.font = UIFont(name: "Cambria", size: 20)
            outboxBtn.titleLabel?.font = UIFont(name: "Cambria", size: 20)
            communityBtn.titleLabel?.font = UIFont(name: "Cambria-Bold", size: 20)
            
            break
        default:
            print("Tab Bar Controller did not fall in one of the expected indicies")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        updateTabBar()
    }
        
    @IBAction func InboxTapped(_ sender: Any) {
        //Change View
        AppLocation.currentTabBarVC.selectedIndex = 0
        updateTabBar()
    }
    
    @IBAction func OutboxTapped(_ sender: Any) {
        //Change View
        AppLocation.currentTabBarVC.selectedIndex = 1
        updateTabBar()
    }
    
    @IBAction func CommunityTapped(_ sender: Any) {
        //Change View
        AppLocation.currentTabBarVC.selectedIndex = 2
        updateTabBar()

    }
    
}
