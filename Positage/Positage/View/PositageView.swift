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

    override func prepareForInterfaceBuilder() {
        CustomizeView()
    }
    
    override func awakeFromNib() {
        CustomizeView()
    }
    
    func CustomizeView(){
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowRadius = 0
        layer.masksToBounds = false
    }
    

}
