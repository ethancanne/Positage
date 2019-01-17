//
//  Post.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/23/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private(set) public var title: String
    private(set) public var data: String
    private(set) public var numStamps: Int
    private(set) public var isCommunity: Bool
    private(set) public var timestamp: Date
    private(set) public var fromUsername: String
    private(set) public var fromUserId: String
    private(set) public var toUserId: String
    private(set) public var documentId: String
    
    init(title: String, data: String, numStamps: Int, isCommunity: Bool, timestamp: Date, fromUsername: String, fromUserId: String, toUserId: String, documentId: String) {
        self.title = title
        self.data = data
        self.numStamps = numStamps
        self.isCommunity = isCommunity
        self.timestamp = timestamp
        self.fromUsername = fromUsername
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.documentId = documentId
    }
    
    
    class func setPost(from snapshot: QuerySnapshot?) -> [Post] {
        var posts = [Post]()
        guard let snap = snapshot else { return posts }
        for document in snap.documents{
            let data = document.data()
            let title = data[POST_TITLE] as? String ?? "Unnamed"
            let postData = data[POST_DATA] as? String ?? "Unknown"
            let isCommunity = data[POST_IS_COMMUNITY] as? Bool ?? true
            let serverTimestamp = data[POST_TIMESTAMP] as? Timestamp ?? Timestamp()
            let numStamps = data[NUM_STAMPS] as? Int ?? 0
            let fromUsername = data[POST_FROM_USERNAME] as? String ?? "Anonymous"
            let fromUserId = data[POST_FROM_USERID] as? String ?? "Anonymous"
            let toUserId = data[POST_TO_USERID] as? String ?? "Anonymous"
            let documentId = document.documentID
            
            let timestamp: Date = serverTimestamp.dateValue()
            let newPost = Post(title: title, data: postData, numStamps: numStamps, isCommunity: isCommunity, timestamp: timestamp, fromUsername: fromUsername, fromUserId: fromUserId, toUserId: toUserId, documentId: documentId)
            posts.append(newPost)
        }
        return posts
    }
}
