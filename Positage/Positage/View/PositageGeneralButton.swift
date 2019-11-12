//
//  PositageGeneralButton.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/30/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit

@IBDesignable
class PositageGeneralButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            layer.cornerRadius = self.cornerRadius
        }
    }
    
    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    override func awakeFromNib() {
        customizeView()
    }
    
    func customizeView(){
        layer.cornerRadius = cornerRadius
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2
        layer.masksToBounds = false
    }

}
