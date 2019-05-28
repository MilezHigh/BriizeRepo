//
//  ClientModel.swift
//  Briize
//
//  Created by Admin on 5/21/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import Parse

struct UserModel {
    var name:String = ""
    var price:String = ""
    var state:String = ""
    var phone:String = ""
    var rating:Double? = 0
    var email:String = ""
    var id:String = ""
    var distance:String = ""
    var isExpert: Bool = false
    var urlString: PFFileObject?
    var currentLocation: PFGeoPoint?
    
    static func create(from user: PFUser?) -> UserModel? {
        guard let user = user,
            let isExpert = user["isExpert"] as? Bool,
            let name = user["fullName"] as? String,
            let state = user["state"] as? String,
            let phone = user["phone"] as? String,
            let email = user["email"] as? String,
            let id = user.objectId
            else {
                return nil
        }
        let profilePic = user["profilePhoto"] as? PFFileObject ?? nil
        let rating = user["rating"] as? Double ?? nil
        
        return UserModel(name             : name,
                          price           : "",
                          state           : state,
                          phone           : phone,
                          rating          : rating,
                          email           : email,
                          id              : id, distance: "",
                          isExpert        : isExpert,
                          urlString       : profilePic,
                          currentLocation : nil)
    }
    
    static func create(from user: PFObject?) -> UserModel? {
        guard let user = user,
            let isExpert = user["isExpert"] as? Bool,
            let name = user["fullName"] as? String,
            let state = user["state"] as? String,
            let phone = user["phone"] as? String,
            let email = user["email"] as? String,
            let id = user.objectId
            else {
                return nil
        }
        let profilePic = user["profilePhoto"] as? PFFileObject ?? nil
        let rating = user["rating"] as? Double ?? nil
        
        return UserModel(name             : name,
                         price           : "",
                         state           : state,
                         phone           : phone,
                         rating          : rating,
                         email           : email,
                         id              : id, distance: "",
                         isExpert        : isExpert,
                         urlString       : profilePic,
                         currentLocation : nil)
    }
}
