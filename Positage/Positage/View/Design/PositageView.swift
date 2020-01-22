//
//  PositageView.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/20/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
@IBDesignable
class PositageView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable var shadowType: Int = 0
    
    @IBInspectable var shadowColor: UIColor = #colorLiteral(red: 0.586538434, green: 0.6672740579, blue: 0.7448138595, alpha: 1)

    @IBInspectable var shadowHeightPosition: Int = 0
    
    @IBInspectable var shadowBlurRadius: Int = 0
    

    
    override func prepareForInterfaceBuilder() {
        CustomizeView()
    }
    
    override func awakeFromNib() {
        CustomizeView()
    }
    
    func CustomizeView(){
        
        if shadowType == 1 {
            layer.shadowColor = shadowColor.cgColor
                layer.shadowRadius = 0
                layer.shadowOpacity = 1
                layer.shadowOffset = CGSize(width: 0, height: shadowHeightPosition)
                layer.masksToBounds = false
        }
        else if shadowType == 2 {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.5
            layer.shadowOffset = CGSize(width: 2, height: shadowHeightPosition)
            layer.shadowRadius = CGFloat(shadowBlurRadius)
            layer.masksToBounds = false
        }
}
    

}
