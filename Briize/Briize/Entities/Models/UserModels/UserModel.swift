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

struct UserModel: Equatable {
    var name:String = ""
    var price:String = ""
    var state:String = ""
    var phone:String = ""
    var rating:Double? = 0
    var email:String = ""
    var id:String = ""
    var distance:String = ""
    var isExpert: Bool = false
    var servicesOffered: [NSMutableDictionary] = []
    var servicesApprovedFor: [Int] = []
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
        let servicesOffered = user["servicesOffered"] as? NSMutableDictionary ?? [:]
        let services = servicesOffered["data"] as? [NSMutableDictionary] ?? []
        let servicesApprovedFor = user["servicesApprovedFor"] as? [Int] ?? []
        let currentLocation = user["currentLocation"] as? PFGeoPoint ?? PFGeoPoint()
        
        return UserModel(name            : name,
                         price           : "",
                         state           : state,
                         phone           : phone,
                         rating          : rating,
                         email           : email,
                         id              : id,
                         distance        : "",
                         isExpert        : isExpert,
                         servicesOffered : services,
                         servicesApprovedFor: servicesApprovedFor,
                         urlString       : profilePic,
                         currentLocation : currentLocation
        )
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
        let servicesOffered = user["servicesOffered"] as? NSMutableDictionary ?? [:]
        let services = servicesOffered["data"] as? [NSMutableDictionary] ?? []
        let servicesApprovedFor = user["servicesApprovedFor"] as? [Int] ?? []
        let currentLocation = user["currentLocation"] as? PFGeoPoint ?? PFGeoPoint()
        
        return UserModel(name            : name,
                         price           : "",
                         state           : state,
                         phone           : phone,
                         rating          : rating,
                         email           : email,
                         id              : id,
                         distance        : "",
                         isExpert        : isExpert,
                         servicesOffered : services,
                         servicesApprovedFor: servicesApprovedFor,
                         urlString       : profilePic,
                         currentLocation : currentLocation)
    }
    
    /// - Turn into update user on DB:
    //    static func create(from user: UserModel?) -> UserModel? {
    //       guard let user = user,
    //            let isExpert = user["isExpert"] as? Bool,
    //            let name = user["fullName"] as? String,
    //            let state = user["state"] as? String,
    //            let phone = user["phone"] as? String,
    //            let email = user["email"] as? String,
    //            let id = user.objectId
    //            else {
    //                return nil
    //        }
    //        let profilePic = user["profilePhoto"] as? PFFileObject ?? nil
    //        let rating = user["rating"] as? Double ?? nil
    //        let servicesOffered = user["servicesOffered"] as? NSMutableDictionary ?? [:]
    //        let services = servicesOffered["data"] as? [NSMutableDictionary] ?? []
    //        let servicesApprovedFor = user["servicesApprovedFor"] as? [Int] ?? []
    //
    //        return UserModel(name            : name,
    //                         price           : "",
    //                         state           : state,
    //                         phone           : phone,
    //                         rating          : rating,
    //                         email           : email,
    //                         id              : id,
    //                         distance        : "",
    //                         isExpert        : isExpert,
    //                         servicesOffered : services,
    //                         servicesApprovedFor: servicesApprovedFor,
    //                         urlString       : profilePic,
    //                         currentLocation : nil)
    //    }
}
