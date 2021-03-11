//
//  MenuVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 11/29/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit

protocol SearchDelegate {
    func searchDidChange(with text: String)
}
class MenuVC: UIViewController, UISearchBarDelegate{
    
    var isOpen:Bool = false
    //Menu Views
        //Search
    @IBOutlet var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
        //Main
    @IBOutlet weak var mainInfoView: UIView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var numStampsLbl: UILabel!

    //Tab Bar
    @IBOutlet weak var tabBarViewBtmCnstr: NSLayoutConstraint!
    
    //Top
    @IBOutlet weak var menuBar: PositageView!
    
    @IBOutlet weak var topUsernameLbl: UILabel!
    
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var logoImg: UIImageView!

    @IBOutlet weak var menuBarNameLocationStckViewLeadCnstr: NSLayoutConstraint!
    @IBOutlet weak var logoImgLeadCnstr: NSLayoutConstraint!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    
    //Main
    @IBOutlet weak var mainContentView: PositageView!
    @IBOutlet weak var mainContentViewHeightCnstr: NSLayoutConstraint!
    @IBOutlet weak var menuViewTopCnstr: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundView: UIView!
    
    var createView: UIView!
    var isSubmenuOpen: Bool = false
    var isMenuOpen:Bool = false
    var searchDelegate: SearchDelegate!
    var isSearching: Bool = false
    var isSearchMenuOpen: Bool = false


    override func viewDidLoad() {
          super.viewDidLoad()
          menuViewTopCnstr.constant -= view.frame.height + 115
          view.layoutIfNeeded()
          
          backgroundView.alpha = 0
        
        searchBar.delegate = self
          
      }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isSubmenuOpen {
            backBtn.alpha = 0
        }
        self.menuBarNameLocationStckViewLeadCnstr.constant = 18
        
