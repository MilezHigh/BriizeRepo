//
//  RequestOrderModel.swift
//  Briize
//
//  Created by Miles Fishman on 11/15/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import Parse

// Insta Testing = https://api.instagram.com/v1/users/self/media/recent?access_token=1553613655.e65c9fd.81da2b500d9b450dbd1d63f193bcc891

struct RequestOrderModel {
    var id: String?
    var type: String?
    var clientID: String
    var clientFullName: String
    var expertID: String
    var expertFullname: String
    var serviceType: String
    var notes: String
    var serviceIds: [Int]
    var bids: [NSDictionary]
    var address: String
    var startTime: Date?
    var finishTime: Date?
    var createdAt: Date?
    var scheduledDate: Date?
    var requestStatus:Int
    var cost: Int
    var payToExpert: Int
    var profit: Int
    var clientAskingPrice: Int
    var beforeImage: Data?
    var afterImage: Data?
    var location: PFGeoPoint?
}

extension RequestOrderModel {
    
    static func create(from object: PFObject) -> RequestOrderModel? {
        guard
            let id: String = object.objectId,
            let type: String  = object["type"] as? String,
            let clientID: String = object["clientName"] as? String,
            let clientFullname: String = object["clientFullName"] as? String,
            let serviceType: String = object["serviceType"] as? String,
            let address: String = object["address"] as? String,
            let notes: String = object["notes"] as? String,
            let requestStatus: Int = object["requestStatus"] as? Int,
            let cost: Int = object["cost"] as? Int,
            let payToExpert: Int = object["payToExpert"] as? Int,
            let profit: Int = object["profit"] as? Int,
            let clientAskingPrice: Int = object["clientAskingPrice"] as? Int,
            let serviceIds: [Int] = object["serviceIds"] as? [Int]
            else {
                return nil
        }

        let expertFullName: String = object["expertFullName"] as? String ?? "n/a"
        let expertID: String = object["expertName"] as? String ?? "n/a"
        
        let bids: [NSDictionary] = object["bids"] as? [NSDictionary] ?? []
        
        let createdAt: Date? = (object["startTime"] as? NSDate) as Date?
        let startTime: Date? = object["startTime"] as? Date
        let finishTime: Date? = object["finishTime"] as? Date
        let scheduledTime: Date? = object["scheduledDate"] as? Date

        let beforeImage: PFFileObject? = object["beforeImage"] as? PFFileObject
        let afterImage: PFFileObject? = object["afterImage"] as? PFFileObject
        
        let location: PFGeoPoint = object["location"] as? PFGeoPoint ?? PFGeoPoint()

        var beforeData: Data?
        var afterData: Data?
        if beforeImage != nil && afterImage != nil {
            guard
                let before = try? beforeImage?.getData(),
                let after = try? afterImage?.getData()
                else {
                    fatalError("Parse Method 'getData' - RequestOrderModel")
            }
            beforeData = before
            afterData = after
        }

        return RequestOrderModel(
            id: id,
            type: type,
            clientID: clientID,
            clientFullName: clientFullname,
            expertID: expertID,
            expertFullname: expertFullName,
            serviceType: serviceType,
            notes: notes,
            serviceIds: serviceIds,
            bids: bids,
            address: address,
            startTime: startTime,
            finishTime: finishTime,
            createdAt: createdAt,
            scheduledDate: scheduledTime,
            requestStatus: requestStatus,
            cost: cost,
            payToExpert: payToExpert,
            profit: profit,
            clientAskingPrice: clientAskingPrice,
            beforeImage: beforeData,
            afterImage: afterData,
            location: location
        )
    }
}

extension RequestOrderModel {

    public func createPFObject() -> PFObject {
        let request = PFObject(className: "Requests")
        request["objId"] = id
        request["expertFullName"] = expertFullname
        request["expertFullName"] = expertFullname
        request["expertName"] = expertID
        request["clientFullName"] = clientFullName
        request["clientName"] = clientID
        request["address"] = address
        request["requestStatus"] = requestStatus
        request["serviceType"] = serviceType
        request["serviceIds"] = serviceIds
        request["cost"] = cost
        request["payToExpert"] = payToExpert
        request["profit"] = profit
        request["type"] = type
        request["bids"] = bids
        request["clientAskingPrice"] = clientAskingPrice
        request["location"] = location ?? PFGeoPoint()

        scheduledDate == nil ? () : (request["scheduledDate"] = scheduledDate)
        startTime == nil ? () : (request["startTime"] = startTime)
        finishTime == nil ? () : (request["finishTime"] = startTime)
        beforeImage == nil ? () : (request["beforeImage"] = PFFileObject(data: beforeImage!, contentType: "image/jpeg"))
        afterImage == nil ? () : (request["afterImage"] = PFFileObject(data: afterImage!, contentType: "image/jpeg"))

        return request
    }
}
