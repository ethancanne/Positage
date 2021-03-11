//
//  OngoingPost.swift
//  Positage
//
//  Created by Ethan Cannelongo on 12/4/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import Foundation
import Firebase

class OngoingPost: Post {
    
    private(set) public var numRecipientUnreadMessages: Int
    private(set) public var numSenderUnreadMessages: Int

    init(title: String, message: String, numRecipientUnreadMessages: Int, numSenderUnreadMessages: Int, numStampsGiven: Int, didRead: Bool, timestamp: Date, category: String, fromUsername: String, fromUserId: String, toUsername: String, toUserId: String, documentId: String) {
        self.numRecipientUnreadMessages = numRecipientUnreadMessages
        self.numSenderUnreadMessages = numSenderUnreadMessages
        
        super.init(title: title, message: message, numStampsGiven: numStampsGiven, didRead: didRead, timestamp: timestamp, category: category, fromUsername: fromUsername, fromUserId: fromUserId, toUsername: toUsername, toUserId: toUserId, documentId: documentId)
    }
    
    override func toDictionary() -> [String: Any]{
        let postDictionaryData: [String: Any] = [
            TITLE: title,
            MESSAGE: message,
            DID_READ: didRead,
            NUM_RECIPIENT_UNREAD_REPLIES: numRecipientUnreadMessages,
            NUM_SENDER_UNREAD_REPLIES: numRecipientUnreadMessages,
            NUM_STAMPS_GIVEN: numStampsGiven,

            CATEGORY: category,
            
            FROM_USERNAME: fromUsername,
            FROM_USERID: fromUserId,
            TO_USERNAME: toUsername,
            TO_USERID: toUserId,
            
            TIMESTAMP: timestamp

        ]
        return postDictionaryData
    }
    
    class func set(from snapshot: QuerySnapshot?) -> [OngoingPost] {
        var ongoingPosts = [OngoingPost]()
        guard let snap = snapshot else { return ongoingPosts }
        for document in snap.documents{
            let data = document.data()
        
            let numRecipientUnreadMessage = data[NUM_RECIPIENT_UNREAD_REPLIES] as? Int ?? 0
            
            let numSenderUnreadMessage = data[NUM_SENDER_UNREAD_REPLIES] as? Int ?? 0
            
            
            let title = data[TITLE] as? String ?? "Unnamed"
            
            let message = data[MESSAGE] as? String ?? "Unknown"
            
            let numStampsGiven = data[NUM_STAMPS_GIVEN] as? Int ?? 0
            
            let timestamp = data[TIMESTAMP] as? Timestamp ?? Timestamp()
            let category = data[CATEGORY] as? String ?? ""
            let didRead = data[DID_READ] as? Bool ?? false
            
            let fromUsername = data[FROM_USERNAME] as? String ?? "Anonymous"
            let fromUserId = data[FROM_USERID] as? String ?? ""
            let toUsername = data[TO_USERNAME] as? String ?? "Anonymous"
            let toUserId = data[TO_USERID] as? String ?? ""
            let documentId = document.documentID
            
            let dateTimestamp = timestamp.dateValue()
            
            let newOngoingPost = OngoingPost(title: title, message: message, numRecipientUnreadMessages: numRecipientUnreadMessage, numSenderUnreadMessages: numSenderUnreadMessage, numStampsGiven: numStampsGiven, didRead: didRead, timestamp: dateTimestamp, category: category, fromUsername: fromUsername, fromUserId: fromUserId, toUsername: toUsername, toUserId: toUserId, documentId: documentId)
            
            ongoingPosts.append(newOngoingPost)
            
        }
        return ongoingPosts
    }
}
