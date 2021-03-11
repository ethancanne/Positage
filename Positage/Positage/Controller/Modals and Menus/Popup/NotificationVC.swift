//
//  NotificationVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 4/8/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import Foundation
import UIKit

enum NotificationType {
    case error
    case inform
}

class NotificationVC: UIViewController {
    
    @IBOutlet weak var notificationView: PositageView!
    @IBOutlet weak var viewBottomCnstr: NSLayoutConstraint!
    @IBOutlet weak var notificationMsg: UILabel!
    @IBOutlet weak var notificationImg: UIImageView!
    
    var type: NotificationType = .inform
    var message: String = ""

    static var currentlyDisplayedNotificationVC: NotificationVC? = nil
    
    override func viewDidLoad() {
        let panGestrRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        notificationView.addGestureRecognizer(panGestrRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Animate
        self.viewBottomCnstr.constant = -(2 * self.notificationView.frame.height)
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
         UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                   self.viewBottomCnstr.constant = 30
                   self.view.layoutIfNeeded()
               }, completion: nil)
               
               notificationMsg.text = message
               
        
            //Provided a type, the notification is customized for its purpose, Error, Success, or just to Inform
               switch type {
               case NotificationType.error:
                   print("ERROR")
                   
                   //Image
                   notificationImg.image = UIImage(systemName: "exclamationmark.circle.fill")
                   notificationImg.tintColor = #colorLiteral(red: 0.7054536939, green: 0.1677121818, blue: 0.1322249174, alpha: 1)
                
                    //Notification Shadow
                   notificationView.shadowColor = #colorLiteral(red: 0.7054536939, green: 0.1677121818, blue: 0.1322249174, alpha: 0.7438950225)
                   notificationView.CustomizeView()
                    
               case NotificationType.inform:
                   print("INFORM")
                   
                   //Image
                   notificationImg.image = UIImage(systemName: "checkmark.circle")
                   notificationImg.tintColor = #colorLiteral(red: 0, green: 0.4396848679, blue: 0, alpha: 1)
                   
                   //Notification Shadow
                   notificationView.shadowColor = #colorLiteral(red: 0, green: 0.3130862713, blue: 0, alpha: 0.6956399701)
                   notificationView.CustomizeView()
                
                
               default: break
                
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.dismissNotification()
        }
    }
    
    
    func dismissNotification(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
            self.viewBottomCnstr.constant = -(2 * self.notificationView.frame.height)
            self.view.layoutIfNeeded()
        }){ (worked) in
            self.removeFromParent()
        }
        
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer){
           switch recognizer.state{
           case .began:
            print("Pan Began")
           case .changed:
            
            
            let translation = recognizer.translation(in: view)
            print(translation.y)
            viewBottomCnstr.constant -= (viewBottomCnstr.constant <= 30) ? (translation.y) :
                (translation.y / 4)
            view.layoutIfNeeded()
            recognizer.setTranslation(.zero, in: view)
            
            
           case .ended:
            let velocity = recognizer.velocity(in: view).y
           //250 velocity = flick
            
            if viewBottomCnstr.constant <= 15 || velocity >= 250 {
                dismissNotification()
            }else{
                //Put view back to where it was
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                    self.viewBottomCnstr.constant = 30
                    self.view.layoutIfNeeded()
                })
            }
           default:
               print("Pan Error")
           }
           
       }
    
    static func showNotification(withMessage msg: String, type: NotificationType){
        //Just in case there is already a notification shown, dismiss it so that the current one can be displayed (to avoid overlapping)
        if let currentNotificationVC = NotificationVC.currentlyDisplayedNotificationVC {
            currentNotificationVC.dismissNotification()
            NotificationVC.currentlyDisplayedNotificationVC = nil
        }
        
        //Set Up
        let notificationVC = instantiateViewController(fromStoryboard: "Popup", withIdentifier: "notificationVC") as! NotificationVC
        
        notificationVC.type = type
        notificationVC.message = msg
        currentlyDisplayedNotificationVC = notificationVC
        
        //Add to window
        guard let window = UIApplication.shared.keyWindow else { return }
        if let notificationView = notificationVC.view{
            notificationView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
            window.addSubview(notificationView)
        }

        
    }
    
    
}

class NotificationBackView: UIView {
    //Window and view requirements, so touches can be performed behind window:
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
    
    
    
}
