//
//  CommunityVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/28/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase


class CommunityVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortDataSegment: UISegmentedControl!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var tableViewTopCnstr: NSLayoutConstraint!
    
    
    //Variables
    var selectedGroup: Group!
    var posts: [Post] = []
    var filteredPosts: [Post] = []
    var isSearching = false
    private var postsCollectionRef: CollectionReference!
    private var postListener: ListenerRegistration!
    private var menuIsShown: Bool = false;
    
    //PopUpVariables
    var chooseGroupVC: ChooseGroupVC!
    var backgroundView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsCollectionRef = Firestore.firestore().collection("\(GROUPS_REF)/main/\(POST_REF)")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //Segment UI
        let attrSelected = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 12), NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        let attrNormal = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 10), NSAttributedString.Key.foregroundColor: UIColor.gray]
        
        sortDataSegment.tintColor = UIColor.clear

        
        sortDataSegment.setTitleTextAttributes(attrSelected, for: .selected)
        sortDataSegment.setTitleTextAttributes(attrNormal, for: .normal)

        self.sortDataSegment.layer.cornerRadius = 0
        self.sortDataSegment.layer.borderColor = UIColor.white.cgColor
        self.sortDataSegment.layer.borderWidth = 0
        self.sortDataSegment.layer.masksToBounds = true
        
        selectedGroup = Group(adminUsername: "main", adminUserId: "main", groupDesc: "main", groupName: "main", stampsToPost: 0, numPosts: 0, documentId: "main")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppLocation.currentUserLocation = COMMUNITY
        ConfigureListener()
        sortDataSegment.layer.borderColor = UIColor.white.cgColor
        sortDataSegment.layer.cornerRadius = 0.0
        sortDataSegment.layer.borderWidth = 1
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if postListener != nil {
            postListener.remove()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    

    //Segmented Control Tapped
    @IBAction func sortingChanged(_ sender: Any) {
        postListener.remove()
        ConfigureListener()
        
    }
    
    
    //General Functions
    func ConfigureListener(){
        if sortDataSegment.selectedSegmentIndex == 0{
            postListener = postsCollectionRef
                .whereField(POST_IS_COMMUNITY, isEqualTo: true)
                .order(by: POST_IS_PROMOTED, descending: true)
                .order(by: TIMESTAMP, descending: true)
                .addSnapshotListener
                {(snapshot, error) in
                    if let err = error {
                        debugPrint("Error fetching docs: \(err)")
                    }
                    else{
                        self.posts.removeAll()
                        self.posts = Post.setPost(from: snapshot)
                        self.tableView.reloadData()
                    }
                    
            }
        }
        else {
            postListener = postsCollectionRef
                .whereField(POST_IS_COMMUNITY, isEqualTo: true)
                .order(by: NUM_SUPPORTS, descending: true)
                .addSnapshotListener
                {(snapshot, error) in
                    if let err = error {
                        debugPrint("Error fetching docs: \(err)")
                    }
                    else{
                        self.posts.removeAll()
                        self.posts = Post.setPost(from: snapshot)
                        self.tableView.reloadData()
                    }
                    
            }
        }
        
    }
    
    
    
    
    //Table View Protocol Stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredPosts.count
        }
        else{
            return posts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "communityCell") as? CommunityTableViewCell{
            if isSearching {
                cell.ConfigureCell(post: filteredPosts[indexPath.row], group: selectedGroup)
            }
            else {
                cell.ConfigureCell(post: posts[indexPath.row], group: selectedGroup)
            }
            return cell
        }
        else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let report = UITableViewRowAction(style: .normal, title: "Report") { (action, indexPath) in
            print("\(self.posts[indexPath.row].title) has been reported.")
        }
        return [report]
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        let bottomConstant:CGFloat = 314
        let topConstant:CGFloat = 130

        print(scrollView.contentOffset)
        if actualPosition.y < 0 && scrollView.contentOffset.y > 0{
            if tableViewTopCnstr.constant == bottomConstant {
                AppLocation.locationHidden = false
                UIView.animate(withDuration: 0.3, animations:{
                    self.headerView.alpha = 0
                    self.tableViewTopCnstr.constant = topConstant
                    self.view.layoutIfNeeded()
                } )
                
            }
            
        }else if tableViewTopCnstr.constant == topConstant && scrollView.contentOffset.y < 0{
            AppLocation.locationHidden = true
            UIView.animate(withDuration: 0.3, animations:{
                self.headerView.alpha = 1
                self.tableViewTopCnstr.constant = bottomConstant
                self.view.layoutIfNeeded()
            } )
        }
    }
    
    //Search Bar Protocol Stubs
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        }
        else{
            guard let searchTxt = searchBar.text else { return }
            filteredPosts = posts.filter({$0.fromUsername.contains(searchTxt) || $0.data.contains(searchTxt) || $0.title.contains(searchTxt)})
            isSearching = true
            tableView.reloadData()
        }
        
    }
}

//extension CommunityVC: GroupDelegate {
//    func didSelectGroup(group: Group) {
//        guard let user = Auth.auth().currentUser else { return }
//        groupNameLbl.text = group.groupName
//        selectedGroup = Group(adminUsername: group.adminUsername, adminUserId: group.adminUserId, groupDesc: group.groupDesc, groupName: group.groupName, stampsToPost: group.stampsToPost, numPosts: group.numPosts, documentId: group.documentId)
//
//    dismissChooseGroupView()
//
//        postsCollectionRef = Firestore.firestore().collection("\(GROUPS_REF)/\(selectedGroup!.documentId)/\(POST_REF)")
//
//        postListener.remove()
//        ConfigureListener()
//
//    }
//}
