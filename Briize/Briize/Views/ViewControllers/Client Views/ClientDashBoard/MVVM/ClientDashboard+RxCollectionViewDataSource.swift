//
//  UserAccountCollectionViewDataSource.swift
//  Briize
//
//  Created by Miles Fishman on 11/11/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

extension ClientDashboardViewController {
    
    static func dataSource() -> RxCollectionViewSectionedReloadDataSource<AccountSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<AccountSectionModel>(
            configureCell: { (dataSource, collection, idxPath, _) in
                switch dataSource[idxPath] {
                case let .home(model):
                    let cell: AccountHomeCollectionCell = collection.dequeueReusableCell(withReuseIdentifier: "Account_Home", for: idxPath) as! AccountHomeCollectionCell
                    cell.model = model
                    return cell
                    
                case let .prior(model):
                    let cell: AccountPriorCollectionCell = collection.dequeueReusableCell(withReuseIdentifier: "Account_Prior", for: idxPath) as! AccountPriorCollectionCell
                    cell.model = model
                    return cell
                }
        },
            configureSupplementaryView: { _, _, dataSource, index in
                return UICollectionReusableView()
        })
    }
}

enum AccountSectionModel {
    case accountOptions(title: String, items: [AccountSectionItem])
}

enum AccountSectionItem {
    case home(model: ClientAccountCellModel)
    case prior(model: ClientAccountCellModel)
}

extension AccountSectionModel: SectionModelType {
    typealias Item = AccountSectionItem
    
    var items: [AccountSectionItem] {
        switch self {
        case .accountOptions(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    init(original: AccountSectionModel, items: [Item]) {
        switch original {
        case let .accountOptions(title: title, items: _):
            self = .accountOptions(title: title, items: items)
        }
    }
}

extension AccountSectionModel {
    var title: String {
        switch self {
        case .accountOptions(title: let title, items: _):
            return title
        }
    }
}
