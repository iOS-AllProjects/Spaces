//
//  Polyline.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/21/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import Foundation
import UIKit

class Polyline: CBLModel {
    
    @NSManaged var points: [[String : CGFloat]]
    
    class func polylineInDatabase(database: CBLDatabase, withPoints points: [[String:CGFloat]]) -> Polyline {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let polyline = Polyline(forNewDocumentIn: delegate!.kDatabase!)
        polyline.points = points
        
        return polyline
    }
    
}
