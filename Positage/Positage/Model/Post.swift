//
//  Post.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/23/18.
//  Copyright © 2018 Ethan Cannelongo. All rights reserved.
//

import Foundation
import Firebase

class Post : Creatable {
    private(set) public var message: String
    private(set) public var numStampsGiven: Int
    private(set) public var didRead: Bool
    
    private(set) public var category: String
    
    private(set) public var fromUsername: String
    private(set) public var fromUserId: String
    private(set) public var toUsername: String
    private(set) public var toUserId: String
        
    
    init(title: String, message: String, numStampsGiven: Int, didRead: Bool, timestamp: Date, category: String, fromUsername: String, fromUserId: String, toUsername: String, toUserId: String, documentId: String) {
        self.message = message
        self.numStampsGiven = numStampsGiven
        self.didRead = didRead
        
        self.category = category
        
        self.fromUsername = fromUsername
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.toUsername = toUsername
        
        super.init(title: title, timestamp: timestamp, documentId: documentId)
    }
    
    func toDictionary() -> [String: Any]{
        let postDictionaryData: [String: Any] = [
            TITLE: title,
            MESSAGE: message,
            NUM_STAMPS_GIVEN: numStampsGiven,
            DID_READ: didRead,
            
            CATEGORY: category,
            
            FROM_USERNAME: fromUsername,
            FROM_USERID: fromUserId,
            TO_USERNAME: toUsername,
            TO_USERID: toUserId,
            
            TIMESTAMP: timestamp
            
        ]
        return postDictionaryData
    }
    
    class func set(from snapshot: QuerySnapshot?) -> [Post] {
        var posts = [Post]()
        guard let snap = snapshot else { return posts }
        for document in snap.documents{
            let data = document.data()
            
            let title = data[TITLE] as? String ?? "Unnamed"
            let message = data[MESSAGE] as? String ?? "Unknown"
            let numStampsGiven = data[NUM_STAMPS_GIVEN] as? Int ?? 0
            let didRead = data[DID_READ] as? Bool ?? false
            
            let timestamp = data[TIMESTAMP] as? Timestamp ?? Timestamp()
            let category = data[CATEGORY] as? String ?? ""
            
            let fromUsername = data[FROM_USERNAME] as? String ?? "Anonymous"
            let fromUserId = data[FROM_USERID] as? String ?? ""
            let toUsername = data[TO_USERNAME] as? String ?? "Anonymous"
            let toUserId = data[TO_USERID] as? String ?? ""
            let documentId = document.documentID
            
            let dateTimestamp = timestamp.dateValue()
            
            if let numRecipientUnreadReplies = data[NUM_RECIPIENT_UNREAD_REPLIES] as? Int, let numSenderUnreadReplies = data[NUM_SENDER_UNREAD_REPLIES] as? Int{
                let newOngoingPost = OngoingPost(title: title, message: message, numRecipientUnreadMessages: numRecipientUnreadReplies, numSenderUnreadMessages: numSenderUnreadReplies, numStampsGiven: numStampsGiven, didRead: didRead, timestamp: dateTimestamp, category: category, fromUsername: fromUsername, fromUserId: fromUserId, toUsername: toUsername, toUserId: toUserId, documentId: documentId)
                posts.append(newOngoingPost)
            }else{
                let newPost = Post(title: title, message: message, numStampsGiven: numStampsGiven, didRead: didRead, timestamp: dateTimestamp, category: category, fromUsername: fromUsername, fromUserId: fromUserId, toUsername: toUsername, toUserId: toUserId, documentId: documentId)
                posts.append(newPost)
            }
            
        }
        return posts
    }
}
