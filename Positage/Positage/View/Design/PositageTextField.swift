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

    override func prepareForInterfaceBuilder() {
        CustomizeView()
    }
    
    override func awakeFromNib() {
        CustomizeView()
        delegate = self
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
