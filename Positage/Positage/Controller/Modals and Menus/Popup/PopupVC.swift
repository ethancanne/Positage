//
//  BottomPopupVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/29/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
class PopupVC: UIViewController {
    @IBOutlet weak var handleView: PositageView!
    @IBOutlet weak var popupView: PositageView!
    @IBOutlet weak var popupViewBtmCnstr: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var popupViewHeightCnstr: NSLayoutConstraint!
    
    private var initialPopupHeight: CGFloat!
    private var popupContentVC: UIViewController!
    
    func setupPopup(withViewController vc: UIViewController){
        popupContentVC = vc
        initialPopupHeight = popupContentVC.view.frame.height
        popupContentVC.view.frame = CGRect(x: 0, y: 0, width: popupView.frame.width, height: initialPopupHeight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        blackView.alpha = 0
        self.popupViewBtmCnstr.constant -= (self.popupView.frame.height  + 100)
        
        popupViewHeightCnstr.constant = initialPopupHeight

        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
         UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
            self.popupViewBtmCnstr.constant = 0
            self.blackView.alpha = 1
            self.view.layoutIfNeeded()
         }, completion: nil)
        
    }

    override func viewDidLoad() {
        let handleViewPanGestrRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        let popupViewPanGestrRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))

        handleView.addGestureRecognizer(handleViewPanGestrRecognizer)
        popupView.addGestureRecognizer(popupViewPanGestrRecognizer)
        
        //Set Container View to specified VC
        addChild(popupContentVC)
        popupView.addSubview(popupContentVC.view)
        popupContentVC.didMove(toParent: self)

    }
    
        
    @objc func handlePan(recognizer: UIPanGestureRecognizer){
        switch recognizer.state{
        case .began:
            print("Pan Began")
        case .changed:
            let translation = recognizer.translation(in: view)
            print(translation.y)
            if popupViewBtmCnstr.constant <= 0{
                popupViewBtmCnstr.constant -= translation.y
                blackView.alpha -= (translation.y/500)
                view.layoutIfNeeded()
                recognizer.setTranslation(.zero, in: view)
            } else{
                //Going up passed start value
                popupViewBtmCnstr.constant -= (translation.y / 2)
                view.layoutIfNeeded()
                recognizer.setTranslation(.zero, in: view)
            }
        case .ended:
            let velocity = recognizer.velocity(in: view).y
            print("velocity: " + String(Int(velocity)))
            if popupViewBtmCnstr.constant <= -(popupView.frame.height / 2) || velocity >= 250 {
                 UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations:{
                    self.popupViewBtmCnstr.constant -= self.popupView.frame.height
                    self.blackView.alpha = 0
                    self.view.layoutIfNeeded()
                 }, completion:  {(worked) in self.dismiss(animated: false)})
            }else{
                 UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                    self.popupViewBtmCnstr.constant = 0
                    self.view.layoutIfNeeded()
                },completion: nil)
            }
        default:
            print("Pan Error")
        }
        
    }
}
