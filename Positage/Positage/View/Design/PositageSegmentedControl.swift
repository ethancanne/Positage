//
//  PositageSegmentedControl.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/10/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit

@IBDesignable
class PositageSegmentedControl: UISegmentedControl {

    var underline: UIView = UIView()
    @IBInspectable var underlineColor: UIColor = #colorLiteral(red: 0.5895040631, green: 0.6752604842, blue: 0.7527205348, alpha: 1)
    override func awakeFromNib() {
        customize()
    }
    
    override func prepareForInterfaceBuilder() {
        customize()
    }
    
    func customize(){
        // Add lines below selectedSegmentIndex
        
        let backgroundImage = UIImage.getColoredRectImageWith(color: UIColor.clear.cgColor, andSize: self.bounds.size)
        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)

        let dividerImage = UIImage.getColoredRectImageWith(color: UIColor.clear.cgColor, andSize: CGSize(width: 1.0, height: self.bounds.size.height))
        self.setDividerImage(dividerImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Cambria-Bold", size: 20), NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Cambria-Bold", size: 20), NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        
        setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "Cambria-Bold", size: 18),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)

        setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "Cambria-Bold", size: 18),
            NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .selected)
        
        let underlineWidth: CGFloat = (self.bounds.size.width / CGFloat(self.numberOfSegments))
        let underlineHeight: CGFloat = 3
        let underlineXPosition = CGFloat((selectedSegmentIndex * Int(underlineWidth)))
        let underLineYPosition = self.bounds.size.height - 5.0
        let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
        bringSubviewToFront(underline)
        underline = UIView(frame: underlineFrame)
        underline.backgroundColor = #colorLiteral(red: 0.5895040631, green: 0.6752604842, blue: 0.7527205348, alpha: 1)
        self.addSubview(underline)
    }
    
    func changeUnderlinePosition(){
        let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(selectedSegmentIndex)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations:{
            self.underline.frame.origin.x = underlineFinalXPosition
        })
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations:{
            self.underline.frame.origin.x = (self.frame.width / CGFloat(self.numberOfSegments)) * CGFloat(self.selectedSegmentIndex)
            self.underline.backgroundColor = self.underlineColor

        })

    }
}

extension UIImage{
    class func getColoredRectImageWith(color: CGColor, andSize size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        graphicsContext?.fill(rectangle)
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectangleImage!
    }
}
