//
//  CommunityVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/28/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase


class CommunityVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortDataSegment: UISegmentedControl!
    
    //Variables
    var posts: [Post] = []
    private var postsCollectionRef: CollectionReference!
    private var postListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsCollectionRef = Firestore.firestore().collection(POST_REF)

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 161
        tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ConfigureListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        postListener.remove()
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
        else {
            postListener = postsCollectionRef
                .whereField(POST_IS_COMMUNITY, isEqualTo: true)
                .order(by: NUM_STAMPS, descending: true)
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
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "communityCell") as? CommunityTableViewCell{
            cell.ConfigureCell(post: posts[indexPath.row])
            return cell
        }
        else{
            return UITableViewCell()
        }
    }
 
}
