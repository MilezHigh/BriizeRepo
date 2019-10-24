//
//  CategoryModel.swift
//  Briize
//
//  Created by Miles Fishman on 6/2/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit

struct CategoryModel {
    var name:String = ""
    var image: UIImage = #imageLiteral(resourceName: "Briizelogo")
}

extension CategoryModel {
    
    static func createFixedCategories() -> [CategoryModel] {
         let hair = CategoryModel(name: "Hair", image: #imageLiteral(resourceName: "hairImg"))
               let makeUp = CategoryModel(name: "Make-Up", image: #imageLiteral(resourceName: "makeUpImg"))
               let eyesbrows = CategoryModel(name: "Eyes & Brows", image: #imageLiteral(resourceName: "eyesBrowsImg"))
               let nails = CategoryModel(name: "Nails", image: #imageLiteral(resourceName: "nailsImg"))
               let mens = CategoryModel(name: "Men's", image: #imageLiteral(resourceName: "menImg"))
               let categories = [
                   hair, makeUp, eyesbrows, nails, mens
               ]
               return  categories
    }
}
