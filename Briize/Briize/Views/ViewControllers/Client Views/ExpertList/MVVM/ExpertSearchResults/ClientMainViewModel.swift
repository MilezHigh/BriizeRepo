//
//  ClientMainViewModel.swift
//  Briize
//
//  Created by Admin on 5/19/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa
import Parse

class ClientMainViewModel {
    private let disposeBag = DisposeBag()
    
    let experts = BehaviorRelay<[MultipleSectionModel]>(value:[])
    
    init(){}
}

extension ClientMainViewModel {
    
    // make dry
    func demoFindObjects(with selectedServices: [Int]) {
        var exps:[PFObject] = []
        
        let query = PFQuery(className: "_User")
        query.findObjectsInBackground { (objects, error) in
            
            if error == nil && objects != nil {
                exps = objects!
            } else if error != nil {
                print(error?.localizedDescription ?? "Can't find users")
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
                    guard let expertMultiSectionModel = BriizeUtility.convertPFObjectToMultipleSectionModel(exp)
                        else { return nil }
                    return expertMultiSectionModel
                })
            
            DispatchQueue.main.async { [weak self] in
                self?.experts.accept([
                    MultipleSectionModel.IndividualExpertSection(
                        title: "",
                        items: results
                    )]
                )
            }
        }
    }
}

extension ClientMainViewModel {
    
    func convertPFObjectToMultipleSectionModel(_ object: PFObject) -> SectionItem? {
        guard
            let objId = object.objectId,
            let name = object["fullName"] as? String,
            let imageFile = object["profilePhoto"] as? PFFileObject,
            let rating = object["rating"] as? Double,
            let servicesOffered = object["servicesOffered"] as? NSDictionary,
            let data = servicesOffered["data"] as? [NSDictionary]
            // Complete expert model for expert result page
            else { return nil }
        
        let price: Int = data
            .map ({ (dic) -> Int in
                guard let price = dic["cost"] as? Int else { return 0 }
                return price
            })
            .reduce(0, +)
        
        let location: PFGeoPoint? = object["currentLocation"] as? PFGeoPoint
        
        let userModel = UserModel.init(
            name: name,
            price: "$\(price.description)",
            state: "",
            phone: "",
            rating: rating,
            email: "",
            id: objId,
            distance: "",
            isExpert: true,
            urlString: imageFile,
            currentLocation: location
        )
        
        return SectionItem.IndividualExpertItem(model: userModel)
    }
}

extension ClientMainViewModel {
    func dataSource() -> RxTableViewSectionedReloadDataSource<MultipleSectionModel> {
        return RxTableViewSectionedReloadDataSource<MultipleSectionModel>(
            configureCell: { (dataSource, table, idxPath, _) in
                switch dataSource[idxPath] {
                case let .IndividualExpertItem(model):
                    let cell: ExpertTableViewCell? = table
                        .dequeueReusableCell(withIdentifier: "expertCell", for: idxPath)
                        as? ExpertTableViewCell
                    
                    cell?.model = model
                    return cell ?? UITableViewCell()
                    
                case .ClientCustomOrder:
                    return UITableViewCell()
                }
        })
    }
}


//Tableview MultiSection Enums
enum MultipleSectionModel {
    case IndividualExpertSection(title: String, items: [SectionItem])
}

enum SectionItem {
    case IndividualExpertItem(model: UserModel)
    case ClientCustomOrder(model: UserModel)
    
    var model: UserModel? {
        switch self {
        case .IndividualExpertItem(let m):
            return m
        
        case .ClientCustomOrder(let m):
            return m
        }
    }
}

extension MultipleSectionModel: SectionModelType {
    typealias Item = SectionItem
    
    var items: [SectionItem] {
        switch  self {
        case .IndividualExpertSection(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    init(original: MultipleSectionModel, items: [Item]) {
        switch original {
        case let .IndividualExpertSection(title: title, items: _):
            self = .IndividualExpertSection(title: title, items: items)
        }
    }
}

extension MultipleSectionModel {
    var title: String {
        switch self {
        case .IndividualExpertSection(title: let title, items: _):
            return title
        }
    }
}

