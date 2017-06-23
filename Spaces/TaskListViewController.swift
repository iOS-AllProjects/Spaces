//
//  TaskListViewController.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/22/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import UIKit
import RealmSwift

class TaskListViewController: UIViewController {
    
    @IBOutlet weak var filterToggle: CustomSegmentedControl!
    @IBOutlet weak var taskListTableView: UITableView!
    
    var lists : Results<TaskList>!
    
    var notificationToken: NotificationToken!
    var realm: Realm!
        
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var currentCreateAction:UIAlertAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        updateUI()
    }
    @IBAction func filterToggleTapped(_ sender: Any) {
        if filterToggle.selectedIndex == 0{
            self.lists = self.lists.sorted(byKeyPath: "name")
        }
        else{
            self.lists = self.lists.sorted(byKeyPath: "createdAt", ascending:false)
        }
        self.taskListTableView.reloadData()
    }
    
    @IBAction func addBarButtonTapped(_ sender: Any) {
        addNewTaskList(nil)
    }
    
    func setupUI(){
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        filterToggle.items = ["A-Z", "Date"]
        filterToggle.highlightedLabelColor = UIColor.white
        filterToggle.unSelectedLabelColor = UIColor.white
    }
    
    func updateUI(){
        if let uiRealm = appDelegate?.uiRealm {
        lists = uiRealm.objects(TaskList.self)
        self.taskListTableView.setEditing(false, animated: true)
        self.taskListTableView.reloadData()
        }
    }
    
    func listNameFieldDidChange(_ textField:UITextField){
        self.currentCreateAction.isEnabled = (textField.text?.characters.count)! > 0
    }
    
    func addNewTaskList(_ updatedList:TaskList!){
        
        var title = "New Tasks List"
        var doneTitle = "Create"
        if updatedList != nil{
            title = "Update Tasks List"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Write the name of your tasks list.", preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            
            let listName = alertController.textFields?.first?.text
            
            if updatedList != nil{
                // update mode
                if let uiRealm = self.appDelegate?.uiRealm {
                try! uiRealm.write{
                    updatedList.name = listName!
                    self.updateUI()
                    }
                }
            }
            else{
                
                let newTaskList = TaskList()
                newTaskList.name = listName!
                if let uiRealm = self.appDelegate?.uiRealm {
                try! uiRealm.write{
                    
                    uiRealm.add(newTaskList)
                    self.updateUI()
                    }
                }
            }
            
            print(listName ?? "")
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Task List Name"
            textField.addTarget(self, action: #selector(TaskListViewController.listNameFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if updatedList != nil{
                textField.text = updatedList.name
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            if identifier == "taskSegue", let selectedList = sender as? TaskList{
                let tasksVC = segue.destination as! TasksViewController
                tasksVC.list = selectedList
                self.tabBarController?.tabBar.isHidden = true
            }
        }
    }
}
extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let listsTasks = lists{
            return listsTasks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskListCell", for: indexPath)
        let list = lists[indexPath.row]
        cell.textLabel?.text = list.name
        cell.detailTextLabel?.text = "\(list.tasks.count) Tasks"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.taskListTableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "taskSegue", sender: self.lists[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (deleteAction, indexPath) -> Void in
            let listToBeDeleted = self.lists[indexPath.row]
            if let uiRealm = self.appDelegate?.uiRealm {
            try! uiRealm.write{
                
                uiRealm.delete(listToBeDeleted)
                self.updateUI()
                }
            }
        }
        deleteAction.backgroundColor = UIColor.red

        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (editAction, indexPath) -> Void in
            let listToBeUpdated = self.lists[indexPath.row]
            self.addNewTaskList(listToBeUpdated)
        }
        editAction.backgroundColor = UIColor.orange

        return [deleteAction, editAction]
    }
    
    
}
