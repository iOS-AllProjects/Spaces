//
//  MessagesViewController.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/13/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var messagesTableView: UITableView!
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let userID = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
                
                let messageID = snapshot.key
                self.fetchMessagesWithMessageId(messageID: messageID)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.reloadTable()  
            
        }, withCancel: nil)
    }
    
    func fetchMessagesWithMessageId(messageID: String){
        let messageRef = Database.database().reference().child("messages").child(messageID)
        
        messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary  = snapshot.value as? [String:AnyObject] {
                let message = Message(dictionary: dictionary)
                if let chatPartnerID = message.chatPartnerId(){
                    self.messagesDictionary[chatPartnerID] = message
                }
                self.reloadTable()
            }
        }, withCancel: nil)
    }
    
    func reloadTable(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
    }
    
    func handleReload(){
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        // GCD call
        performUIUpdatesOnMain {
            self.messagesTableView.reloadData()
        }
    }
    
    func setupUI(){
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        if Auth.auth().currentUser?.uid == nil {
            performSegue(withIdentifier: "authenticateSegue", sender: nil)
        } else {
            fetchCurrentUser()
    }
}
    func fetchCurrentUser(){
        // Get the current user
        if let id = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(id).observe(.value, with: { (snapshot) in
                // Update the Navigation title
                if let dictionary  = snapshot.value as? [String:AnyObject] {
                        //self.navigationItem.title = dictionary["name"] as? String
                        performUIUpdatesOnMain {
                        let person = Person()
                        person.setValuesForKeys(dictionary)
                        self.setupNavBar(user: person)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    func setupNavBar(user: Person){
            self.messages.removeAll()
            self.messagesDictionary.removeAll()
            self.messagesTableView.reloadData()
            self.messagesTableView.tableFooterView = UIView()

            observeUserMessages()

        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        titleView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let profileImageView = UIImageView()
        containerView.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        let url = URL(string: user.profileImageURL!)
        print("Download Started")
        getDataFromUrl(url: url!) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print("Download Finished")
            performUIUpdatesOnMain {
                profileImageView.image = UIImage(data: data)
            }
        }
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.textColor = UIColor.white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.segueToChatLog(_:)))
        tapGesture.delegate = self
        self.navigationItem.titleView?.addGestureRecognizer(tapGesture)
        
    }
    
    func segueToChatLog(_ sender: UITapGestureRecognizer){
        print("TitleBarTapped")
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }


    @IBAction func signoutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        performSegue(withIdentifier: "authenticateSegue", sender: nil)
    }
    @IBAction func newMessageButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "newSegue", sender: nil)
    }

    func showChatLogForUser(user: Person){
        performSegue(withIdentifier: "logSegue", sender: user)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            if identifier == "authenticateSegue"{
                let nav = segue.destination as! UINavigationController
                let loginVC = nav.topViewController as! LoginViewController
                loginVC.messagesController = self
            }
            if identifier == "newSegue"{
                let nav = segue.destination as! UINavigationController
                let newMessageVC = nav.topViewController as! NewMessageViewController
                newMessageVC.messagesController = self
            }
            if identifier == "logSegue", let selectedUser = sender as? Person{
                let chatVC = segue.destination as! ChatLogViewController
                chatVC.person = selectedUser
                self.tabBarController?.tabBar.isHidden = true
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! messagesCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.messagesTableView.deselectRow(at: indexPath, animated: true)
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else{
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {
                return
            }
            let person = Person()
            person.id = chatPartnerId
            person.setValuesForKeys(dictionary)
            self.performSegue(withIdentifier: "logSegue", sender: person)
        }, withCancel: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let message = self.messages[indexPath.row]
        if let chatPartner = message.chatPartnerId() {
        Database.database().reference().child("user-messages").child(uid).child(chatPartner).removeValue(completionBlock: { (error, ref) in
            
            if error != nil {
                print("Failed to delete")
            }
            
            self.messagesDictionary.removeValue(forKey: chatPartner)
            self.reloadTable()
            
        })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0
    }
}
