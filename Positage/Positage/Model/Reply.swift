//
//  Reply.swift
//  Positage
//
//  Created by Ethan Cannelongo on 2/3/19.
//  Copyright © 2019 Ethan Cannelongo. All rights reserved.
//

import Foundation
import Firebase


class Reply {
    private(set) public var username: String
    private(set) public var timestamp: Date
    private(set) public var message: String
    private(set) public var userId: String

    
    init(username: String, timestamp: Date, message: String, userId: String) {
        self.username = username
        self.timestamp = timestamp
        self.message = message
        self.userId = userId
    }
    
    class func setReply(from snapshot: QuerySnapshot?) -> [Reply] {
        var replies = [Reply]()
        guard let snap = snapshot else { return replies }
        for document in snap.documents{
            let username = document.data()[FROM_USERNAME] as? String ?? "Unknown"
            let serverTimestamp = document.data()[TIMESTAMP] as? Timestamp ?? Timestamp()
            let message = document.data()[MESSAGE] as? String ?? "null"
            let userId = document.data()[FROM_USERID] as? String ?? "Unknown"
            print("A reply has been sent by \(username)")
            
            let timestamp: Date = serverTimestamp.dateValue()
            let newReply = Reply(username: username, timestamp: timestamp, message: message, userId: userId)
            replies.append(newReply)
        }
        return replies
    }
}
