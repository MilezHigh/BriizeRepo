//
//  NetworkManager.swift
//  Briize
//
//  Created by Admin on 5/19/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Parse

class NetworkManager {
    
    static let instance = NetworkManager()
    
    private init(){}
}

extension NetworkManager {
    
    func login(username: String, password: String, completion: @escaping (UserModel?) -> ()) {
        PFUser.logInWithUsername(
            inBackground : username,
            password     : password
        ) { (user, error) in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil)
            } else {
                guard let user = user, let userObject = UserModel.create(from: user)
                    else {
                        return
                }
                completion(userObject)
            }
        }
    }
    
    func pullPriorRequests(for clientID: String, completion: @escaping ([RequestOrderModel?]) -> ()) {
        let predicate = NSPredicate(format: "clientName = '\(clientID)' AND requestStatus = \(4)")
        let query = PFQuery(className: "Requests", predicate: predicate)
        query.findObjectsInBackground { (objects, error) in
            switch error != nil {
            case true:
                print("Error on pulling prior requests")
                completion([])
                
            case false:
                guard let objects = objects else { return }
                print(objects)
                completion(objects.map({obj -> RequestOrderModel? in
                    guard let request = RequestOrderModel.create(from: obj)
                        else {
                            return nil
                    }
                    return request
                }))
            }
        }
    }
    
    func pullUser(_ id: String, completion: @escaping (UserModel?) -> ()) {
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: id)
        query.getFirstObjectInBackground { (object, error) in
            switch error != nil {
            case true:
                print("Error on pulling user from API - \(error!.localizedDescription)")
                
                completion(nil)
                
            case false:
                if let object = object {
                    completion(UserModel.create(from: object))
                }
            }
        }
    }
    
    func postRequest(_ model: RequestOrderModel, status: Int, completion: @escaping (Bool, String?, Error?) -> ()) {
        let request = PFObject(className: "Requests")
        request["expertFullName"] = model.expertFullname
        request["expertName"] = model.expertID
        request["clientFullName"] = model.clientFullName
        request["clientName"] = model.clientID
        request["address"] = model.address
        request["requestStatus"] = status
        request["serviceType"] = model.serviceType
        request["serviceIds"] = model.serviceIds
        request["cost"] = model.cost
        request["payToExpert"] = model.payToExpert
        request["profit"] = model.profit
        
        request.saveInBackground { (success, error) in
            guard error == nil
                else {
                    completion(false, nil, error)
                    return
            }
            let predicate = NSPredicate(format: "clientName = '\(model.clientID)' AND requestStatus = \(status)")
            let query = PFQuery(className: "Requests", predicate: predicate)
            
            query.findObjectsInBackground(block: { (objects, error) in
                guard error == nil
                    else {
                        completion(false, nil, error)
                        return
                }
                guard let object = objects?.first
                    else {
                        completion(false, nil, nil) // Place Error
                        return
                }
                completion(success, object.objectId, nil)
            })
        }
    }
    
    func checkRequestState(from requestId: String, completion: @escaping (RequestState) -> ()) {
        let predicate = NSPredicate(format: "objectId = '\(requestId)'")
        let query = PFQuery(className: "Requests", predicate: predicate)
        query.findObjectsInBackground(block: { (objects, error) in
            guard error == nil else {
                return
            }
            guard let object = objects?.first else {
                return
            }
            completion(RequestState.create(from: (object["requestStatus"] as? Int) ?? 0))
        })
    }
    
    func pullInstagramPhotos(completion: @escaping ([String]) -> ()) {
        
    }
}

// Review Below
extension NetworkManager {
    
    static func convertUrlStringToImageSync(_ urlString:String) -> UIImage? {
        guard let url = URL(string:urlString),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data:data)
            else {
                return nil
        }
        return image
    }
}

extension NetworkManager {
    
    class func convertPFObjectToMultipleSectionModel(_ object: PFObject) -> MultipleSectionModel? {
        guard
            let objId = object.objectId,
            let name = object["fullName"] as? String,
            let imageFile = object["profilePhoto"] as? PFFileObject
            else {
                return nil
        }
        let userModel = UserModel()
        
        return MultipleSectionModel.IndividualExpertSection(
            title: userModel.name,
            items: [SectionItem.IndividualExpertItem(model: userModel)]
        )
    }
}
