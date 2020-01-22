//
//  InboxVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/23/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class InboxVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopCnstr: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIStackView!
    
    
    //Variables
    private var menuIsShown: Bool = false
    private var posts: [Post] = []
    private var postsCollectionRef: CollectionReference!
    private var postListener: ListenerRegistration!
    private var authHandle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        postsCollectionRef = Firestore.firestore().collection(POST_REF)
        tableView.estimatedRowHeight = 108
        tableView.rowHeight = UITableView.automaticDimension
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //MENU
        //Set Menu for entire application
        guard let window = UIApplication.shared.keyWindow else { return }
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        let menuVC = storyboard.instantiateViewController(withIdentifier: "MenuViewController")
        
        if let menuView = menuVC.view{
            menuView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
            window.addSubview(menuView)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppLocation.currentUserLocation = INBOX
        AppLocation.locationHidden = true
        ConfigureListener()
        authHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
            }
            else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
                self.present(loginVC, animated: true, completion: nil)
            }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if postListener != nil {
            postListener.remove()
        }
//        if menuIsShown{
//            showMenu()
//        }
    }
    
    
    //General Functions
    func ConfigureListener(){
       guard let user = Auth.auth().currentUser else { return }
        postListener = postsCollectionRef
            .whereField(TO_USERID, isEqualTo: user.uid)
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

    
    //Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsSegue" {
            let detailsVC = segue.destination as? DetailsVC
            let post = posts[(tableView.indexPathForSelectedRow?.row)!]

            detailsVC?.post = post
        }
    }
    
    
    //TableView Protocol Stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell") as? InboxTableViewCell {
            cell.ConfigureCell(post: posts[indexPath.row])
            return cell
        }
        else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select row at\(indexPath.row)")
        performSegue(withIdentifier: "detailsSegue", sender: self)
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
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        let bottomConstant:CGFloat = 280
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

}
