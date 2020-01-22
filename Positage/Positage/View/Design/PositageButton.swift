//
//  PositageGeneralButton.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/30/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit

@IBDesignable
class PositageButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable var addShadow: Bool = false
    
    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    override func awakeFromNib() {
        customizeView()
    }
    
    func customizeView(){
        layer.cornerRadius = 8
        if addShadow{
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.3
            layer.shadowOffset = CGSize(width: 1, height: 1)
            layer.shadowRadius = 2
        }
        
        layer.masksToBounds = false
    }

}
