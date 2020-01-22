//
//  MenuVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 11/29/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit

class MenuVC: UIViewController {

    var isOpen:Bool = false
    @IBOutlet weak var menuView: PositageView!
    
    @IBOutlet weak var menuViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuViewTop.constant -= view.frame.height + 115
        menuView.layoutIfNeeded()
        
        backgroundView.alpha = 0
        
    }

}

class MenuView: PositageView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
    
    
    var isOpen:Bool = false
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var menuBarNameLocationStckViewLeadCnstr: NSLayoutConstraint!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var menuView: PositageView!
    @IBOutlet weak var menuBar: PositageView!
    
    @IBOutlet weak var menuViewTop: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var logoImg: UIImageView!

    override func didMoveToSuperview() {
        if AppLocation.IsTabViewVisible() {
            menuBarNameLocationStckViewLeadCnstr.constant = 18
            
            self.layoutIfNeeded()
            backBtn.isHidden = true
        }else{
            menuBarNameLocationStckViewLeadCnstr.constant = 70
            self.layoutIfNeeded()
            backBtn.isHidden = false
        }
        locationLbl.text = AppLocation.currentUserLocation
        
        if AppLocation.locationHidden{
            UIView.animate(withDuration: 0.4, animations: {
                self.locationStackView.alpha = 0
            })
        }else{
            UIView.animate(withDuration: 0.4, animations: {
                self.locationStackView.alpha = 1
            })
        }
    }
    
    
    @IBAction func menuBtnTapped(_ sender: Any) {
            showMenu()
    }
    func showMenu(){
       
        if isOpen{
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                if AppLocation.IsTabViewVisible(){
                    self.menuBarNameLocationStckViewLeadCnstr.constant = 18
                    self.superview?.layoutIfNeeded()
                }
                
                self.logoImg.alpha = 0
                self.usernameLbl.alpha = 1
                self.backBtn.alpha = 1
                
                self.backgroundView.alpha = 0
                
                self.menuViewTop.constant -= self.frame.height + 115
                self.superview?.layoutIfNeeded()
                self.menuBtn.transform = CGAffineTransform(rotationAngle: -(2*(CGFloat.pi)))
                self.menuBar.shadowType = 1
                self.menuBar.shadowHeightPosition = 8
                self.menuBar.shadowColor = #colorLiteral(red: 0.6078431373, green: 0.6705882353, blue: 0.7490196078, alpha: 1)
                self.menuBar.CustomizeView()

            }, completion: nil)
            isOpen = false
        }
        else{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations:{
                self.logoImg.alpha = 1;
                self.usernameLbl.alpha = 0
                self.backBtn.alpha = 0
                 self.backgroundView.alpha = 1
                
                //Animate Menu View
                if AppLocation.IsTabViewVisible(){
                    self.menuBarNameLocationStckViewLeadCnstr.constant = 60
                    self.superview?.layoutIfNeeded()

                        
                }
                
                 self.menuViewTop.constant = 0
                 self.superview?.layoutIfNeeded()
                self.menuBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.menuBar.shadowType = 2
                self.menuBar.shadowBlurRadius = 20
                self.menuBar.CustomizeView()
                 
             }, completion: nil)
            
            isOpen = true

        }
        
        
    }
}
