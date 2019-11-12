//
//  InboxVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/23/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class InboxVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //Outlets
    @IBOutlet weak var menuArrowLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuStackView: UIStackView!
    @IBOutlet weak var userBarTopCnstr: NSLayoutConstraint!
    
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
        
        let menuTapped = UITapGestureRecognizer(target: self, action: #selector(showMenu))
        menuStackView.isUserInteractionEnabled = true

        menuStackView.addGestureRecognizer(menuTapped)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ConfigureListener()
        
        

        authHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                //Present alert

//               let alertView = UIAlertController(title: "Success", message: "\(user.displayName!) has successfully logged in!", preferredStyle: .actionSheet)
//                let action = UIAlertAction(title: "OK", style: .default)
//                alertView.addAction(action)
//                self.present(alertView, animated: true, completion: nil)
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
        if menuIsShown{
            showMenu()
        }
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

    
    let menu = MenuView.createView()

    @objc func showMenu(){
        menuStackView.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.2, animations: {
            self.menuStackView.alpha = 0.5
        })
        { (worked) in
            UIView.animate(withDuration: 0.2, animations: {
                self.menuStackView.alpha = 1
            })
        }
        let amountToMove: CGFloat = 5.0

        if !menuIsShown{
            menu.frame = CGRect(x: 0, y: self.menuStackView.frame.maxY + amountToMove, width: self.view.frame.width, height: 126)
            userBarTopCnstr.constant += menu.frame.height - amountToMove
            menu.alpha = 0
            view.addSubview(menu)
            view.sendSubviewToBack(menu)
            menuIsShown = true

            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                self.menu.alpha = 1
                self.menuArrowLbl.transform = self.menuArrowLbl.transform.rotated(by: CGFloat((Double.pi) / 2))
            }, completion: {(worked) in
                self.menuStackView.isUserInteractionEnabled = true
            })
        }
        else{
            userBarTopCnstr.constant -= menu.frame.height - amountToMove
            self.menuIsShown = false


            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                self.menu.alpha = 0
                self.menuArrowLbl.transform = self.menuArrowLbl.transform.rotated(by: CGFloat(-(Double.pi) / 2))
            }, completion: {(worked) in
                self.menu.removeFromSuperview()
                self.menuStackView.isUserInteractionEnabled = true
            })
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
    
    
}
