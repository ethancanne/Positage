//
//  UITabBarViewExt.swift
//  Positage
//
//  Created by Ethan Cannelongo on 5/4/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import Foundation
import UIKit

extension UITabBar{
    
    func setTabBarVisible(visible: Bool, animated: Bool) {
        let height = frame.size.height
        let offsetY = (visible ? -height : height)
        let duration: TimeInterval = (animated ? 0.3 : 0.0)
        
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { [weak self] () -> Void in
                        guard let weakSelf = self else { return }
                        weakSelf.frame = weakSelf.frame.offsetBy(dx: 0, dy: offsetY)
                        weakSelf.setNeedsDisplay()
                        weakSelf.layoutIfNeeded()
        })
    }
    
    func tabBarIsVisible() -> Bool {
        return frame.origin.y < UIScreen.main.bounds.height
    }
    
    
}
