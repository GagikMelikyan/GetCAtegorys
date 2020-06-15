//
//  CategoriesViewController.swift
//  getpost
//
//  Created by Hayk Movsesyan on 11/10/18.
//  Copyright © 2018 Hayk Movsesyan. All rights reserved.
//

import UIKit

class CategoriesViewController: UITableViewController{
    
    private var categories = [Category]()
    let session = URLSession(configuration: .default)
    let host = "http://jin.am"
    let categoriesPath = "/api/jin/categories"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellReuseIdentifier: CategoryCell.id)
        UIApplication.appDelegate.dataProvider.getCategories(categoriesPath: categoriesPath) { [weak self] (categories) in
            self?.categories = categories
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.id, for: indexPath) as! CategoryCell
        cell.titleLabel.text = categories[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "SubCategoriesViewController") as! SubCategoriesViewController
        vc.subCategoriesPath = "/api/jin/subcategorie_by_parent_id/" + String(categories[indexPath.row].id) + "/"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
