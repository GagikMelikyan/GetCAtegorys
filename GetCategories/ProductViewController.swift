//
//  ProductViewController.swift
//  GetCategories
//
//  Created by Hayk Brsoyan on 11/16/18.
//  Copyright © 2018 Hayk Movsesyan. All rights reserved.
//

import UIKit


class ProductViewController: UITableViewController {
    
    var subCategoryId: Int!
    var products: [Product] = []
    var cellLocation: [String: IndexPath] = [:] // imageURl : indexPath
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        
        UIApplication.appDelegate.dataProvider.getProduct(subCategoryId: subCategoryId) {[weak self] (productList) in
            
            if let products = productList {
                if !products.isEmpty {
                    self?.products = products
                    self?.tableView.reloadData()
                }
            }
        }
        
        UIApplication.appDelegate.dataProvider.delegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        cell.nameLable.text = products[indexPath.row].name
        cellLocation[products[indexPath.row].imageStringUrl] = indexPath
        UIApplication.appDelegate.dataProvider.dowloadImageWithUrl(products[indexPath.row].imageStringUrl)
        return cell
    }

}

extension ProductViewController: DataProviderDelegate {
    func didFinishDowloadImage(image: UIImage?, urlString: String) {
        if let indexPath = cellLocation[urlString] {
            if let cell = tableView.cellForRow(at: indexPath) as? ProductCell {
                cell.productImageView?.image = image
            }
        }
    }
    
    func downloadedImageWith(progress: Float, fileSize: String, urlString: String) {
        if let indexPath = cellLocation[urlString] {
            if let cell = tableView.cellForRow(at: indexPath) as? ProductCell {
                cell.progerssView.progress = progress
                cell.progressLabel.text = "\(Int(progress * 100)) % -> Size \(fileSize)"
            }
        }
    }
}
