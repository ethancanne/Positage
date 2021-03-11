//
//  TrackVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 1/28/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase

class TrackVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    //Outlets
    @IBOutlet weak var tableViewTopCnstr: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    //Variables
    var ongoingPosts: [OngoingPost] = []
    var postListener: ListenerRegistration!
    private var postsCollectionRef: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsCollectionRef = Firestore.firestore().collection(POST_REF)
        tableView.delegate = self
        tableView.dataSource = self

    }
    override func viewWillAppear(_ animated: Bool) {
        AppLocation.currentUserLocation = "CONVERSATIONS"
        ConfigureListener()
    }
    
    //General Functions
    func ConfigureListener(){
        guard let user = Auth.auth().currentUser else { return }
        postListener = postsCollectionRef
            .whereField(FROM_USERID, isEqualTo: user.uid)
            .order(by: TIMESTAMP, descending: true)
            .addSnapshotListener
            {(snapshot, error) in
                if let err = error {
                    debugPrint("Error fetching docs: \(err)")
                }
                else{
                    self.ongoingPosts.removeAll()
                    self.ongoingPosts = OngoingPost.set(from: snapshot)
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
            let ongoingPost = ongoingPosts[(tableView.indexPathForSelectedRow?.row)!]
            trackDetailsVC?.ongoingPost = ongoingPost
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //Table View Stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ongoingPosts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toTrackDetails", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ongoingPostCell") as? OngoingPostTableViewCell {
            cell.ConfigureCell(ongoingPost: ongoingPosts[indexPath.row])
            return cell
        }
        else{
            return UITableViewCell()
        }
        
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