        updateMenu()
    }
        

    @IBAction func dropdownBtnTapped(_ sender: Any) {
        if isSubmenuOpen{
            toggleMenu(with: nil, size: ((self.view.frame.height - menuBar.frame.height) - menuBar.frame.height))
        }else{
            toggleMenu(with: mainInfoView, size: 192)
        }
        
        if AppLocation.isTabViewVisible(){
            toggleTabBar()
        }
    }
    
    @IBAction func searchBtnTapped(_ sender: Any) {
        isSubmenuOpen = false
        toggleMenu(with: searchView, size: 57, isFocused: false)
        searchBar.placeholder = "Search: " + AppLocation.currentUserLocation!
        toggleTabBar()
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        //If submenu is currently visible on screen
        if isSubmenuOpen{
            toggleSubmenu()
        }else if isMenuOpen{
            toggleMenu()
        }
    }

    
    @IBAction func createBtnTapped(_ sender: Any) {
           let storyboard = UIStoryboard(name: "Create", bundle: nil)
           let createVC = storyboard.instantiateViewController(withIdentifier: "CreateVC")
           createView = createVC.view
           createView.alpha = 0
           toggleSubmenu(withView: createView)
       }
    
    @IBAction func settingsBtnTapped(_ sender: Any) {
        var settingsVC = instantiateViewController(fromStoryboard: "Settings", withIdentifier: "settingsVC")
        createView = settingsVC.view
        createView.alpha = 0
        toggleSubmenu(withView: createView)
    }
    

    
    //Menu Functions
    func updateMenu(){
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
        
        usernameLbl.text = DataService.currentUser?.username
        
        topUsernameLbl.text = DataService.currentUser?.username
        
        numStampsLbl.text = String(DataService.currentUserNumStamps)
        
    }
    
    func toggleMenu(with view: UIView? = nil, size: CGFloat? = nil, isFocused: Bool = true){
        //open the entire menu
        if !isMenuOpen{
            if let view = view, let size = size {
                mainContentView.insertFullSubview(with: view)
                mainContentViewHeightCnstr.constant = size
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations:{
                if isFocused{
                    if !AppLocation.locationHidden{
                        self.locationStackView.alpha = 0
                    }
                    
                    self.logoImg.alpha = 1
                    self.topUsernameLbl.alpha = 0
                    self.backgroundView.alpha = 1
                    self.menuBarNameLocationStckViewLeadCnstr.constant = 65
                    self.view.superview?.layoutIfNeeded()
                }
                
                self.menuViewTopCnstr.constant = 0
                self.view.superview?.layoutIfNeeded()
                self.menuBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.enableMenuShadow(enabled: true)
            
            }, completion: nil)
        
        }
            
        //close the entire menu
        else if isMenuOpen{
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                
                self.menuBarNameLocationStckViewLeadCnstr.constant = 18
                self.view.superview?.layoutIfNeeded()
                
                if !AppLocation.locationHidden{
                    self.locationStackView.alpha = 1
                }
                
                self.logoImg.alpha = 0
                self.topUsernameLbl.alpha = 1
                
                self.backgroundView.alpha = 0
                
                self.menuViewTopCnstr.constant -= self.view.frame.height + 115
                self.view.superview?.layoutIfNeeded()
                self.menuBtn.transform = CGAffineTransform(rotationAngle: -(2*(CGFloat.pi)))
                self.enableMenuShadow(enabled: false)
                
                
            }, completion: nil)
        
        }
        
        //Animate Back Btn Out
        if self.isSubmenuOpen{
            self.toggleBackBtn()
        }
        isMenuOpen = !isMenuOpen
        
    }
    
    func toggleSubmenu (withView view: UIView? = nil){
        //Open Submenu
        if !isSubmenuOpen{
            //View
            if let view = view{
                view.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9568627451, blue: 0.9647058824, alpha: 1)
                view.layer.shadowOpacity = 0
                mainContentView.insertFullSubview(with: view, isRemoveAll: false)
                
                mainContentViewHeightCnstr.constant = (self.view.frame.height - menuBar.frame.height) - menuBar.frame.height
                
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                    self.menuBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                    self.view.layoutIfNeeded()
                    
                    view.alpha = 1
                    
                    
                }, completion: nil)
                
            }
            
        } else{
            //Close Submenu
            mainContentViewHeightCnstr.constant = 192
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations:{
                self.createView.alpha = 0
                self.view.superview?.layoutIfNeeded()
                self.menuBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }, completion: {(worked) in self.createView.removeFromSuperview()})
            
        }
        
        toggleBackBtn()
        isSubmenuOpen = !isSubmenuOpen
    }
    
    func enableMenuShadow(enabled: Bool){
        menuBar.shadowColor = #colorLiteral(red: 0.6078431373, green: 0.6705882353, blue: 0.7490196078, alpha: 1)
        menuBar.shadowType = (isMenuOpen) ? 1 : 2
        menuBar.shadowHeightPosition = (isMenuOpen) ? 8 : 20
        menuBar.shadowBlurRadius = 20
        menuBar.CustomizeView()
    }
    
    func toggleBackBtn(){
        if self.backBtn.alpha == 0{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                //Animate Back Button in
                self.logoImgLeadCnstr.constant += self.backBtn.frame.width
                self.view.layoutIfNeeded()
                self.backBtn.alpha = 1
            },completion: nil)
        } else{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                //Animate Back Button out
                self.logoImgLeadCnstr.constant -= self.backBtn.frame.width
                self.view.layoutIfNeeded()
                self.backBtn.alpha = 0
            }, completion: nil)
        }
    }
    
    func toggleTabBar(){
        //Animate TabBar View out of the screen
        tabBarViewBtmCnstr.constant = ((tabBarViewBtmCnstr.constant != 0 && !isSearching)) ? 0 : -100
        UIView.animate(withDuration: 0.2){
            self.view.layoutIfNeeded()
            self.searchBtn.alpha = (self.searchBtn.alpha != 0) ? 0 : 1
        }
        
    }
   
    
    
    //Search Bar stubs
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDelegate.searchDidChange(with: searchText.lowercased())
        isSearching = (searchText != "") ? true : false
        searchBtn.tintColor = (searchText != "") ? #colorLiteral(red: 0.629678309, green: 0.7381821871, blue: 0.8188829422, alpha: 1): #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1.0)
    }
    
}

class MenuView: PositageView {
    //Window and view requirements, so touches can be performed behind window:
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
    
    
    
}

