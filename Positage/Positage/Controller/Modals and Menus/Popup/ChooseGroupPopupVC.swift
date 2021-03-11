//
//  ChooseGroupPopupVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/21/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase
class GroupTblViewCell: UITableViewCell, PaymentDelegate, ChoiceDelegate, ChooseUserDelegate {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionTxtView: UITextView!
    @IBOutlet weak var adminUsernameLbl: UILabel!
    @IBOutlet weak var stampsNumLbl: UILabel!
    @IBOutlet weak var numEntriesLbl: UILabel!
    @IBOutlet weak var usersNumLbl: UILabel!
    @IBOutlet weak var joinBtn: PositageButton!
    @IBOutlet weak var stampsToJoinStckView: UIStackView!
    
    public var delegate: ChooseGroupDelegate?
    
    var group: Group!
    var isJoined: Bool = false
    var isCreated: Bool = false

    func configure(group: Group, delegate: ChooseGroupDelegate){
        
        self.group = group
        self.delegate = delegate
        
        if let user = DataService.currentUser{
            self.isJoined = group.joinedUsers.contains(user.userId)
            self.isCreated = group.adminUserId == user.userId
        }
        
        joinBtn.setTitle((isCreated) ? "Options" : (isJoined) ? "Select" : "Join", for: .normal)
        
        stampsToJoinStckView.isHidden = (isJoined) ? true : false
        
        titleLbl.text = group.title
        descriptionTxtView.text = group.description
        adminUsernameLbl.text = group.adminUsername
        stampsNumLbl.text = String(group.stampsToJoin)
        usersNumLbl.text = String(group.joinedUsers.count)
        numEntriesLbl.text = String(group.numEntries)
        
    }
    
    @IBAction func joinSelectTapped(_ sender: Any) {
        
        if isCreated {
            PopupVC.showChoicePopup(from: self, with: [Choice(title: "Select", style: .normal), Choice(title: "Invite Users", style: .normal), Choice(title: "Reset Cycle", style: .destructive), Choice(title: "Delete", style: .destructive)], title: "Manage Group: \(group.title)")
        }
        else if isJoined{
            getCurrentViewController()?.dismiss(animated: true, completion: nil)
            delegate?.didChooseGroup(group: group)
        }else{
            PopupVC.showPaymentPopup(with: [Price(label: "Join Group:  \(group.title)", numStamps: group.stampsToJoin)], from: self)
        }
        
    }
    
