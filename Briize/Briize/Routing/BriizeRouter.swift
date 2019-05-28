//
//  BriizeRouter.swift
//  Briize
//
//  Created by Miles Fishman on 4/30/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit

class BriizeRouter {
    
    static var RequestOrderVC: RequestOrderViewController? {
        let storyboard = UIStoryboard(name: "RequestOrder", bundle: nil)
        return storyboard.instantiateInitialViewController() as? RequestOrderViewController
    }
}
