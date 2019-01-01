//
//  DetailsVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/27/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit

class DetailsVC: UIViewController {
    
    //Outlets
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var fromUserLbl: UILabel!
    @IBOutlet private weak var timestampLbl: UILabel!
    @IBOutlet private weak var dataTxtView: PositageTextView!
    
    //Variables
    var postData: String = ""
    var postTitle: String = ""
    var timestamp: String = ""
    var fromUsername: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleLbl.text = postTitle
        dataTxtView.text = postData
        timestampLbl.text = timestamp
        fromUserLbl.text = fromUsername
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
    
    
    
    
}