    //Manage group
    func didSelectChoice(choice: String) {
        switch choice{
        case "Select":
            getCurrentViewController()?.dismiss(animated: true, completion: nil)
            delegate?.didChooseGroup(group: group)
        case "Invite Users":
            PopupVC.showChooseUserPopup(from: self, allowMultiple: true)
        case "Delete":
            print("Delete!")
        default:
            print("Default!")
        }
    }
    //Add invite via manage group
    func didChooseUsers(users: [User]) {
        var inviteesIDs: [String] = []
        users.forEach { (user) in
            if !(group.joinedUsers.contains(user.userId)){
                inviteesIDs.append(user.userId)
            }
        }
        DataService.database.collection(GROUPS_REF).document(group.documentId).updateData([INVITED_USERS:   FieldValue.arrayUnion(inviteesIDs)]){ (err) in
            if let error = err {
                debugPrint("Error inviting user to group:  \(error)")
            }else{
                getCurrentViewController()?.dismiss(animated: true)
                NotificationVC.showNotification(withMessage: "Sucessfully invited \(users.count) users", type: .inform)
            }
        }
    }
    
    
    func didReturnFromPayment(isSuccessfull: Bool) {
        if isSuccessfull {
            DataService.database.document("\(GROUPS_REF)/\(group.documentId)").updateData([
                JOINED_USERS : FieldValue.arrayUnion([DataService.currentUser?.userId]),
                INVITED_USERS : FieldValue.arrayRemove([DataService.currentUser?.userId])
            ]){ err in
                LoadingVC.dismissLoadingScreen()
                
                if let err = err {
                    NotificationVC.showNotification(withMessage: "There has been an error joining this group.", type: .error)
                    print("Error writing document: \(err)")
                } else {
                    NotificationVC.showNotification(withMessage: "Group: \(self.group.title) has been sucessfully joined.", type: .inform)
                    print("Document successfully written!")
                    getCurrentViewController()?.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        
    }
    
}

protocol ChooseGroupDelegate {
    func didChooseGroup(group: Group)
}
class ChooseGroupPopupVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, ChooseUserDelegate {
    
    var groups: [Group] = []
    var searchedGroups: [Group] = []
    
    var isSearching: Bool = false
    var groupListener: ListenerRegistration!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedView: PositageSegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    public var delegate: ChooseGroupDelegate?
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.setInsets(top: 0, bottom: 300, left: 0, right: 0)
        tableView.estimatedRowHeight = 252
        
    }
    override func viewWillAppear(_ animated: Bool) {
        configureListener()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        groupListener.remove()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func configureListener(){
        if groupListener != nil{
            groupListener.remove()
        }
        
        groupListener = DataService.database.collection(GROUPS_REF)
            .addSnapshotListener {(snapshot, error) in
                if let err = error {
                    debugPrint("Error fetching docs: \(err)")
                }
                else{
                    self.groups = Group.set(from: snapshot)
                    
                    switch self.segmentedView.selectedSegmentIndex{
                    
                        
                    case 0: //Created Groups
                        self.groups = self.groups.filter{($0.joinedUsers.contains(DataService.currentUser!.userId) == true) && $0.adminUserId != DataService.currentUser!.userId}
                        
                    case 1: //Joined Groups (But not created)
                        self.groups = self.groups.filter{($0.adminUserId == DataService.currentUser!.userId)}
                        
                    case 2: //Non Joined Groups (Not created)
                        self.groups = self.groups.filter{($0.joinedUsers.contains(DataService.currentUser!.userId) == false && $0.isPrivate == false)}
                        
                    default:
                        fatalError("Unexpected Selected Segment Index for Choose Group View")
                        
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
    
    @IBAction func sortingChanged(_ sender: Any) {
        segmentedView.changeUnderlinePosition()
        searchBar.text = nil
        configureListener()
        
    }
    
    //TableView Stubs
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isSearching) ? searchedGroups.count : groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as? GroupTblViewCell {
            cell.configure(group: (isSearching) ? searchedGroups[indexPath.row] : groups[indexPath.row], delegate: delegate!)
            return cell
        }
        else{
            return UITableViewCell()
        }
        
        
    }
    
    
    var chosenManageGroupId: String!

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if self.groups[indexPath.row].adminUserId == DataService.currentUser?.userId {
            
            let manageAction = UIContextualAction(style: .normal, title: "Manage") { (action, view, success)  in
                self.chosenManageGroupId = self.groups[indexPath.row].documentId
                PopupVC.showChoicePopup(from: self, with: [Choice(title: "Invite Users", style: .normal), Choice(title: "Delete", style: .destructive)], title: "Manage Group: \(self.groups[indexPath.row].title)")
            }
            return UISwipeActionsConfiguration(actions: [manageAction])
        }
        return nil
        
        
    }
    
    
    //Manage group
    func didSelectChoice(choice: String) {
        switch choice{
        case "Invite Users":
            print("Invite!")
            PopupVC.showChooseUserPopup(from: self, allowMultiple: true)
        case "Delete":
            print("Delete!")
        default:
            print("Default!")
        }
    }
    //Add invite via manage group
    func didChooseUsers(users: [User]) {
        var inviteesIDs: [String] = []
        users.forEach { (user) in
            inviteesIDs.append(user.userId)
        }
        DataService.database.collection(GROUPS_REF).document(chosenManageGroupId).updateData([INVITED_USERS:   FieldValue.arrayUnion(inviteesIDs)]){ (err) in
            if let error = err {
                debugPrint("Error inviting user to group:  \(error)")
            }else{
                getCurrentViewController()?.dismiss(animated: true)
                NotificationVC.showNotification(withMessage: "Sucessfully invited \(users.count) users", type: .inform)
            }
        }
    }
    
    //Search bar Stubs
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchedText = searchBar.text?.lowercased(){
            if searchedText != ""{
                isSearching = true
                searchedGroups = groups.filter{($0.adminUsername.lowercased().contains(searchedText)) || ($0.title.lowercased().contains(searchedText)) || ($0.description.lowercased().contains(searchedText))}
            } else {
                isSearching = false
                view.endEditing(true)
            }
            
            tableView.reloadData()
        }
    }
    
    
}
