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
    
    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    override func awakeFromNib() {
        customizeView()
    }
    
    func customizeView(){
        layer.cornerRadius = 10
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
    }

}
