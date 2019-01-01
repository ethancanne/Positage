//
//  UserBarView.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/20/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit

@IBDesignable
class UserBarView: UIView {

    override func prepareForInterfaceBuilder() {
        CustomizeView()
    }
    
    override func awakeFromNib() {
        CustomizeView()
    }
    
    func CustomizeView(){
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 20
        layer.masksToBounds = false
    }

}
