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
                guard let user = user,
                    let userObject = UserModel.create(from: user)
                    else {
                        return
                }
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
        servicesAppliedFor: [String]) -> Observable<(Bool, UserPartialModel?, Error?)> {
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
        user["state"] = "California" // model.state
        user["phone"] = model.phone
        user["servicesAppliedFor"] = servicesAppliedFor

        let hasCertification = certImageData != nil
        hasCertification ? user["certPhoto"] = certImageData?.pfFileObject() : ()

        return Observable<(Bool, UserPartialModel?, Error?)>.create { observer in
            user.signUpInBackground { (succeeded, error) in
                guard error == nil, succeeded
                    else {
                        if let err = error {
                            print("Error on User Sign Up - \(err.localizedDescription)")
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
                completion(
                    objects.map({ obj -> RequestOrderModel? in
                        guard let request = RequestOrderModel.create(from: obj)
                            else {
                                return nil
                        }
                        return request
                    })
                )
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
