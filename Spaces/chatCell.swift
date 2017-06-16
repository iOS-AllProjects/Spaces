//
//  chatCell.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/15/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class chatCell: UICollectionViewCell {
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var bubbleWidth: NSLayoutConstraint!
    @IBOutlet weak var bubbleTrailing: NSLayoutConstraint!
    @IBOutlet weak var chatTrailing: NSLayoutConstraint!
    
    
    var message: Message? { didSet{ updateUI() } }
    
    func updateUI(){
        if let message = message{
        self.chatTextView.text = message.text
        }
    }
}
