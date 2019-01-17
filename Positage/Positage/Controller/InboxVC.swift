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
    @IBOutlet weak var tableView: UITableView!
    
    //Variables
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
    }
    
    
    //General Functions
    func ConfigureListener(){
        guard let user = Auth.auth().currentUser else { return }
        postListener = postsCollectionRef
            .whereField(POST_TO_USERID, isEqualTo: user.uid)
            .order(by: POST_TIMESTAMP, descending: true)
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
    
    //Segue Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select row at\(indexPath.row)")
        performSegue(withIdentifier: "detailsSegue", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsSegue" {
            let detailsVC = segue.destination as? DetailsVC
            let post = posts[(tableView.indexPathForSelectedRow?.row)!]
            
            detailsVC?.postTitle = post.title
            detailsVC?.postData = post.data
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, hh:mm"
            let timestamp = formatter.string(from: post.timestamp)
            detailsVC?.timestamp = timestamp
            
            detailsVC?.fromUsername = post.fromUsername
            
        }
    }
    
    //Actions
    @IBAction func signOutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do{
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            debugPrint("Error signing out: \(signOutError)")
        }
        
    }
    
    
}
