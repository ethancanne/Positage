//
//  LoadingVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 4/9/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit

class LoadingVC: UIViewController {
    
    @IBOutlet weak var loadingMsgLbl: UILabel!
    var message: String = "Loading"
    
    static var currentLoadingVC: LoadingVC? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        loadingMsgLbl.text = message
        view.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5){
            self.view.alpha = 1
        }
    }
    
    static func showLoadingScreen(withMessage msg: String = "Loading"){
        //Set Up
        let loadingVC = instantiateViewController(fromStoryboard: "Popup", withIdentifier: "loadingVC") as! LoadingVC
        
        currentLoadingVC = loadingVC
        loadingVC.message = msg
        
        //Add to window
        guard let window = UIApplication.shared.keyWindow else { return }
        if let loadingView = loadingVC.view{
            loadingView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
            window.addSubview(loadingView)
        }
        
    }
    
    static func dismissLoadingScreen(){
        if let currentLoadingVC = LoadingVC.currentLoadingVC{
            UIView.animate(withDuration: 0.5, animations: {
                currentLoadingVC.view.alpha = 0
            }, completion: {(worked) in
                currentLoadingVC.removeFromParent()
            })
            LoadingVC.currentLoadingVC = nil
        }
    }
    

}
