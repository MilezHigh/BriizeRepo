//
//  Client.swift
//  Briize
//
//  Created by Admin on 6/2/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxDataSources
import RxSwift
import RxCocoa

class User {
    
    // Session Vars
    var model = BehaviorRelay<UserModel?>(value:nil)
    var userProfileImage: UIImage? = nil
    
    // Search for an Expert Vars
    let openCategorySelection = BehaviorRelay<Bool>(value:false)
    let openSelectaDateForRequest = BehaviorRelay<Bool>(value: false)
    
    let searchServicesWasPressed = BehaviorRelay<Bool>(value:false)
    let searchExpertsWithTheseServices = BehaviorRelay<[Int]>(value:[])
    
    // Selected Category Vars
    let selectedCategoryImage = BehaviorRelay<UIImage?>(value: nil)
    let selectedCategoryName = BehaviorRelay<String>(value: "")
    let selectedCategoryServices = BehaviorRelay<[ServiceModel]>(value: [])

    // Convinience vars
    var persistedServiceNames:[String] = []
    
    init(){}
}
