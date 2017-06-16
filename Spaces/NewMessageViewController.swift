//
//  ChatViewController.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/14/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import UIKit
import Firebase

class NewMessageViewController: UIViewController {

    @IBOutlet weak var usersTableView: UITableView!
    
    var people = [Person]()
    
    var messagesController: ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI(){
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        fetchUser()
        usersTableView.tableFooterView = UIView()
    }
    
    func fetchUser(){
        // Check for existing nodes
        Database.database().reference().child("users").observe(.childAdded, with:  {
            (snapshot) in
            if let dictionary  = snapshot.value as? [String:AnyObject] {
                let person = Person()
                person.id = snapshot.key
                // This way the property name should match the database key to avoid a crash
                person.setValuesForKeys(dictionary)
                self.people.append(person)
                // GCD call
                performUIUpdatesOnMain {
                    self.usersTableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NewMessageViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! userCell
        cell.person = people[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.people[indexPath.row]
            self.messagesController?.showChatLogForUser(user: user)
        }
    }
}
