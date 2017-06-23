//
//  TasksViewController.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/22/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import UIKit
import RealmSwift

class TasksViewController: UIViewController {

    @IBOutlet weak var tasksTableView: UITableView!
    
    var list: TaskList?
    var openTasks : Results<Task>!
    var completedTasks : Results<Task>!
    var currentCreateAction:UIAlertAction!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate


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
        if let list = list{
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
            self.title = list.name
            updateUI()
        }
    }
    
    func updateUI(){
        if let list = list {
            completedTasks = list.tasks.filter("isCompleted = true")
            openTasks = list.tasks.filter("isCompleted = false")
            self.tasksTableView.reloadData()
        }
    }
    @IBAction func addBarButtonTapped(_ sender: Any) {
        addNewTask(nil)
    }
    
    func addNewTask(_ updatedTask:Task!){
        
        var title = "New Task"
        var doneTitle = "Create"
        if updatedTask != nil{
            title = "Update Task"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Write the name of your task.", preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            
            let taskName = alertController.textFields?.first?.text
            
            if updatedTask != nil{
                // update mode
            if let uiRealm = self.appDelegate?.uiRealm{
                try! uiRealm.write{
                    updatedTask.name = taskName!
                    self.updateUI()
                }
            }
        }
            else{
                
                let newTask = Task()
                newTask.name = taskName!
            if let uiRealm = self.appDelegate?.uiRealm{
                try! uiRealm.write{
                    
                    self.list?.tasks.append(newTask)
                    self.updateUI()
                }
            }
        }
            print(taskName ?? "")
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Task Name"
            textField.addTarget(self, action: #selector(TasksViewController.taskNameFieldDidChange(_:)) , for: UIControlEvents.editingChanged)
            if updatedTask != nil{
                textField.text = updatedTask.name
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }

    func taskNameFieldDidChange(_ textField:UITextField){
        self.currentCreateAction.isEnabled = (textField.text?.characters.count)! > 0
    }

}

extension TasksViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = UIColor.white
            headerTitle.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return openTasks.count
        }
        return completedTasks.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "OPEN TASKS"
        }
        return "COMPLETED TASKS"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        var task: Task!
        if indexPath.section == 0{
            task = openTasks[indexPath.row]
            cell.imageView?.image = UIImage(named: "checkbox_unselected")
        }
        else{
            task = completedTasks[indexPath.row]
            cell.imageView?.image = UIImage(named: "checkbox_selected")
        }
        
        cell.textLabel?.text = task.name
        return cell

    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            //Deletion will go here
            
            var taskToBeDeleted: Task!
            if indexPath.section == 0{
                taskToBeDeleted = self.openTasks[indexPath.row]
            }
            else{
                taskToBeDeleted = self.completedTasks[indexPath.row]
            }
            if let uiRealm = self.appDelegate?.uiRealm{
            try! uiRealm.write{
                uiRealm.delete(taskToBeDeleted)
                self.updateUI()
                }
            }
        }
        deleteAction.backgroundColor = UIColor.red
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            
            // Editing will go here
            var taskToBeUpdated: Task!
            if indexPath.section == 0{
                taskToBeUpdated = self.openTasks[indexPath.row]
            }
            else{
                taskToBeUpdated = self.completedTasks[indexPath.row]
            }
            
            self.addNewTask(taskToBeUpdated)
            
        }
        editAction.backgroundColor = UIColor.orange
        
        let doneAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Done") { (doneAction, indexPath) -> Void in
            // Editing will go here
            var taskToBeUpdated: Task!
            if indexPath.section == 0{
                taskToBeUpdated = self.openTasks[indexPath.row]
            }
            else{
                taskToBeUpdated = self.completedTasks[indexPath.row]
            }
            if let uiRealm = self.appDelegate?.uiRealm{
            try! uiRealm.write{
                taskToBeUpdated.isCompleted = true
                self.updateUI()
                }
            }
            
        }
        doneAction.backgroundColor = UIColor.clear
        return [deleteAction, editAction, doneAction]
    }
}
