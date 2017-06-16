//
//  userCell.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/15/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class userCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    
    
    var person: Person? { didSet{ updateUI() } }
    
    func updateUI() {
        guard let person = person else { return }
        
        
        if let profileImageURL = person.profileImageURL {
            let url = URL(string: profileImageURL)
            print("Download Started")
            getDataFromUrl(url: url!) { (data, response, error)  in
                guard let data = data, error == nil else { return }
                print("Download Finished")
                performUIUpdatesOnMain {
                    self.userImage.image = UIImage(data: data)
                    self.userName.text = person.name
                    self.userEmail.text = person.email
                }
            }
        }
    }

    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }

}
