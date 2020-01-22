//
//  PositageAddButton.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/20/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit

@IBDesignable
class PositageAddButton: UIButton {

   
    override func prepareForInterfaceBuilder() {
        CustomizeView()
    }
    
    override func awakeFromNib() {
        CustomizeView()
    }
    
    func CustomizeView(){
       layer.cornerRadius = (layer.bounds.width) / 2
        clipsToBounds = true
        backgroundColor = #colorLiteral(red: 0.2056628764, green: 0.2057041228, blue: 0.2056574523, alpha: 0.879369213)
    }
    
}
