//
//  HeaderBarVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 3/7/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit

class HeaderBarVC: UIViewController {

    @IBOutlet weak var menuArrowLbl: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    private var menuIsShown: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        mainStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMenu)))
    }
    


    let menu = MenuView.createView()
    
    
    @objc func showMenu(){
        mainStackView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.mainStackView.alpha = 0.5
        })
        { (worked) in
            UIView.animate(withDuration: 0.2, animations: {
                self.mainStackView.alpha = 1
            })
        }
        let amountToMove: CGFloat = 16.0
        
        if !menuIsShown{
            menu.frame = CGRect(x: 0, y: self.mainStackView.frame.maxY + amountToMove, width: self.view.frame.width, height: 126)
            menu.alpha = 0
            view.addSubview(menu)
            view.sendSubviewToBack(menu)
            menuIsShown = true
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
                self.view.frame = CGRect(x: self.view.frame.minX, y: self.view.frame.minY, width: self.view.frame.width, height: self.view.frame.height + amountToMove)
                self.menu.alpha = 1
                self.menuArrowLbl.transform = self.menuArrowLbl.transform.rotated(by: CGFloat((6 * Double.pi) / 2))
            }, completion: {(worked) in
                self.mainStackView.isUserInteractionEnabled = true
            })
        }
        else{
            self.menuIsShown = false
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
                self.view.frame = CGRect(x: self.view.frame.minX, y: self.view.frame.minY, width: self.view.frame.width, height: self.view.frame.height + amountToMove)
                self.menu.alpha = 0
                self.menuArrowLbl.transform = self.menuArrowLbl.transform.rotated(by: CGFloat(-(6 * Double.pi) / 2))
            }, completion: {(worked) in
                self.menu.removeFromSuperview()
                self.mainStackView.isUserInteractionEnabled = true
                self.menuArrowLbl.isUserInteractionEnabled = true
            })
        }
    }

}
