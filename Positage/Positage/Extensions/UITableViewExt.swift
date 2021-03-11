//
//  TableViewFormatter.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/9/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func setEmptyTableViewMessage(message: String) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        let rect = CGRect(x: 0, y: 0, width: self.bounds.size.width - 100, height: self.bounds.size.height)
        let messageLabel = UILabel(frame: rect)
        messageLabel.center.x = view.center.x
        messageLabel.text = message
        messageLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "CambriaBold", size: 30)
        view.sizeToFit()
        view.addSubview(messageLabel)
        self.backgroundView = view;
        self.separatorStyle = .none;
    }
    
    func scrollToBtm(){
        let count = self.numberOfRows(inSection: 0)
        if count != 0{
            DispatchQueue.main.async {
                
                let indexPath = IndexPath(row: count-1, section: 0)
                self.scrollToRow(at: indexPath, at: .bottom, animated: true)
                
            }
        }
    }
    
    func setInsets(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat){
        self.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    func startFromBtm() {
        let numRows = self.numberOfRows(inSection: 0)
        var contentInsetTop = self.bounds.size.height
        for i in 0..<numRows {
            let rowRect = self.rectForRow(at: IndexPath(item: i, section: 0))
            contentInsetTop -= rowRect.size.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
            }
        }
        self.contentInset = UIEdgeInsets(top: contentInsetTop,left: 0,bottom: 0,right: 0)
    }
    
    
}
