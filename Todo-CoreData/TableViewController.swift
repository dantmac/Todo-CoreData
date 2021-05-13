//
//  TableViewController.swift
//  Todo-CoreData
//
//  Created by admin on 13.05.2021.
//

import UIKit

class TableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "To-Do List"
        getTasks()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(tapedAdd))
    }
    
    @objc private func tapedAdd() {
        let alert = UIAlertController(title: "New Task",
                                      message: "Add a new Task",
                                      preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Add", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let task = field.text, !task.isEmpty else { return }
            
            self?.createTask(task: task)
        }))
        present(alert, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.task
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        
        let sheet = UIAlertController(title: "Edit",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            
            let alert = UIAlertController(title: "Edit Task",
                                          message: "Edit your Task",
                                          preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = task.task
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newTask = field.text, !newTask.isEmpty else { return }
                
                self?.updateTask(task: task, newTask: newTask)
            }))
            self.present(alert, animated: true)
        }))
        
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteTask(task: task)
        }))
        present(sheet, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            deleteTask(task: task)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
    // Core Data Services
    
    func getTasks() {
        do {
            tasks = try context.fetch(Task.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            // error
        }
    }
    
    func createTask(task: String) {
        let newTask = Task(context: context)
        newTask.task = task
        saveContex()
    }
    
    func deleteTask(task: Task) {
        context.delete(task)
        saveContex()
    }
    
    func updateTask(task: Task, newTask: String) {
        task.task = newTask
        saveContex()
    }
    
    private func saveContex() {
        do {
            try context.save()
            getTasks()
        }
        catch {
            // error
        }
    }
}
