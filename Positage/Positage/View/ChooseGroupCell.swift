//
//  ChooseGroupCell.swift
//  Positage
//
//  Created by Ethan Cannelongo on 5/3/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit

class ChooseGroupCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var adminLbl: UILabel!
    @IBOutlet weak var numPostsLbl: UILabel!
    @IBOutlet weak var stampsReqLbl: UILabel!
    var group: Group!
    
    func configureCell(group: Group){
        self.group = group
        titleLbl.text = group.title
        adminLbl.text = group.adminUsername
        numPostsLbl.text = "Posts: \(group.joinedUsers.count)"
        stampsReqLbl.text = "Stamps Required: \(String(group.stampsToJoin))"
        }
    
    @IBAction func showdescriptionriptionTapped(_ sender: Any) {
        guard let window = UIApplication.shared.keyWindow else {return}
        var alert = UIAlertController(title: "Group Description", message: group.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        window.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
}
