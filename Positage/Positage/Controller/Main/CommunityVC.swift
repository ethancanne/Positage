//
//  CommunityVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/28/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase


class CommunityVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate, ChooseGroupDelegate, SearchDelegate, UserListenerDelegate, ChoiceDelegate {
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: PositageSegmentedControl!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var tableViewTopCnstr: NSLayoutConstraint!
    
    @IBOutlet weak var numSupportsRemainingLbl: UILabel!
    
    @IBOutlet var tbGroupHeaderView: UIView!
    @IBOutlet weak var groupNameLbl: UILabel!
    @IBOutlet weak var groupDescLbl: UILabel!
    @IBOutlet weak var sortByBtn: PositageButton!
    
    //Variables
    var isSearching = false
    var isTBViewScrolledUp: Bool = false
    
    var selectedGroup: Group?{
        didSet{
            if communityPostsListener != nil{
                communityPostsListener.remove()
            }
            ConfigureListener()
        }
    }
    
    var entries: [Entry] = []
    var searchedEntries: [Entry] = []
    
    private var communityPostsListener: ListenerRegistration!
    private var userListener: ListenerRegistration!
    
    
    //PopUpVariables
    var chooseGroupVC: ChooseGroupVC!
    var backgroundView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.setInsets(top: 0, bottom: 102, left: 0, right: 0)
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 80
        
        tbGroupHeaderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeGroupBtnTapped)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppLocation.currentUserLocation = COMMUNITY
        AppLocation.currentMenuVC.searchDelegate = self
        
        ConfigureListener()
        
        numSupportsRemainingLbl.text = String(DataService.currentUser!.numSupportsRemaining)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
    
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if communityPostsListener != nil {
            communityPostsListener.remove()
        }
        DataService.userListenerDelegate = nil
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    @objc func tappedOnSegment(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 1 {
            print("HELLO")
        }
    }
    
    
    //Segmented Control Tapped
    @IBAction func sortingChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex{
        
        case 0: segmentControl.underlineColor = #colorLiteral(red: 0.5895040631, green: 0.6752604842, blue: 0.7527205348, alpha: 1)
        case 1: segmentControl.underlineColor = #colorLiteral(red: 0.7741701603, green: 0.3519945741, blue: 0.06768070906, alpha: 1)
        case 2:segmentControl.underlineColor = #colorLiteral(red: 0.1823700368, green: 0.3285570443, blue: 0.5826966166, alpha: 1)
            
        default: break
        }
        
        segmentControl.changeUnderlinePosition()
        
        if communityPostsListener != nil{
            communityPostsListener.remove()
        }
        ConfigureListener()
        
    }
    
    @IBAction func sortByButtonTapped(_ sender: Any) {
        PopupVC.showChoicePopup(from: self, with: [Choice(title: "Popularity", style: .normal), Choice(title: "Recent", style: .normal), Choice(title: "Investments", style: .normal)], title: "Sort By:")
    }
    
    func didSelectChoice(choice: String) {
        var sortingBool: Bool = false
        entries.sort(by: { (entry1, entry2) -> Bool in
            switch choice{
            case "Popularity": sortingBool = entry1.numSupports > entry2.numSupports
                
            case "Recent":  sortingBool = entry1.timestamp > entry2.timestamp
                
            case "Investments": sortingBool = entry1.usersInvested.count > entry2.usersInvested.count
                
            default: break

            }
            return sortingBool
        })
        sortByBtn.setTitle("SORT BY (\(choice))", for: .normal)
        tableView.reloadData()
    }
    
    
    
    
    //General Functions
    func ConfigureListener(){
        if let group = selectedGroup { //Filter Group Tab
            var entriesRef: String = "\(GROUPS_REF)/\(group.documentId)/\(ENTRY_REF)"
            if segmentControl.selectedSegmentIndex == 0{
                communityPostsListener = Firestore.firestore().collection(entriesRef)
                    .order(by: TIMESTAMP, descending: true)
                    .addSnapshotListener
                    {(snapshot, error) in
                        if let err = error {
                            debugPrint("Error fetching docs: \(err)")
                        }
                        else{
                            print(snapshot!.isEmpty)
                            self.entries.removeAll()
                            self.entries = Entry.set(from: snapshot)
                            self.tableView.reloadData()
                        }
                        
                }
            } else if (segmentControl.selectedSegmentIndex == 1){ //Supported Tab
                communityPostsListener = Firestore.firestore().collection(entriesRef)
                    .whereField(USERS_SUPPORTED, arrayContains: DataService.currentUser?.userId)
                    .addSnapshotListener
                    {(snapshot, error) in
                        if let err = error {
                            debugPrint("Error fetching docs: \(err)")
                        }
                        else{
                            print(snapshot!.isEmpty)
                            self.entries.removeAll()
                            self.entries = Entry.set(from: snapshot)
                            self.tableView.reloadData()
                        }
                        
                }
                
            } else if segmentControl.selectedSegmentIndex == 2{  //Invested tab
                communityPostsListener = Firestore.firestore().collection(entriesRef)
                    .whereField(("\(USERS_INVESTED).\(DataService.currentUser!.userId)"), isGreaterThan: [])
                    
                    .addSnapshotListener
                    {(snapshot, error) in
                        if let err = error {
                            debugPrint("Error fetching docs: \(err)")
                        }
                        else{
                            print(snapshot!.isEmpty)
                            self.entries.removeAll()
                            self.entries = Entry.set(from: snapshot)
                            self.tableView.reloadData()
                        }
                        
                }
                
            }
            
        }
        
        DataService.userListenerDelegate = self
        
    }
    
    func currentUserDataDidChange(user: User) {
        numSupportsRemainingLbl.text = String(user.numSupportsRemaining)
    }
    
    
    @objc func changeGroupBtnTapped(_ sender: Any) {
        PopupVC.showChooseGroupPopup(from: self)
    }
    func didChooseGroup(group: Group) {
        self.selectedGroup = group
    }
    
    
    
    //Table View Protocol Stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isSearching) ? searchedEntries.count : entries.count
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        groupNameLbl.text = selectedGroup?.title ?? "Hello"
        groupDescLbl.text = selectedGroup?.description ?? "Tap here to select a group"
        
        return tbGroupHeaderView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry: Entry = (isSearching) ? self.searchedEntries[indexPath.row] : self.entries[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "communityCell") as? CommunityTableViewCell, let selectedGroup = selectedGroup{
            cell.ConfigureCell(entry: entry, group: selectedGroup)
            return cell
        }
        else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let report = UITableViewRowAction(style: .normal, title: "Report") { (action, indexPath) in
            print("\(self.entries[indexPath.row].title) has been reported.")
        }
        return [report]
    }
    
    
    //Tableview scrolling animations
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomConstant:CGFloat = 270
        let topConstant:CGFloat = 96
        
        print(scrollView.contentOffset)
        
        let isGoingUp =  (scrollView.contentOffset.y > 0)
        
        if scrollView.contentOffset.y != 0{
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                AppLocation.locationHidden = (isGoingUp) ? false : true
                self.headerView.alpha = (isGoingUp) ? 0 : 1
                self.tableViewTopCnstr.constant = (isGoingUp) ? topConstant : bottomConstant
                self.tbGroupHeaderView.alpha = ((scrollView.contentOffset.y > 15)) ? 0 : 1
                self.view.layoutIfNeeded()
            })
            isTBViewScrolledUp = isGoingUp
            
        }
    }
    
    
    //Search Stubs
    func searchDidChange(with text: String) {
        if text != ""{
            isSearching = true
            searchedEntries = entries.filter({$0.username.contains(text) || $0.message.contains(text) || $0.title.contains(text)})
        } else {
            isSearching = false
            view.endEditing(true)
        }
        
        tableView.reloadData()
    }
}
