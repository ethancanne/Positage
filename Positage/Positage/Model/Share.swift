//
//  Share.swift
//  Positage
//
//  Created by Ethan Cannelongo on 4/14/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import Foundation

class Investment: Creatable {

    private(set) public var stampsEarned: Int
    private(set) public var originalEntryDocumentId: String

    internal init(stampsEarned: Int, originalEntryDocumentId: String, title: String, timestamp: Date, documentId: String) {
        self.stampsEarned = stampsEarned
        self.originalEntryDocumentId = originalEntryDocumentId
        super.init(title: title, timestamp: timestamp, documentId: documentId)
    }
}
