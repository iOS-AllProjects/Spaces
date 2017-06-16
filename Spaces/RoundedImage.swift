//
//  RoundedButton.swift
//  CBREConnect
//
//  Created by Etjen Ymeraj on 12/17/16.
//  Copyright © 2016 Etjen Ymeraj. All rights reserved.
//

import UIKit

@IBDesignable class RoundedImageView: UIImageView
{
    @IBInspectable var perfectRound: Bool = false
    
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.blue {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 15.0 {
        didSet{
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var backColor: UIColor = UIColor.white {
        didSet {
            self.backgroundColor = backColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if perfectRound {
            self.cornerRadius = bounds.height / 2
            self.layer.masksToBounds = self.layer.cornerRadius > 0
        }
    }
}
