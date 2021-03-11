//
//  MenuVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 11/29/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit

class MenuVCCopy: UIViewController {
    
    var isOpen:Bool = false
    @IBOutlet weak var menuViewTop: NSLayoutConstraint!
    @IBOutlet var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuViewTop.constant -= view.frame.height + 115
        view.layoutIfNeeded()
        
        backgroundView.alpha = 0
        
    }
    
    
    
}

class MenuViewCopy: PositageView {
    //Window and view requirements, so touches can be performed behind window:
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
    
    @IBOutlet weak var topUsernameLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var numStampsLbl: UILabel!
    
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var menuBarNameLocationStckViewLeadCnstr: NSLayoutConstraint!
    @IBOutlet weak var logoImgLeadCnstr: NSLayoutConstraint!
    @IBOutlet weak var logoImg: UIImageView!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var mainContentView: PositageView!
    @IBOutlet weak var mainContentViewHeightCnstr: NSLayoutConstraint!
    
    @IBOutlet weak var menuBar: PositageView!
    @IBOutlet weak var mainInfoView: UIView!
    
    @IBOutlet weak var menuViewTopCnstr: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    
    var menuView: UIView!
    var isSubmenuOpen: Bool = false
    var isMenuOpen:Bool = false
    
    
    override func didMoveToSuperview() {
        usernameLbl.text = DataService.currentUser?.username
        
        topUsernameLbl.text = DataService.currentUser?.username
        
        numStampsLbl.text = String(DataService.currentUserNumStamps)
        
        if !isSubmenuOpen {
            backBtn.alpha = 0
        }
        self.menuBarNameLocationStckViewLeadCnstr.constant = 18
        
        if AppLocation.locationHidden{
            UIView.animate(withDuration: 0.1, animations: {
                self.locationStackView.alpha = 0
            })
        }else{
            self.locationLbl.text = AppLocation.currentUserLocation
            UIView.animate(withDuration: 0.1, animations: {
                self.locationStackView.alpha = 1
            })
        }
    }
    
    @IBAction func menuBtnTapped(_ sender: Any) {
        
        toggleMenu()
    }
    
    
    var previousView: UIView
    func toggleMenu(isSmallView Bool, isSubmenu: Bool, withView view: UIView){        
        if isSubmenu {
            previousView = menuView
        }
        
        //View
        view.frame = mainContentView.frame
        view.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9568627451, blue: 0.9647058824, alpha: 1)
        view.layer.shadowOpacity = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        mainContentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor, constant: 0),
            view.topAnchor.constraint(equalTo: mainContentView.topAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: mainContentView.bottomAnchor, constant: 0),
        ])
        
        
        if !isSubmenu {
            //Close Menu
            if isMenuOpen{
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.menuBarNameLocationStckViewLeadCnstr.constant = 18
                    self.superview?.layoutIfNeeded()
                    
                    if !AppLocation.locationHidden{
                        self.locationStackView.alpha = 1
                    }
                    
                    self.logoImg.alpha = 0
                    self.topUsernameLbl.alpha = 1
                    
                    self.backgroundView.alpha = 0
                    
                    self.menuViewTopCnstr.constant -= self.frame.height + 115
                    self.superview?.layoutIfNeeded()
                    self.menuBtn.transform = CGAffineTransform(rotationAngle: -(2*(CGFloat.pi)))
                    self.enableMenuShadow(enabled: false)
                    
                    
                }, completion: nil)
                
                //Animate Back Btn Out
                if self.isSubmenuOpen{
                    self.toggleBackBtn()
                }
                isMainMenuOpen = false
            }
                
                //open the entire menu
            else if !isMenuOpen{
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations:{
                    
                    self.menuViewTopCnstr.constant = 0
                    
                    self.menuBarNameLocationStckViewLeadCnstr.constant = 65
                    self.superview?.layoutIfNeeded()
                    
                    if !AppLocation.locationHidden{
                        self.locationStackView.alpha = 0
                    }
                    
                    self.logoImg.alpha = 1;
                    self.topUsernameLbl.alpha = 0
                    self.backgroundView.alpha = 1
                    
                    self.superview?.layoutIfNeeded()
                    self.menuBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                    self.enableMenuShadow(enabled: true)
                    
                    
                }, completion: nil)
                
                //Animate Back Btn in if submenu is open
                if self.isSubmenuOpen{
                    self.toggleBackBtn()
                }
                isMainMenuOpen = true
            }
        }else{
            
        }
        
        
    }
    
    @IBAction func toggleSearch(_ sender: Any) {
    
    }
    
    func enableMenuShadow(enabled: Bool){
        menuBar.shadowColor = #colorLiteral(red: 0.6078431373, green: 0.6705882353, blue: 0.7490196078, alpha: 1)
        menuBar.shadowType = (isMainMenuOpen) ? 1 : 2
        menuBar.shadowHeightPosition = (isMainMenuOpen) ? 8 : 20
        menuBar.shadowBlurRadius = 20
        menuBar.CustomizeView()
    }
    
    @IBAction func createBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Create", bundle: nil)
        let createVC = storyboard.instantiateViewController(withIdentifier: "CreateVC")
        createView = createVC.view
        createView.alpha = 0
        toggleSubmenu(withView: createView)
    }
    
    
    
    func toggleBackBtn(){
        if self.backBtn.alpha == 0{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                //Animate Back Button in
                self.logoImgLeadCnstr.constant += self.backBtn.frame.width
                self.layoutIfNeeded()
                self.backBtn.alpha = 1
            },completion: nil)
        } else{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                //Animate Back Button out
                self.logoImgLeadCnstr.constant -= self.backBtn.frame.width
                self.layoutIfNeeded()
                self.backBtn.alpha = 0
            }, completion: nil)
        }
    }
    
    func toggleSubmenu (withView view: UIView?){
        //Open Submenu
        if let view = view{
            mainContentViewHeightCnstr.constant = (self.frame.height - menuBar.frame.height) - menuBar.frame.height
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                self.menuBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.layoutIfNeeded()
                
                self.mainInfoView.alpha = 0
                
            }, completion: nil)
                        
            //View
            view.frame = mainContentView.frame
            view.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9568627451, blue: 0.9647058824, alpha: 1)
            view.layer.shadowOpacity = 0
            view.translatesAutoresizingMaskIntoConstraints = false
            
            mainContentView.addSubview(view)
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 0),
                view.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor, constant: 0),
                view.topAnchor.constraint(equalTo: mainContentView.topAnchor, constant: 0),
                view.bottomAnchor.constraint(equalTo: mainContentView.bottomAnchor, constant: 0),
            ])
            
            UIView.animate(withDuration: 0.6) {
                view.alpha = 1
            }
            
            toggleBackBtn()
            isSubmenuOpen = true
            
        }
        else{
            //Close Submenu
            mainContentViewHeightCnstr.constant = 192
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations:{
                self.mainInfoView.alpha = 1
                self.createView.alpha = 0
                self.superview?.layoutIfNeeded()
                self.menuBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                
            }, completion: {(worked) in self.createView.removeFromSuperview()})
            
            toggleBackBtn()
            isSubmenuOpen = false
            
        }
        
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        //If submenu is currently visible on screen
        toggleSubmenu(withView: nil)
    }
    
}

