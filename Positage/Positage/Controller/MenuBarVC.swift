//
//  MenuBarVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 11/28/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit

class MenuBarVC: UIViewController {

    private var locationName: String!
    private var currentVC: UIViewController!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var usernameLeadingCnstr: NSLayoutConstraint!
    @IBOutlet weak var menuBtn: UIButton!
    
    override func viewDidLoad() {
        if tabBarController != nil {
            usernameLeadingCnstr.constant = 9
            view.layoutIfNeeded()
            backBtn.isHidden = true
        }
        locationLbl.text = locationName
    }
    
    @IBAction func menuBtnTapped(_ sender: Any) {
        showMenu()
    }
    
    func setLocationName(name: String){
        locationName = name
    }
    
    func setParentVC(viewController: UIViewController){
        self.currentVC = viewController
    }
    
    func showMenu(){
        let menuView: UIView = MenuView.createView()
        currentVC.view.addSubview(menuView)
        menuView.translatesAutoresizingMaskIntoConstraints = false
        let menuViewTopCnstr = menuView.topAnchor.constraint(equalTo: currentVC.view.topAnchor)
        menuViewTopCnstr.constant = 244
        NSLayoutConstraint.activate([
                   menuView.widthAnchor.constraint(equalToConstant: currentVC.view.frame.width),
                   menuView.heightAnchor.constraint(equalToConstant: 244),
                   menuView.leadingAnchor.constraint(equalTo: currentVC.view.leadingAnchor),
                   menuView.trailingAnchor.constraint(equalTo: currentVC.view.trailingAnchor),
               ])
        menuView.layoutIfNeeded()

        let blackView:UIView = UIView(frame:   CGRect(x: 0, y: 0, width: currentVC.view.frame.width, height: currentVC.view.frame.height))
        blackView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2415325599)
                
        currentVC.view.addSubview(blackView)
        
        currentVC.view.bringSubviewToFront(menuView)
        currentVC.view.bringSubviewToFront(view)

        menuViewTopCnstr.constant = self.view.frame.height
        menuViewTopCnstr.isActive = true
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
            
            self.menuBtn.transform.rotated(by: CGFloat((6 * Double.pi) / 2))
            menuView.layoutIfNeeded()

        }, completion: nil)
        
    }
    
    
}
