//
//  CommunityPost.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/4/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import Foundation
import Firebase

class Entry{
    
    private(set) public var title: String
    private(set) public var message: String
    private(set) public var sorting: String
    
    private(set) public var numSupports: Int
    private(set) public var usersSupported: [String]
    private(set) public var supportGoal: Int
    private(set) public var customSupportMsg: String
    
    private(set) public var timestamp: Date
    private(set) public var username: String
    private(set) public var userId: String
    
    private(set) public var documentId: String
    
    func setSupportGoal(supportGoal: String){
        self.supportGoal = Int(supportGoal)!
    }
    
    func setSorting(sorting: String){
        if sorting == NORMAL_SORTING || sorting == PRIORITY_SORTING{
            self.sorting = sorting
        }
    }
    
    func setSupportMessage(message: String){
        self.customSupportMsg = message
    }
    init(title: String, message: String, sorting: String, numSupports: Int, usersSupported: [String], supportGoal: Int, customSupportMsg: String, username: String, userId: String, timestamp: Date, documentId: String) {
        
        self.title = title
        self.message = message
        self.sorting = sorting
        
        self.numSupports = numSupports
        self.usersSupported = usersSupported
        self.supportGoal = supportGoal
        self.customSupportMsg = customSupportMsg
        
        self.username = username
        self.userId = userId
        
        self.timestamp = timestamp
        self.documentId = documentId
        
    }
    
    class func setCommunityPost(from snapshot: QuerySnapshot?) -> [Entry] {
        var posts = [Entry]()
        guard let snap = snapshot else { return posts }
        for document in snap.documents{
            let data = document.data()
            
            let title = data[TITLE] as? String ?? "Unnamed"
            let message = data[MESSAGE] as? String ?? "Unknown"
            let sorting = data[SORTING] as? String ?? ""
            
            let numSupports = data[NUM_SUPPORTS] as? Int ?? 0
            let usersSupported = data[USERS_SUPPORTED] as? [String] ?? [String]()
            let supportGoal = data[SUPPORT_GOAL] as? Int ?? 0
            let customSupportMsg = data[CUSTOM_SUPPORT_MESSAGE] as? String ?? "Thank you"
            
            let username = data[USERNAME] as? String ?? "Anonymous"
            let userId = data[USERID] as? String ?? ""
            
            let timestamp = data[TIMESTAMP] as? Timestamp ?? Timestamp()
            let documentId = document.documentID
            
            let dateTimestamp = timestamp.dateValue()
            let newPost = Entry(title: title, message: message, sorting: sorting, numSupports: numSupports, usersSupported: usersSupported, supportGoal: supportGoal, customSupportMsg: customSupportMsg, username: username, userId: userId, timestamp: dateTimestamp, documentId: documentId)
            
            posts.append(newPost)
            
        }
        return posts
    }
}
