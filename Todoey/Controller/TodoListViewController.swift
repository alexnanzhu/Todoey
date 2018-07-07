//
//  ViewController.swift
//  Todoey
//
//  Created by Alex Z on 7/3/18.
//  Copyright © 2018 Alex Nan Zhu. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {

    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
//    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell")
        
        
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            
            //        item.done == true ? cell.accessoryType = .checkmark : cell.accessoryType = .none
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "no item added"
        }

        return cell
        
    }
    
    //MARK: - TableView delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(itemArray[indexPath.row])
        
//        itemArray[indexPath.row].done == false ? true : false
//
//        itemArray[indexPath.row].setValue("Completed", forKey: "title")
//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
//
//        saveItem()
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
//                    realm.delete(item)
                }
            } catch {
                print(error)
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    //MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "add item", style: .default) { (action) in
            //what will happen once the user clicks the add item buttom on our UIAlert
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("addbutton pressed erro msg \(error)")
                }
            }
            
            self.tableView.reloadData()

        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manupulation Methods
//    func saveItem() {
////        let encoder = PropertyListEncoder()
////        do {
////            let data = try encoder.encode(itemArray)
////            try data.write(to: dataFilePath!)
////        } catch {
////            print(error)
////        }
//
//        do {
//            try context.save()
//
//        } catch {
//            print(error)
//        }
//        self.tableView.reloadData()
//    }
//
//    func loadItems() {
//        do {
//            let data = try Data(contentsOf: dataFilePath!)
//            let decoder = PropertyListDecoder()
//            itemArray = try decoder.decode([Item].self, from: data)
//        } catch {
//            print(error)
//        }
//    }
  
    
// give a default value for the parameter of this fuction ↓
    func loadItems() {
        
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
////        if predicate != nil {
////            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, categoryPredicate])
////        } else {
////            request.predicate = categoryPredicate
////
////        }
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print("load errors: \(error)")
//        }
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }



}

//MARK: - Search bar methods
//
//extension TodoListViewController: UISearchBarDelegate {
//
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//
////        let request: NSFetchRequest<Item> = Item.fetchRequest()
//
////        tableView.reloadData()
//
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
//
//
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            loadItems()
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//        }
//
//    }
//
//
//}

