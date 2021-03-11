////
////  MenuView.swift
////  Positage
////
////  Created by Ethan Cannelongo on 2/27/19.
////  Copyright © 2019 Ethan Cannelongo. All rights reserved.
////
//
//import UIKit
//
//class MenuView: PositageView {
//    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let view = super.hitTest(point, with: event)
//        return view == self ? nil : view
//    }
//    
//    
//    var isOpen:Bool = false
//    @IBOutlet weak var usernameLbl: UILabel!
//    @IBOutlet weak var locationStackView: UIStackView!
//    @IBOutlet weak var locationLbl: UILabel!
//    @IBOutlet weak var backBtn: UIButton!
//    @IBOutlet weak var menuBarNameLocationStckViewLeadCnstr: NSLayoutConstraint!
//    @IBOutlet weak var menuBtn: UIButton!
//    @IBOutlet weak var menuView: PositageView!
//    @IBOutlet weak var menuBar: PositageView!
//    
//    @IBOutlet weak var menuViewTop: NSLayoutConstraint!
//    @IBOutlet weak var backgroundView: UIView!
//    @IBOutlet weak var logoImg: UIImageView!
//
//    override func didMoveToSuperview() {
//        if AppLocation.isTabViewVisible() {
//            menuBarNameLocationStckViewLeadCnstr.constant = 18
//            
//            self.layoutIfNeeded()
//            backBtn.isHidden = true
//        }else{
//            menuBarNameLocationStckViewLeadCnstr.constant = 70
//            self.layoutIfNeeded()
//            backBtn.isHidden = false
//        }
//        locationLbl.text = AppLocation.currentUserLocation
//    }
//    
//    @IBAction func menuBtnTapped(_ sender: Any) {
//            showMenu()
//    }
//    func showMenu(){
//       
//        if isOpen{
//            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
//                if AppLocation.isTabViewVisible(){
//                    self.menuBarNameLocationStckViewLeadCnstr.constant = 18
//                    self.superview?.layoutIfNeeded()
//                }
//                
//                self.logoImg.alpha = 0
//                self.usernameLbl.alpha = 1
//                self.backBtn.alpha = 1
//                
//                self.backgroundView.alpha = 0
//                
//                self.menuViewTop.constant -= self.frame.height + 115
//                self.superview?.layoutIfNeeded()
//                self.menuBtn.transform = CGAffineTransform(rotationAngle: -(2*(CGFloat.pi)))
//                self.menuBar.shadowType = 1
//                self.menuBar.shadowHeightPosition = 8
//                self.menuBar.shadowColor = #colorLiteral(red: 0.6078431373, green: 0.6705882353, blue: 0.7490196078, alpha: 1)
//                self.menuBar.CustomizeView()
//
//            }, completion: nil)
//            isOpen = false
//        }
//        else{
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations:{
//                self.logoImg.alpha = 1;
//                self.usernameLbl.alpha = 0
//                self.backBtn.alpha = 0
//                 self.backgroundView.alpha = 1
//                
//                //Animate Menu View
//                if AppLocation.isTabViewVisible(){
//                    self.menuBarNameLocationStckViewLeadCnstr.constant = 70
//                    self.superview?.layoutIfNeeded()
//
//                        
//                }
//                
//                 self.menuViewTop.constant = 0
//                 self.superview?.layoutIfNeeded()
//                self.menuBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
//                self.menuBar.shadowType = 2
//                self.menuBar.shadowBlurRadius = 20
//                self.menuBar.CustomizeView()
//                 
//             }, completion: nil)
//            
//            isOpen = true
//
//        }
//        
//        
//    }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
////
////    override func awakeFromNib() {
//////        let size = self.frame.size
//////        self.clipsToBounds = true
//////        let layer: CALayer = CALayer()
//////        layer.backgroundColor = UIColor.lightGray.cgColor
//////        layer.position = CGPoint(x: size.width / 2, y: -size.height / 2 + 0.5)
//////        layer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//////        layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//////        layer.shadowOffset = CGSize(width: 6, height: 0.5)
//////        layer.shadowOpacity = 0.8
//////        layer.shadowRadius = 3.0
//////        self.layer.addSublayer(layer)
//////
////
////    }
////
////
//    public static func createView() -> MenuView {
//        if let menu = Bundle.main.loadNibNamed("MenuView", owner: self, options: nil)?.first as? MenuView {
//                return menu
//        }
//        return MenuView()
//    }
//
////    @IBAction func trackingBtnTapped(_ sender: Any) {
////        let storyboard = UIStoryboard(name: "Main", bundle: nil)
////        let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "TrackingViewController")
////        let currentController = self.getCurrentViewController()
////        currentController?.present(mainTabBarController, animated: true, completion: nil)
////    }
////
////    @IBAction func settingsBtnTapped(_ sender: Any) {
////        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
////        let mainNavController = storyboard.instantiateViewController(withIdentifier: "SettingsMainNavController")
////        let currentController = self.getCurrentViewController()
////        currentController?.present(mainNavController, animated: true, completion: nil)
////    }
////    @IBAction func addBtnTapped(_ sender: Any) {
////        let currentController = self.getCurrentViewController()
////
////        let alert = UIAlertController(title: "What would you like to create?", message: "", preferredStyle: .actionSheet)
////        alert.addAction(UIAlertAction(title: "New Post", style: .default, handler: { (action) in
////            let storyboard = UIStoryboard(name: "CreatePost", bundle: nil)
////            let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "CreatePostNavController")
////            let currentController = self.getCurrentViewController()
////            currentController?.present(mainTabBarController, animated: true, completion: nil)
////        }))
////        alert.addAction(UIAlertAction(title: "New Group", style: .default, handler: { (action) in
////            let storyboard = UIStoryboard(name: "Groups", bundle: nil)
////            let createGroupVC = storyboard.instantiateViewController(withIdentifier: "CreateGroupVC")
////            currentController?.present(createGroupVC, animated: true, completion: nil)
////        }))
////        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
////
////        currentController?.present(alert, animated: true, completion: nil)
////    }
////
////    func getCurrentViewController() -> UIViewController? {
////
////        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
////            var currentController: UIViewController! = rootController
////            while( currentController.presentedViewController != nil ) {
////                currentController = currentController.presentedViewController
////            }
////            return currentController
////        }
////        return nil
////
////    }
////
////    class func showMenu(view: UnsafeMutablePointer<UIView>, menuStackView: UnsafeMutablePointer<UIStackView>, userBarTopCnstr: UnsafeMutablePointer<NSLayoutConstraint>, menuArrowLbl: UnsafeMutablePointer<UILabel>, menu: UIView, menuIsShown: Bool){
////        menuStackView.pointee.isUserInteractionEnabled = false
////
////        UIView.animate(withDuration: 0.2, animations: {
////            menuStackView.pointee.alpha = 0.5
////        })
////        { (worked) in
////            UIView.animate(withDuration: 0.2, animations: {
////                menuStackView.pointee.alpha = 1
////            })
////        }
////        let amountToMove: CGFloat = 16.0
////
////        guard let window = UIApplication.shared.keyWindow else { return }
////
////        if !menuIsShown{
////            menu.frame = CGRect(x: 0, y: menuStackView.pointee.frame.maxY + amountToMove, width: window.frame.width, height: 126)
////            userBarTopCnstr.pointee.constant += menu.frame.height - amountToMove
////            menu.alpha = 0
////            view.pointee.addSubview(menu)
////            view.pointee.sendSubviewToBack(menu)
////
////            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
////                view.pointee.layoutIfNeeded()
////                menu.alpha = 1
////                menuArrowLbl.pointee.transform = menuArrowLbl.pointee.transform.rotated(by: CGFloat((6 * Double.pi) / 2))
////            }, completion: {(worked) in
////                menuStackView.pointee.isUserInteractionEnabled = true
////            })
////        }
////        else{
////            userBarTopCnstr.pointee.constant -= menu.frame.height - amountToMove
////
////
////            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
////                view.pointee.layoutIfNeeded()
////                menu.alpha = 0
////                menuArrowLbl.pointee.transform = menuArrowLbl.pointee.transform.rotated(by: CGFloat(-(6 * Double.pi) / 2))
////            }, completion: {(worked) in
////                menu.removeFromSuperview()
////                menuStackView.pointee.isUserInteractionEnabled = true
////            })
////        }
////    }
////}
//}
