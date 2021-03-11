//
//  UIViewExt.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/10/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    

    func bindToKeyboard (by amount: Int = 0){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    @objc func keyboardWillChange (_ notification: NSNotification){
            
        guard let userInfo = notification.userInfo else { return }
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let beginningFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let differenceFromBottom = UIApplication.shared.keyWindow!.frame.maxY - self.frame.maxY
        let deltaY = (endFrame.origin.y - beginningFrame.origin.y)

        
        
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += (deltaY)
        }, completion: nil)
    }
    
    
    func insertFullSubview(with subview: UIView, isRemoveAll: Bool = true){
        if isRemoveAll{
            for i in self.subviews{
                i.removeFromSuperview()
            }
        }
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.frame = self.frame

        self.addSubview(subview)
        
        
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            subview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        ])
        self.layoutIfNeeded()

    }
}
