//
//  replyView.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/8/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit

class ReplyView: UIView {

    let blackView = UIView()
    
    @IBAction func replyTapped(_ sender: Any) {
        
        if let window = UIApplication.shared.keyWindow {
            blackView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
            
            ReplyView.frame = CGRect(x: 0, y: window.frame.height, width: view.frame.width, height: 285)
            window.addSubview(ReplyView)
            
            
            
            blackView.addGestureRecognizer(UIGestureRecognizer(target: UITapGestureRecognizer()
                , action: #selector(dismissReplyView)))
            
            blackView.backgroundColor = #colorLiteral(red: 0.2369174063, green: 0.2357194126, blue: 0.2378458679, alpha: 0.7544053819)
            blackView.alpha = 0
            
            window.addSubview(blackView)
            
            let replyHeight: CGFloat = 285
            let yValue = window.frame.height - replyHeight
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.replyView.layer.cornerRadius = 10
                self.replyView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                
                self.replyView.frame(forAlignmentRect: CGRect(x: 0, y: yValue, width: self.replyView.frame.width, height: self.replyView.frame.height))
                
            })
        }
    }
    
    @objc func dismissReplyView() {
        if let window = UIApplication.shared.keyWindow {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
                self.blackView.alpha = 0
                self.replyView.layer.cornerRadius = 0
                
                self.replyView.frame(forAlignmentRect: CGRect(x: 0, y: window.frame.height, width: self.replyView.frame.width, height: self.replyView.frame.height))
                
            })
        }
    }

}
