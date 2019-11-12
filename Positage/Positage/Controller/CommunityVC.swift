//
//  CommunityVC.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/28/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import UIKit
import Firebase


class CommunityVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortDataSegment: UISegmentedControl!
    @IBOutlet weak var communityHeader: PositageHeaderView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var menuStackView: UIStackView!
    @IBOutlet weak var userBarTopCnstr: NSLayoutConstraint!
    @IBOutlet weak var menuArrowLbl: UILabel!
    
  
    
    //Variables
    var posts: [Post] = []
    var filteredPosts: [Post] = []
    var isSearching = false
    private var postsCollectionRef: CollectionReference!
    private var postListener: ListenerRegistration!
    private var menuIsShown: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsCollectionRef = Firestore.firestore().collection(POST_REF)

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.bindToKeyboard()
        
        tableView.estimatedRowHeight = 161
        tableView.rowHeight = UITableView.automaticDimension
        let menuTap = UITapGestureRecognizer(target: self, action: #selector(showMenu))
        menuStackView.addGestureRecognizer(menuTap)
        menuStackView.isUserInteractionEnabled = true
        
        //Segment UI
        let attrSelected = NSDictionary(object: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!, forKey: NSAttributedString.Key.font as NSCopying)
        let attrNormal = NSDictionary(object: UIFont(name: "HelveticaNeue", size: 10.0)!, forKey: NSAttributedString.Key.font as NSCopying)
        sortDataSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        sortDataSegment.setTitleTextAttributes(attrNormal as? [NSAttributedString.Key : Any], for: .normal)
        sortDataSegment.setTitleTextAttributes(attrSelected as? [NSAttributedString.Key : Any], for: .selected)
        
        
        
        
        self.sortDataSegment.layer.cornerRadius = 0
        self.sortDataSegment.layer.borderColor = UIColor.white.cgColor
        self.sortDataSegment.layer.borderWidth = 0
        self.sortDataSegment.layer.masksToBounds = true
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ConfigureListener()
        sortDataSegment.layer.borderColor = UIColor.white.cgColor
        sortDataSegment.layer.cornerRadius = 0.0
        sortDataSegment.layer.borderWidth = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let newFrame = communityHeader.frame
        self.communityHeader.frame = CGRect(x: self.communityHeader.frame.minX - self.view.frame.width, y: self.communityHeader.frame.minY, width: self.communityHeader.frame.width, height: self.communityHeader.frame.height)

        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
            self.communityHeader.frame = newFrame

        }, completion: nil)
 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if postListener != nil {
            postListener.remove()
        }
        if menuIsShown{
            showMenu()
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
                .order(by: NUM_STAMPS, descending: true)
                .order(by: POST_IS_PROMOTED, descending: true)
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
    
    
    var menu = MenuView.createView()
    
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
                self.menuArrowLbl.transform = self.menuArrowLbl.transform.rotated(by: CGFloat((6 * Double.pi) / 2))
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
                self.menuArrowLbl.transform = self.menuArrowLbl.transform.rotated(by: CGFloat(-(6 * Double.pi) / 2))
            }, completion: {(worked) in
                self.menu.removeFromSuperview()
                self.menuStackView.isUserInteractionEnabled = true
            })
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
                cell.ConfigureCell(post: filteredPosts[indexPath.row])
            }
            else {
                cell.ConfigureCell(post: posts[indexPath.row])
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
