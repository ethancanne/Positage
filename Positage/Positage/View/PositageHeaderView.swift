//
//  PositageHeaderView.swift
//  Positage
//
//  Created by Ethan Cannelongo on 1/6/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit

@IBDesignable
class PositageHeaderView: UIView {

    override func awakeFromNib() {
        customizeView()
    }
    
    override func prepareForInterfaceBuilder() {
        customizeView()
    }
   
    func customizeView(){
        layer.cornerRadius = 35
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }

}
