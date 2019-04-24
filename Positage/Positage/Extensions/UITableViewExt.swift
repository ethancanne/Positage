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
        messageLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.09112413196)
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "Chalkboard SE", size: 30)
        view.sizeToFit()
        view.addSubview(messageLabel)
        self.backgroundView = view;
        self.separatorStyle = .none;
    }
}
