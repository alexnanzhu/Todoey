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
    let searchController = UISearchController(searchResultsController: nil)

    

    var categoryArray: Results<Category>?
    var filteredCategoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadCategory()
        
        tableView.rowHeight = 80
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true


    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCategoryArray = categoryArray?.filter("name CONTAINS[cd] %@", searchController.searchBar.text!)
        tableView.reloadData()
    }

    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return categoryArray.count
    //    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredCategoryArray?.count ?? 1
        }

        return categoryArray?.count ?? 1
    }
    


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "CatagoryCell") as! SwipeTableViewCell
        //        cell.delegate = self
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        var category: Category
        if isFiltering() {
            category = filteredCategoryArray![indexPath.row]
        } else {
            category = categoryArray![indexPath.row]
        }
        cell.textLabel?.text = category.name
        cell.backgroundColor = UIColor(hexString: category.color)
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
//extension CatagoryTableViewController: UISearchBarDelegate {
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//
//        categoryArray = categoryArray?.filter("name CONTAINS[cd] %@", searchBar.text!)
//
//
//        tableView.reloadData()
//
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            loadCategory()
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//        }
//
//    }
//}

extension CatagoryTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)

    }
}
