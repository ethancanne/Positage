//
//  InboxVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/23/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class InboxVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ChooseGroupDelegate, SearchDelegate {
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopCnstr: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIStackView!
    @IBOutlet weak var unreadPostsNumLbl: UILabel!
    
    var isSearching: Bool = false
    
    //Variables
    private var items: [Creatable] = [] //Use reserved word "is" to access the Posts, OngoingPosts, or Groups
    private var searchedItems: [Creatable] = []
    private var postListener: ListenerRegistration!
    private var groupListener: ListenerRegistration!
    private var authHandle: AuthStateDidChangeListenerHandle!
    
    
    var isTBViewScrolledUp: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.setInsets(top: 0, bottom: 52, left: 0, right: 0)
        
        //MENU
            //Set Menu for entire application
            guard let window = UIApplication.shared.keyWindow else { return }
            let storyboard = UIStoryboard(name: "Menu", bundle: nil)
            let menuVC = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuVC
            AppLocation.currentMenuVC = (menuVC)
            AppLocation.currentTabBarVC = tabBarController
            
            if let menuView = menuVC.view{
                menuView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
                window.addSubview(menuView)
            }
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ConfigureListener()
        AppLocation.locationHidden = !(isTBViewScrolledUp)
        AppLocation.currentUserLocation = INBOX
        
        AppLocation.currentMenuVC.searchDelegate = self

    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if postListener != nil {
            postListener.remove()
        }
        if groupListener != nil{
            groupListener.remove()
        }
    }
    
    
    //General Functions
    func ConfigureListener(){
        guard let user = Auth.auth().currentUser else { return }
        postListener = Firestore.firestore().collection(POST_REF)
            .whereField(TO_USERID, isEqualTo: user.uid)
            .order(by: TIMESTAMP, descending: true)
            .addSnapshotListener
            {(snapshot, error) in
                if let err = error {
                    debugPrint("Error fetching docs: \(err)")
                }
                else{
                    self.items.removeAll{$0 is Post}
                    self.items += Post.set(from: snapshot)
                    
                    //Unread posts Lbl is updated with current amount of unread posts
                    self.unreadPostsNumLbl.text = String(self.items.filter{
                        ($0 is Post) && !(($0 as! Post).didRead)
                    }.count)
                    
                    //Sort the items array so that posts and invitations are sorted based on timestamp
                    self.items.sort{$0.timestamp > $1.timestamp}
                    self.tableView.reloadData()
                }
        }
        
        groupListener = DataService.database.collection(GROUPS_REF)
            .whereField(INVITED_USERS, arrayContains: user.uid)
            .order(by: TIMESTAMP, descending: true)
            .addSnapshotListener
            {(snapshot, error) in
                if let err = error {
                    debugPrint("Error fetching docs: \(err)")
                }
                else if snapshot != nil{
                    //All group invitation in the item array are removed and then re-added with any updates applied
                    self.items.removeAll{$0 is Group}
                    self.items += Group.set(from: snapshot)
                    
                    //Sort the items array so that posts and invitations are sorted based on timestamp
                    self.items.sort{$0.timestamp > $1.timestamp}
                    self.tableView.reloadData()
                }
        }
    }
    
    
    //Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsSegue" {
            let detailsVC = segue.destination as? DetailsVC
            let post = items[(tableView.indexPathForSelectedRow?.row)!]
            detailsVC?.post = post as! Post
            
            if(AppLocation.currentMenuVC.isMenuOpen ){
                AppLocation.currentMenuVC.toggleMenu()
                AppLocation.currentMenuVC.toggleTabBar()
            }
        }
    }
    
    //Once group invite is chosen
    func didChooseGroup(group: Group) {
        
    }
    
    //TableView Protocol Stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isSearching) ? searchedItems.count : items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: Creatable = (isSearching) ? self.searchedItems[indexPath.row] : self.items[indexPath.row]
        if item is OngoingPost {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ongoingPostCell") as? OngoingPostTableViewCell {
                cell.ConfigureCell(ongoingPost: item as! OngoingPost)
                return cell
            }
            
        } else if items[indexPath.row] is Post {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell") as? InboxTableViewCell {
                cell.ConfigureCell(post: item as! Post)
                return cell
            }
            
        } else if items[indexPath.row] is Group {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "groupInvitationCell") as? GroupTblViewCell {
                cell.configure(group: item as! Group, delegate: self)
                return cell
            }
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select row at\(indexPath.row)")
        if items[indexPath.row] is Post{
            performSegue(withIdentifier: "detailsSegue", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var itemId: String?
        var title: String?
        
        if items[indexPath.row] is Post{
            itemId = (items[indexPath.row] as! Post).documentId
            title = (items[indexPath.row] as! Post).title
            
        }else{
            itemId = (items[indexPath.row] as! Group).documentId
            title = (items[indexPath.row] as! Group).title
        }
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            let alert = UIAlertController(title: "Delete?", message: "Are you sure you want to delete this post? \(title!)", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alert) in
                self.items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                Firestore.firestore().collection(POST_REF).document(itemId!).delete(completion: { (error) in
                    if let error = error {
                        debugPrint("Error deleting document:\(error.localizedDescription)")
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        return [delete]
    }
    
    
    
    //Tableview scrolling animations
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomConstant:CGFloat = 236
        let topConstant:CGFloat = 96
        
        print(scrollView.contentOffset)
        
        let isGoingUp =  (scrollView.contentOffset.y > 0)
        
        if scrollView.contentOffset.y != 0{
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                AppLocation.locationHidden = (isGoingUp) ? false : true
                self.headerView.alpha = (isGoingUp) ? 0 : 1
                self.tableViewTopCnstr.constant = (isGoingUp) ? topConstant : bottomConstant
                self.view.layoutIfNeeded()
            })
            isTBViewScrolledUp = isGoingUp
            
        }
    
    }
//    func scrollTBView(up: Bool){
//        let topConstant:CGFloat = 140
//        let bottomConstant:CGFloat = 280
//        if up && tableViewTopCnstr.constant != topConstant{
//            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
//                AppLocation.locationHidden = false
//                self.headerView.alpha = 0
//                self.tableViewTopCnstr.constant = topConstant
//                self.view.layoutIfNeeded()
//            })
//            isTBViewScrolledUp = true
//        }else if !up && tableViewTopCnstr.constant != bottomConstant{
//            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
//                AppLocation.locationHidden = true
//                self.headerView.alpha = 1
//                self.tableViewTopCnstr.constant = bottomConstant
//                self.view.layoutIfNeeded()
//            })
//            isTBViewScrolledUp = false
//        }
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
//        let bottomConstant:CGFloat = 280
//        let topConstant:CGFloat = 140
//
//        print(scrollView.contentOffset)
//        if actualPosition.y < 0 && scrollView.contentOffset.y > 0{
//            if tableViewTopCnstr.constant == bottomConstant {
//                scrollTBView(up: true)
//            }
//        } else if tableViewTopCnstr.constant == topConstant && scrollView.contentOffset.y < 0{
//            scrollTBView(up: false)
//        }
//    }
    
    //Search Stubs
    func searchDidChange(with text: String) {
        if text != ""{
            isSearching = true
            searchedItems = items.filter{($0.title.lowercased().contains(text)) }
        } else {
            isSearching = false
            view.endEditing(true)
        }
        
        tableView.reloadData()
    }

    
}
