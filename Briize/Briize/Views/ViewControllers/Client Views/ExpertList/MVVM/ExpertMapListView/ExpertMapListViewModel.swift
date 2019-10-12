//
//  ExpertMapListViewModel.swift
//  Briize
//
//  Created by Miles Fishman on 10/9/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation

class ExpertMapListViewModel {
    
    var experts: [UserModel?] = []
    
    init(experts: [UserModel?]) {
        self.experts = experts
    }
}
