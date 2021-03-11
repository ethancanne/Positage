//
//  ChooseGroupVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 5/3/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

protocol GroupDelegate {
    func didSelectGroup(group: Group)
}

class ChooseGroupVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Variables
    var delegate: GroupDelegate?
    var groups: [Group] = []
    var groupListener: ListenerRegistration!
    var groupCollectionRef = Firestore.firestore().collection(GROUPS_REF)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ConfigureListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        groupListener.remove()
    }
    
    func ConfigureListener(){
        groupListener = groupCollectionRef
            .addSnapshotListener
            {(snapshot, error) in
                if let err = error {
                    debugPrint("Error fetching docs: \(err)")
                }
                else{
                    self.groups.removeAll()
                    self.groups = Group.set(from: snapshot)
                    self.tableView.reloadData()
                    
                }
        }
    }
    
    //Table View Protocol Stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as? ChooseGroupCell{
            cell.configureCell(group: groups[indexPath.row])
            return cell
        }
        else{
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectGroup(group: groups[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

}
