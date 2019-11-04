//
//  NetworkManager.swift
//  Briize
//
//  Created by Miles Fishman on 5/19/18.
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
    
    func login(username: String, password: String, completion: @escaping (UserModel?) -> Void) {
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error on Login")
                completion(nil)
            } else {
                guard let user = user, let userObject = UserModel
                    .create(from: user) else { return }
                completion(userObject)
            }
        }
    }
    
    func logout() -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            PFUser.logOutInBackground { (error) in
                guard error == nil else {
                    guard let err = error else {
                        observer.onCompleted()
                        return
                    }
                    print("Error on logout - \(err.localizedDescription)")
                    observer.onError(err)
                    observer.onCompleted()
                    return
                }
                print("User Logged Out")
                observer.onNext(true)
                observer.onCompleted()
            }
            
            return Disposables.create {
                PFUser.logOut()
            }
        }
    }
    
    func signUpUser(
        model             : UserPartialModel,
        certImageData     : Data?,
        servicesAppliedFor: [String]
    ) -> Observable<(Bool, UserPartialModel?, Error?)> {
        let user = PFUser()
        user.username = model.email
        user.password = model.password
        user.email = model.email
        
        let isExpert = !servicesAppliedFor.isEmpty
        user["isExpert"] = isExpert
        user["fullName"] = model.firstName + model.lastName
        user["username"] = model.email
        user["email"] = model.email
        user["password"] = model.password
        user["state"] = "California" // <-> model.state
        user["phone"] = model.phone
        user["servicesAppliedFor"] = servicesAppliedFor
        
        let hasCertification = certImageData != nil
        hasCertification ? user["certPhoto"] = certImageData?.pfFileObject() : ()
        
        return Observable<(Bool, UserPartialModel?, Error?)>.create { observer in
            user.signUpInBackground { (succeeded, error) in
                guard error == nil, succeeded else {
                    if let err = error {
                        print("Error - \(err.localizedDescription)")
                        observer.onNext((false, nil , error))
                        observer.onCompleted()
                    }
                    return
                }
                print("User Signed Up")
                observer.onNext((succeeded, model, nil))
                observer.onCompleted()
            }
            
            return Disposables.create { }
        }
    }
    
    func pullExpertsForRequest(
        selectedServices: [Int],
        completion      : @escaping ([SectionItem]) -> ()
    ) {
        var exps: [PFObject] = []
        let query = PFQuery(className: "_User")
        query.findObjectsInBackground { (objects, error) in
            
            if error == nil && objects != nil {
                exps = objects!
            } else if error != nil {
                print(error!.localizedDescription)
            }
            
            let results = exps
                .filter({ ($0["isOnline"] as? Bool) == true })
                .filter({
                    guard let services = $0["servicesOffered"] as? NSDictionary,
                        let arr = services["data"] as? NSArray else { return false }
                    
                    let newArr = arr
                        .map({ (service) -> Int in
                            guard let obj = service as? NSDictionary,
                                let id = obj["serviceId"] as? Int else { return 0 }
                            return id
                        })
                        .filter({ $0 != 0 })
                        .sorted()
                    
                    let sortedServices = selectedServices.sorted()
                    return newArr == sortedServices
                })
                .filter ({
                    //Calculate Distance
                    print($0)
                    return true
                })
                .compactMap ({ exp -> SectionItem? in
                    guard let expertMultiSectionModel = BriizeUtility
                        .convertPFObjectToMultipleSectionModel(exp) else { return nil }
                    return expertMultiSectionModel
                })
            
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    
    func pullRequests(
        for id: String = "",
        isExpert: Bool = false,
        status: Int = 5,
        isExactStatus: Bool = true,
        completion: @escaping ([RequestOrderModel?]) -> ()
    ) {
        let userIdKey = isExpert ? "expertName" : "clientName"
        let requestStatus = " AND requestStatus = \(status)"
        let incompleteRequestStatus = " AND requestStatus = \(status)"
        let statusPredicate = isExactStatus ? requestStatus : incompleteRequestStatus
        let predicateString = userIdKey + " = '\(id)'" + statusPredicate
        let predicate = NSPredicate(format: predicateString)
        let query = PFQuery(className: "Requests", predicate: predicate)
        query.findObjectsInBackground { (objects, error) in
            switch error != nil {
            case true:
                print("Error on pulling prior requests")
                completion([])
                
            case false:
                guard let objects = objects else { return } ; print(objects)
                completion(objects.map({ RequestOrderModel.create(from: $0) }))
            }
        }
    }
    
    func pullRequests(
        type: String,
        completion: @escaping ([RequestOrderModel?]) -> ()
    ) {
        let query = PFQuery(className: "Requests")
        query.whereKey("type", equalTo: type)
        query.findObjectsInBackground { (objects, error) in
            switch error != nil {
            case true:
                print("Error on pulling prior requests")
                completion([])
                
            case false:
                guard let objects = objects else { return } ; print(objects)
                completion(objects.map({ RequestOrderModel.create(from: $0) }))
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
    
    func postRequest(_ model: RequestOrderModel, status: Int = 1, completion: @escaping (Bool, String?, Error?) -> ()) {
        let request = model.createPFObject()
        request.saveInBackground { (success, error) in
            guard error == nil else {
                completion(false, nil, error)
                return
            }
            
            let predicate = NSPredicate(format: "clientName = '\(model.clientID)' AND requestStatus = \(status)")
            let query = PFQuery(className: "Requests", predicate: predicate)
            query.findObjectsInBackground(block: { (objects, error) in
                guard error == nil else {
                    completion(false, nil, error)
                    return
                }
                guard let object = objects?.first else {
                    completion(false, nil, nil) // <--- Place Error
                    return
                }
                completion(success, object.objectId, nil)
            })
        }
    }
    
    func checkRequestState(from requestId: String, completion: @escaping (RequestStatus) -> ()) {
        let predicate = NSPredicate(format: "objectId = '\(requestId)'")
        let query = PFQuery(className: "Requests", predicate: predicate)
        query.findObjectsInBackground(block: { (objects, error) in
            guard error == nil, let object = objects?.first else { return }
            completion(RequestStatus.create(from: (object["requestStatus"] as? Int) ?? 0))
        })
    }
    
    func pullInstagramPhotos(completion: @escaping ([String]) -> ()) {
        
    }
}

// updates to db
extension NetworkManager {
    
    func updateUserAddress(
        formatted: String,
        state    : String,
        zipcode  : String
    ) -> Observable<(Bool, Error?)> {
        return Observable<(Bool, Error?)>.create { observer in
            PFUser.current()?.fetchInBackground(block: { (object, error) in
                guard error == nil, let obj = object else {
                    guard let err = error else {
                        observer.onCompleted()
                        return
                    }; print("Error - \(err.localizedDescription)")
                    
                    DispatchQueue.main.async {
                        observer.onError(err)
                        observer.onCompleted()
                    }
                    return
                }
                obj["address"] = formatted
                obj["state"] = state
                obj["zipcode"] = zipcode
                obj.saveInBackground()
                
                DispatchQueue.main.async {
                    observer.onNext((true, nil))
                    observer.onCompleted()
                }
            })
            
            return Disposables.create {
                PFUser.logOut()
            }
        }
    }
    
    //sync method below
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
