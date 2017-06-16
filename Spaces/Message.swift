//
//  Message.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/15/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import Foundation
import Firebase

class Message: NSObject {
    var fromID: String?
    var toID: String?
    var text: String?
    var timestamp: NSNumber?
    var imageURL: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    func chatPartnerId() -> String? {
    return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }
    
    init(dictionary: [String: Any]){
        super.init()
        fromID = dictionary["fromID"] as? String
        toID = dictionary["toID"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        imageURL = dictionary["imageURL"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
    }
}
