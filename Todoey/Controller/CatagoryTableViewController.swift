//
//  CatagoryTableViewController.swift
//  Todoey
//
//  Created by Alex Z on 7/6/18.
//  Copyright © 2018 Alex Nan Zhu. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CatagoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    

    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var categoryArray: Results<Category>?
    
    //    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadCategory()
        
        tableView.rowHeight = 80
        print("load them")
    }
    
    
    
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return categoryArray.count
    //    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "CatagoryCell") as! SwipeTableViewCell
        //        cell.delegate = self
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "no category"
        cell.backgroundColor = UIColor(hexString: categoryArray?[indexPath.row].color ?? "FFFFFF")
//        tableView.backgroundColor = UIColor.randomFlat
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat:true)
        tableView.separatorStyle = .none
        
        return cell
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "add category", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textfield.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            self.saveCategory(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category here"
            textfield = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    //MARK: - Data Manupulation Methods
    
    func saveCategory(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Save category error msg: \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    func loadCategory() {
        //        do {
        //            categoryArray = try context.fetch(request)
        //        } catch {
        //            print("load categorys error msg: \(error)")
        //        }
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
//        handle action by updating model with deletion
        
        do {
            try realm.write {
                realm.delete(categoryArray![indexPath.row])
            }
        } catch {
            print("deleting error: \(error)")
        }
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
            
        }
    }
    
    
    
}

//
extension CatagoryTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        categoryArray = categoryArray?.filter("name CONTAINS[cd] %@", searchBar.text!)
        

        tableView.reloadData()

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadCategory()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
    }
}
