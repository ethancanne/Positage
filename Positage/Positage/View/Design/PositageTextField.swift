//
//  PositageTextField.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/19/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit

@IBDesignable
class PositageTextField: UITextField, UITextFieldDelegate{
    
    
    @IBInspectable var addTxtInset: Bool = true
    
    @IBInspectable var maxLength: Int = 100
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable var shadowType: Int = 0
    
    @IBInspectable var shadowColor: UIColor = #colorLiteral(red: 0.586538434, green: 0.6672740579, blue: 0.7448138595, alpha: 1)
    
    @IBInspectable var shadowHeightPosition: Int = 0
    
    @IBInspectable var shadowBlurRadius: Int = 0
    
    @IBInspectable var maskedCorners: String = String()
    
    override func prepareForInterfaceBuilder() {
        CustomizeView()
    }
    
    override func awakeFromNib() {
        CustomizeView()
        delegate = self
    }
    
    func CustomizeView() {
        
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
        for corner in maskedCorners {
            layer.maskedCorners = CACornerMask(rawValue: UInt(Int(String(corner))!))
        }

        
        if addTxtInset == true {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: frame.height))
            leftView = paddingView
            leftViewMode = UITextField.ViewMode.always
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
}
