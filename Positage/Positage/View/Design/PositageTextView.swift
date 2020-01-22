//
//  PositageTextView.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/20/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
@IBDesignable
class PositageTextView: UITextView {


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
        layer.shadowRadius = 2
        layer.masksToBounds = false
        layer.cornerRadius = 0.7
        textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        backgroundColor = #colorLiteral(red: 0.8478136063, green: 0.8430128098, blue: 0.8429611325, alpha: 1)
        
        
    }
    
    

}
