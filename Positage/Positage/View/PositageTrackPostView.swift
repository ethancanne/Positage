//
//  PositageTrackPostView.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/1/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit

@IBDesignable
class PositageTrackPostView: UIView {

    override func awakeFromNib() {
        prepareView()
    }
    
    override func prepareForInterfaceBuilder() {
        prepareView()
    }
    
    func prepareView (){
        layer.cornerRadius = 10
        
    }

}
