//
//  UserDefaultsManager.swift
//  Briize
//
//  Created by Miles Fishman on 4/30/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation

enum UDKey: String {
    case requestId = "SESSION_REQUEST_ID"
    case requestTimeInterval = "SESSION_REQUEST_TIME_REMAINING"
}

class UserDefaultsManager {
    
    // Methods
    static func saveRequest(id: String) {
        UserDefaults.standard.set(id, forKey: UDKey.requestId.rawValue)
    }
    
    static func saveRequestTimer(interval: TimeInterval) {
        UserDefaults.standard.set(interval, forKey: UDKey.requestTimeInterval.rawValue)
    }
    
    // Vars
    static var currentRequestId: String? {
        return UserDefaults.standard.value(forKey: UDKey.requestId.rawValue) as? String
    }
    
    static var currentRequestTimeInterval: TimeInterval? {
        return UserDefaults.standard.value(forKey: UDKey.requestTimeInterval.rawValue) as? TimeInterval
    }
}
