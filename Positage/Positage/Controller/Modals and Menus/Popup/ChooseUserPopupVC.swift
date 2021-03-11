//
//  RecipientVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 1/11/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

protocol ChooseUserDelegate {
    func didChooseUsers(users: [User])
}


import UIKit
class RecipientCell: UITableViewCell {
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var numStampsToSendLbl: UILabel!
    var user: User!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(user: User){
        self.user = user
        usernameLbl.text = user.username
        numStampsToSendLbl.text = "+"+String(user.numStampsToSend)
    }
    
}


import UIKit
import Firebase
class ChooseUserPopupVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var topMsgLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var users: [User] = []
    var searchedUsers: [User] = []

    public var delegate: ChooseUserDelegate?
    var selectedUsers: [User] = []
    var allowMultiple: Bool = false
    var isSearching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Firestore.firestore().collection(USERS_REF).getDocuments { (snapshot, error) in
            if let error = error{
                debugPrint("Error updating recipient tableView:\(error.localizedDescription)")
            }
            else {
                self.users = User.set(from: snapshot)
                self.tableView.reloadData()
            }
            self.tableView.allowsMultipleSelection = self.allowMultiple
        }
    }
    
    @IBAction func selectBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.delegate?.didChooseUsers(users: self.selectedUsers)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //TableView Protocol Stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isSearching) ? searchedUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "recipient") as? RecipientCell{
            cell.configureCell(user: (isSearching) ?  searchedUsers[indexPath.row] : users[indexPath.row])
            return cell
        }
        else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "recipient") as? RecipientCell{
            if !allowMultiple{
                selectedUsers.removeAll()
            }
            selectedUsers.append(users[indexPath.row])
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "recipient") as? RecipientCell{
            if let index = selectedUsers.firstIndex(where: {$0.userId == users[indexPath.row].userId}){
                selectedUsers.remove(at: index)
                cell.accessoryType = .checkmark
            }
        }
    }
    
    //Search Bar Stubs
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchTxt = searchBar.text{
            if searchTxt != "" {
                searchedUsers = users.filter{($0.username.lowercased().contains(searchTxt.lowercased()))}
                isSearching = true
            }else{
                isSearching = false
            }
        }
        tableView.reloadData()
    }
}
