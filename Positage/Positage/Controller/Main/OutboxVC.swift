//
//  OutboxVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/6/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase


class OutboxVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, SearchDelegate {
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopCnstr: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIStackView!
    @IBOutlet weak var unreadNumLbl: UILabel!
    
    
    //Variables
    var isSearching: Bool = false
    
    
    private var posts: [Post] = []
    private var searchedPosts: [Post] = []

    private var postsCollectionRef: CollectionReference!
    private var postListener: ListenerRegistration!
    private var authHandle: AuthStateDidChangeListenerHandle!
    
    var isTBViewScrolledUp: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.setInsets(top: 0, bottom: 52, left: 0, right: 0)

        tableView.estimatedRowHeight = 108
        tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        ConfigureListener()
        AppLocation.locationHidden = !(isTBViewScrolledUp)
        AppLocation.currentUserLocation = OUTBOX
        AppLocation.currentMenuVC.searchDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if postListener != nil {
            postListener.remove()
        }
    }
    
    
    //General Functions
    func ConfigureListener(){
        guard let user = Auth.auth().currentUser else { return }
        postListener = DataService.database.collection(POST_REF)
            .whereField(FROM_USERID, isEqualTo: user.uid)
            .order(by: TIMESTAMP, descending: true)
            .addSnapshotListener
            {(snapshot, error) in
                if let err = error {
                    debugPrint("Error fetching docs: \(err)")
                }
                else{
                    self.posts = Post.set(from: snapshot)
                    self.tableView.reloadData()
                    
                    //Unread posts Lbl is updated with current amount of unread posts
                    self.unreadNumLbl.text = String(self.posts.filter{!($0.didRead)
                    }.count)
                }
        }
    }
    
    
    
    //TableView Protocol Stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isSearching) ? searchedPosts.count : posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post: Post = (isSearching) ? self.searchedPosts[indexPath.row] : self.posts[indexPath.row]
        if post is OngoingPost {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "outboxOngoingPostCell") as? OutboxTBViewCell {
                cell.configure(post: post as! OngoingPost)
                return cell
            }
            else{
                return UITableViewCell()
            }
        }else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "outboxPostCell") as? OutboxTBViewCell {
                cell.configure(post: post)
                return cell
            }
            else{
                return UITableViewCell()
            }
        }
    }
    
    var prevOpenedIndexPath: IndexPath!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select row at\(indexPath.row)")
        
        //toggleDetails returns true if opened, false if closed
        let didOpen: Bool = ((tableView.cellForRow(at: indexPath) as! OutboxTBViewCell).toggleDetails())
        
        //First check if the selected index path isn't the same as the previous one (don't toggle twice) and isn't nil.  Then close the previous row ONLY after opening the selected row
        if (indexPath != prevOpenedIndexPath) && (prevOpenedIndexPath != nil) && didOpen{
            (tableView.cellForRow(at: prevOpenedIndexPath) as! OutboxTBViewCell).toggleDetails()
        }
        
        //Don't save closed indexPaths
        prevOpenedIndexPath = (didOpen) ? indexPath : nil
        
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)

        if !isTBViewScrolledUp {
            scrollTBView(isUp: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let postId = posts[indexPath.row].documentId
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            let alert = UIAlertController(title: "Delete?", message: "Are you sure you want to delete this post? \(self.posts[indexPath.row].title)", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alert) in
                self.posts.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                Firestore.firestore().collection(POST_REF).document(postId).delete(completion: { (error) in
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
        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        print(scrollView.contentOffset)
        
        let isUp =  (scrollView.contentOffset.y > 0)
        
        if scrollView.contentOffset.y != 0{
            scrollTBView(isUp: isUp)
        }
    }
    
    func scrollTBView(isUp: Bool){
        let bottomConstant:CGFloat = 236
        let topConstant:CGFloat = 96
               
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            AppLocation.locationHidden = (isUp) ? false : true
            self.headerView.alpha = (isUp) ? 0 : 1
            self.tableViewTopCnstr.constant = (isUp) ? topConstant : bottomConstant
            self.view.layoutIfNeeded()
        })
        isTBViewScrolledUp = isUp
    }
    
    
    
    //Search Stubs
    func searchDidChange(with text: String) {
        if text != ""{
            isSearching = true
            searchedPosts = posts.filter{($0.title.lowercased().contains(text))}
            

        } else {
            isSearching = false
            
            view.endEditing(true)
        }
        
        //close any row before reloading
        if prevOpenedIndexPath != nil{
            (tableView.cellForRow(at: prevOpenedIndexPath) as! OutboxTBViewCell).toggleDetails()
            prevOpenedIndexPath = nil
        }
        tableView.reloadData()
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    let bottomConstant:CGFloat = 280
//    let topConstant:CGFloat = 130
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        let offset = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y
//
//        print(offset)
//
//
//        if tableViewTopCnstr.constant < bottomConstant && tableViewTopCnstr.constant > topConstant && offset < 0  {
//            UIView.animate(withDuration: 0.3, animations:{
//                self.headerView.alpha = 0
//                self.tableViewTopCnstr.constant = self.topConstant
//                self.view.layoutIfNeeded()
//            })
//            AppLocation.locationHidden = false
//        }else if tableViewTopCnstr.constant > topConstant && tableViewTopCnstr.constant < bottomConstant && offset > 0{
//            UIView.animate(withDuration: 0.3, animations:{
//                self.headerView.alpha = 1
//                self.tableViewTopCnstr.constant = self.bottomConstant
//                self.view.layoutIfNeeded()
//            })
//            AppLocation.locationHidden = true
//        }
//    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        var offset = scrollView.contentOffset.y
//        //Scrolling up, tableview constant goes up to top constant with drag
//        if scrollView.contentOffset.y >= 0{
//            if tableViewTopCnstr.constant >= topConstant   {
//                self.headerView.alpha -= -(offset/500)
//                self.tableViewTopCnstr.constant -= offset
//                self.view.layoutIfNeeded()
//            }
//
//            //Scrolling down, tableview constant goes down to bottom constant once user hits top of tableview
//        }else if scrollView.contentOffset.y <= 0{
//            if tableViewTopCnstr.constant <= bottomConstant{
//                self.headerView.alpha -= (offset/500)
//                self.tableViewTopCnstr.constant -= offset
//                self.view.layoutIfNeeded()
//            }
//        }
//    }
    
}
