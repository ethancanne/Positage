//
//  PositageTextField.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/19/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit

@IBDesignable
class PositageTextField: UITextField {

    override func prepareForInterfaceBuilder() {
        CustomizeView()
    }
    
    override func awakeFromNib() {
        CustomizeView()
    }
    
    func CustomizeView() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 0
        layer.masksToBounds = false
        layer.cornerRadius = 4.0
        textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        backgroundColor = #colorLiteral(red: 0.9573150277, green: 0.957475245, blue: 0.9572940469, alpha: 1)

        
    }

}
