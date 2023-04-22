//
//  ViewController.swift
//  ToDoList
//
//  Created by LAVANTA on 19.04.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var nameText = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.allowsMultipleSelection = true
        
        fetchData()
    }
   


    @IBAction func addClicked(_ sender: Any) {
        
        showInputDialog()
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete the item from the data source
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext

            let itemToDelete = nameText[indexPath.row]

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Lists")
            fetchRequest.predicate = NSPredicate(format: "toDoLists = %@", itemToDelete)

            do {
                let test = try context.fetch(fetchRequest)

                let objectToDelete = test[0] as! NSManagedObject
                context.delete(objectToDelete)
                try context.save()

                fetchData()
            } catch {
                print("Error deleting item: \(error)")
            }
        }
    }
    
   


    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let cellText = nameText
        cell.textLabel?.text = cellText[indexPath.row]
        
        
        
        return cell    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return nameText.count   }
    
    func showInputDialog(title:String? = "Add What Do You Want to Do",
                            subtitle:String? = nil,
                            actionTitle:String? = "Add",
                            cancelTitle:String? = "Cancel",
                            inputPlaceholder:String? = "Buy Milk and Eggs...",
                            inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                            cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                            actionHandler: ((_ text: String?) -> Void)? = nil) {
            
            let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
            alert.addTextField { (textField:UITextField) in
                textField.placeholder = inputPlaceholder
                textField.keyboardType = inputKeyboardType
            }
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { [self] (action:UIAlertAction) in
                guard let textField =  alert.textFields?.first, let text = textField.text else {
                    actionHandler?(nil)
                    return
                }
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                       let context = appDelegate.persistentContainer.viewContext
                       
                       let newLists = NSEntityDescription.insertNewObject(forEntityName: "Lists", into: context)
                       newLists.setValue(text, forKey: "toDoLists")

                       do {
                           try context.save()
                       } catch {
                           print("Error saving data: \(error)")
                       }

                       fetchData()
                       actionHandler?(text)            }))
            
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
            
            self.present(alert, animated: true, completion: nil)
        }
    func fetchData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lists")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            nameText = []
            for data in results as! [NSManagedObject] {
                if let name = data.value(forKey: "toDoLists") as? String {
                    nameText.append(name)
                }
            }
            tableView.reloadData()
        } catch {
            print("Error fetching data: \(error)")
        }
    }

    
}

