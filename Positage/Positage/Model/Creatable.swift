//
//  Creatable.swift
//  Positage
//
//  Created by Ethan Cannelongo on 3/2/20.
//  Copyright © 2020 Ethan Cannelongo. All rights reserved.
//

import Foundation
import Firebase

class Creatable {
    internal(set) public var title: String
    internal(set) public var timestamp: Date
    internal(set) public var documentId: String


    init(title: String, timestamp: Date, documentId: String){
        self.title = title
        self.timestamp = timestamp
        self.documentId = documentId
    }
    
}

