//
//  TaskList.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/22/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import Foundation
import RealmSwift

class TaskList: Object {
    dynamic var name = ""
    dynamic var createdAt = Date()
    let tasks = List<Task>() // used for one to many relationships 
    // List is very similar to Array for built in methods and accessing objects using indexed subscripting
}
