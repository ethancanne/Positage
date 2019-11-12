//
//  TrackVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 1/28/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class TrackVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Variables
    var posts: [Post] = []
    var postListener: ListenerRegistration!
    private var postsCollectionRef: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsCollectionRef = Firestore.firestore().collection(POST_REF)
        tableView.delegate = self
        tableView.dataSource = self

    }
    override func viewWillAppear(_ animated: Bool) {
        ConfigureListener()
    }
    
    //General Functions
    func ConfigureListener(){
        guard let user = Auth.auth().currentUser else { return }
        postListener = postsCollectionRef
            .whereField(FROM_USERID, isEqualTo: user.uid)
            .whereField(POST_ALLOWS_TRACKING, isEqualTo: true)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        if postListener != nil {
            postListener.remove()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTrackDetails" {
            let trackDetailsVC = segue.destination as? TrackDetailsVC
            let post = posts[(tableView.indexPathForSelectedRow?.row)!]
            trackDetailsVC?.post = post
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    //Table View Stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toTrackDetails", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell") as? TrackTableViewCell {
            cell.ConfigureCell(post: posts[indexPath.row])
            return cell
        }
        else{
            return UITableViewCell()
        }
        
    }
    
    

}
