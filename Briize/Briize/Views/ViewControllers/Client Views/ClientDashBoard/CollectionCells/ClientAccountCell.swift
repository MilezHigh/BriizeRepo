//
//  ClientAccountCell.swift
//  Briize
//
//  Created by Miles Fishman on 11/8/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum UserAccountCellType {
    case Home
    case Prior
    case Live
}

struct ClientAccountCellModel {
    var type: UserAccountCellType
    var priorRequests: [RequestOrderModel] = []
    
    var id_name: String {
        var result: String = ""
        switch self.type {
        case .Home:
            result = "Account_Home"
            
        case .Prior:
            result = "Account_Prior"
            
        case .Live:
            result = "Account_Live"
        }
        return result
    }
}

extension ClientAccountCellModel {
    init(_ type: UserAccountCellType) {
        self.type = type
    }
}
