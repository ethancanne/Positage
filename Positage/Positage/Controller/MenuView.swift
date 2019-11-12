//
//  MenuView.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/27/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit

class MenuView: UIView {
    
    
    override func awakeFromNib() {
        let size = self.frame.size
        self.clipsToBounds = true
        let layer: CALayer = CALayer()
        layer.backgroundColor = UIColor.lightGray.cgColor
        layer.position = CGPoint(x: size.width / 2, y: -size.height / 2 + 0.5)
        layer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 3.0
        self.layer.addSublayer(layer)
        
        
    }
    
    
    public static func createView() -> MenuView {
        if let menu = Bundle.main.loadNibNamed("MenuView", owner: self, options: nil)?.first as? MenuView {
                return menu
        }
        return MenuView()
    }
    
    @IBAction func trackingBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "TrackingViewController")
        let currentController = self.getCurrentViewController()
        currentController?.present(mainTabBarController, animated: true, completion: nil)
    }
    
    @IBAction func settingsBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "SettingsMainNavController")
        let currentController = self.getCurrentViewController()
        currentController?.present(mainTabBarController, animated: true, completion: nil)
    }
    @IBAction func addBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CreatePost", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "CreatePostNavController")
        let currentController = self.getCurrentViewController()
        currentController?.present(mainTabBarController, animated: true, completion: nil)
    }
    
    func getCurrentViewController() -> UIViewController? {
        
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
        
    }
    
//    private var menuIsShown: Bool = false
//    let menu = MenuView.createView()
    
    class func showMenu(view: UnsafeMutablePointer<UIView>, menuStackView: UnsafeMutablePointer<UIStackView>, userBarTopCnstr: UnsafeMutablePointer<NSLayoutConstraint>, menuArrowLbl: UnsafeMutablePointer<UILabel>, menu: UIView, menuIsShown: Bool){
        menuStackView.pointee.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.2, animations: {
            menuStackView.pointee.alpha = 0.5
        })
        { (worked) in
            UIView.animate(withDuration: 0.2, animations: {
                menuStackView.pointee.alpha = 1
            })
        }
        let amountToMove: CGFloat = 16.0
        
        guard let window = UIApplication.shared.keyWindow else { return }
        
        if !menuIsShown{
            menu.frame = CGRect(x: 0, y: menuStackView.pointee.frame.maxY + amountToMove, width: window.frame.width, height: 126)
            userBarTopCnstr.pointee.constant += menu.frame.height - amountToMove
            menu.alpha = 0
            view.pointee.addSubview(menu)
            view.pointee.sendSubviewToBack(menu)
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
                view.pointee.layoutIfNeeded()
                menu.alpha = 1
                menuArrowLbl.pointee.transform = menuArrowLbl.pointee.transform.rotated(by: CGFloat((6 * Double.pi) / 2))
            }, completion: {(worked) in
                menuStackView.pointee.isUserInteractionEnabled = true
            })
        }
        else{
            userBarTopCnstr.pointee.constant -= menu.frame.height - amountToMove
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
                view.pointee.layoutIfNeeded()
                menu.alpha = 0
                menuArrowLbl.pointee.transform = menuArrowLbl.pointee.transform.rotated(by: CGFloat(-(6 * Double.pi) / 2))
            }, completion: {(worked) in
                menu.removeFromSuperview()
                menuStackView.pointee.isUserInteractionEnabled = true
            })
        }
    }
}
