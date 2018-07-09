//
//  Category.swift
//  Todoey
//
//  Created by Alex Z on 7/7/18.
//  Copyright © 2018 Alex Nan Zhu. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    //to-many realtion
    let items = List<Item>()
    
}
