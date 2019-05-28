//
//  RequestOrderModel.swift
//  Briize
//
//  Created by Miles Fishman on 11/15/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import Parse

struct RequestOrderModel {
    var id: String?
    var clientID:String
    var clientFullName:String
    var expertID:String
    var expertFullname:String
    var serviceType:String
    var serviceIds:[Int]
    var address:String
    var startTime:Date?
    var finishTime:Date?
    var requestStatus:Int
    var cost:Int
    var payToExpert:Int
    var profit:Int
}

extension RequestOrderModel {
    
    static func create(from object: PFObject) -> RequestOrderModel? {
        guard
            let id: String = object.objectId,
            let clientID: String = object["clientName"] as? String,
            let clientFullname: String = object["clientFullName"] as? String,
            let expertID: String = object["expertName"] as? String,
            let expertFullName: String = object["expertFullName"] as? String,
            let serviceType: String = object["serviceType"] as? String,
            let address: String = object["address"] as? String,
            let startTime: Date = object["startTime"] as? Date,
            let finishTime: Date = object["finishTime"] as? Date,
            let requestStatus: Int = object["requestStatus"] as? Int,
            let cost: Int = object["cost"] as? Int,
            let payToExpert: Int = object["payToExpert"] as? Int,
            let profit: Int = object["profit"] as? Int,
            let serviceIds: [Int] = object["serviceIds"] as? [Int]
            else {
                return  nil
        }
        return RequestOrderModel(
            id: id,
            clientID: clientID,
            clientFullName: clientFullname,
            expertID: expertID,
            expertFullname: expertFullName,
            serviceType: serviceType,
            serviceIds: serviceIds,
            address: address,
            startTime: startTime,
            finishTime: finishTime,
            requestStatus: requestStatus,
            cost: cost,
            payToExpert: payToExpert,
            profit: profit
        )
    }
}
