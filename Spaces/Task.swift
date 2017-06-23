//
//  Task.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/22/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    dynamic var name = ""
    dynamic var createdAt = Date()
    dynamic var notes = ""
    dynamic var isCompleted = false
}
