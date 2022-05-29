//
//  CategoryViewController.swift
//  EveryDay
//
//  Created by Ruslan Sadritdinov on 22.05.2022.
//

import UIKit
import CoreData
import ChameleonFramework



class CategoryViewController: SwipeTableViewController {

    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller Does Not Exist")}
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
    }



    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        if let hexColor = category.colorHex {
           
            guard let categoryColor = UIColor(hexString: hexColor) else {fatalError()}
            
            cell.backgroundColor = categoryColor
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        

        return cell

    }
    
    //MARK: - tableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    
    func saveCategories() {
                  
          do {
              try context.save()
          } catch {
              print("error saving categories: \(error)")
          }
          
          self.tableView.reloadData()
          
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {

        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    //MARK: - Delete Method From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
                    self.context.delete(self.categoryArray[indexPath.row])
        
                    self.categoryArray.remove(at: indexPath.row)
        
                    self.saveCategories()
                    
                    tableView.reloadData()
    }
    
    //MARK: - Add Button Methods
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            
            newCategory.name = textField.text!
            
            newCategory.colorHex = UIColor.randomFlat().hexValue()
            
            self.categoryArray.append(newCategory)
            
            self.saveCategories()
        }
        
        alert.addTextField{(alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}

