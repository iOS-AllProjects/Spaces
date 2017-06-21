//
//  messagesCell.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/15/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class messagesCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userMessage: UILabel!
    @IBOutlet weak var userTime: UILabel!
    
    var message: Message? { didSet{ updateUI() } }
    
    func updateUI() {
        guard let message = message else { return }
        if let id = message.chatPartnerId(){
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any]{
                    if let profileImageURL = dictionary["profileImageURL"] as? String {
                        let url = URL(string: profileImageURL)
                        self.getDataFromUrl(url: url!) { (data, response, error)  in
                            guard let data = data, error == nil else { return }
                            performUIUpdatesOnMain {
                                self.userImage.image = UIImage(data: data)
                                self.userName.text = dictionary["name"] as? String
                                if message.imageURL != nil {
                                    self.userMessage.text = "Image"
                                } else {
                                self.userMessage.text = message.text
                                }
                                if let seconds = message.timestamp?.doubleValue{
                                    let timestampDate = NSDate(timeIntervalSince1970: seconds)
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "hh:mm a"
                                    self.userTime.text = dateFormatter.string(from: timestampDate as Date)
                                }

                            }
                        }
                    }
                }
            }, withCancel: nil)
        }
    }


    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
        }
}
