//
//  ViewController.swift
//  Todoey
//
//  Created by Alex Z on 7/3/18.
//  Copyright © 2018 Alex Nan Zhu. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    let searchController = UISearchController(searchResultsController: nil)
    
    var todoItems: Results<Item>?
    var filterTodoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    //    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            title = selectedCategory!.name
            
            if let navBarColor = UIColor(hexString: colorHex) {
                updateNavBar(withHexCode: colorHex)
                searchController.searchBar.barTintColor = navBarColor
            }
            
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D98F6")
    }
    
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filterTodoItems = todoItems?.filter("title CONTAINS[cd] %@", searchController.searchBar.text!)
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode: String) {
        //        guard let originalColor = UIColor(hexString: "1D98F6") else {
        //            fatalError()
        //        }
        guard let color = UIColor(hexString: colorHexCode) else { fatalError() }
        navigationController?.navigationBar.barTintColor = color
        navigationController?.navigationBar.tintColor = ContrastColorOf(color, returnFlat: true)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(color, returnFlat: true)]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
    //    override func didReceiveMemoryWarning() {
    //        super.didReceiveMemoryWarning()
    //        // Dispose of any resources that can be recreated.
    //    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filterTodoItems!.count
        }
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        var item: Item
        
        if isFiltering() {
            item = filterTodoItems![indexPath.row]
        } else {
            item = todoItems![indexPath.row]
        }
        
        cell.textLabel?.text = item.title
        // *********** important ***********
        if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat:true)
        }
        //        item.done == true ? cell.accessoryType = .checkmark : cell.accessoryType = .none
        
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
        
    }
    
    
    override func updateModel(at indexPath: IndexPath) {
        do {
            try realm.write {
                realm.delete(todoItems![indexPath.row])
            }
        } catch {
            print("update items error msg \(error)")
        }
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
                        newItem.dateCreated = Date()
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
//        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
//
////        let request: NSFetchRequest<Item> = Item.fetchRequest()
////
////        tableView.reloadData()
////
////        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
////
////        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
////
////        loadItems(with: request, predicate: predicate)
//        tableView.reloadData()
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

extension TodoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        
    }
}


