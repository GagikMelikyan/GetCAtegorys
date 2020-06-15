//
//  Product.swift
//  GetCategories
//
//  Created by Hayk Brsoyan on 11/16/18.
//  Copyright © 2018 Hayk Movsesyan. All rights reserved.
//

import Foundation

class Product {
    private(set) var name: String!
    private(set) var imageStringUrl: String!
    
    init(name: String, imageStringUrl: String) {
        self.name = name
        self.imageStringUrl = imageStringUrl
    }
}
