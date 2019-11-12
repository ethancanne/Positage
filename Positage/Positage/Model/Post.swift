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
    private(set) public var numReplies: Int
    private(set) public var isCommunity: Bool
    private(set) public var allowsTracking: Bool
    private(set) public var timestamp: Date
    private(set) public var fromUsername: String
    private(set) public var fromUserId: String
    private(set) public var toUserId: String
    private(set) public var toUsername: String
    private(set) public var documentId: String
    private(set) public var didView: Bool
    private(set) public var isPromoted: Bool



    
    init(title: String, data: String, numStamps: Int, numReplies: Int, isCommunity: Bool, allowsTracking: Bool, isPromoted: Bool, timestamp: Date, fromUsername: String, fromUserId: String, toUserId: String, toUsername: String, documentId: String, didView: Bool) {
        self.title = title
        self.data = data
        self.numStamps = numStamps
        self.numReplies = numReplies
        self.isCommunity = isCommunity
        self.allowsTracking = allowsTracking
        self.timestamp = timestamp
        self.fromUsername = fromUsername
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.toUsername = toUsername
        self.documentId = documentId
        self.didView = didView
        self.isPromoted = isPromoted
    }
    
    
    class func setPost(from snapshot: QuerySnapshot?) -> [Post] {
        var posts = [Post]()
        guard let snap = snapshot else { return posts }
        for document in snap.documents{
            let data = document.data()
            let title = data[TITLE] as? String ?? "Unnamed"
            let postData = data[DATA] as? String ?? "Unknown"
            let isCommunity = data[POST_IS_COMMUNITY] as? Bool ?? true
            let allowsTracking = data[POST_ALLOWS_TRACKING] as? Bool ?? false
            let isPromoted = data[POST_IS_PROMOTED] as? Bool ?? false
            let serverTimestamp = data[TIMESTAMP] as? Timestamp ?? Timestamp()
            let numStamps = data[NUM_STAMPS] as? Int ?? 0
            let numReplies = data[NUM_REPLIES] as? Int ?? 0
            let fromUsername = data[FROM_USERNAME] as? String ?? "Anonymous"
            let fromUserId = data[FROM_USERID] as? String ?? "Anonymous"
            let toUserId = data[TO_USERID] as? String ?? "Anonymous"
            let toUsername = data[TO_USERNAME] as? String ?? "Anonymous"
            let documentId = document.documentID
            let didView = document[DID_VIEW] as? Bool ?? false
            
            
            let timestamp: Date = serverTimestamp.dateValue()
            let newPost = Post(title: title, data: postData, numStamps: numStamps, numReplies: numReplies, isCommunity: isCommunity, allowsTracking: allowsTracking, isPromoted: isPromoted, timestamp: timestamp, fromUsername: fromUsername, fromUserId: fromUserId, toUserId: toUserId, toUsername: toUsername, documentId: documentId, didView: didView)
            posts.append(newPost)
        }
        return posts
    }
}
