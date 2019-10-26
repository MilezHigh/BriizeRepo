//
//  ServiceModel.swift
//  Briize
//
//  Created by Miles Fishman on 6/5/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit

struct ServiceModel {
    var id       : Int = 0 // Miles.F - not needed potentially
    var parent   : CategoryModel?
    var name     : String = ""
    var subTypes : [ServiceSubType] = []
}

enum ServiceSubType: String {
    
    /// * Hair *
    ///
    /// - Braiding
    case waterfall_Braiding = "Waterfall Braiding"
    case french_Braiding    = "French Braiding"
    case strand_Braiding    = "Strand Braiding"
    case mermaid_Braiding   = "Mermaid Braiding"
    case color              = "Color"
    case womensHaircut      = "Womens Haircut"

    /// - Extensions
    case bonded_Extensions = "Bonded Extensions"
    case weft_Extensions   = "Weft Extensions"
    case weave_Extensions  = "Weave Extensions"

    /// - Updue
    case messyUpdue = "Messy Updue"
    case braidedUpdue = "Braided Updue"
    case chignonUpdue  = "Chignon Updue"

    /// - Blow Dry
    case oldFashionedWaves = "Old Fashioned Waves"
    case straightWithBody = "Straight w/ Body"
    case looseCurls  = "Loose Curls"
    case beachCurls  = "Beach Curls"
    case volumeCurls  = "Volume Curls"
    case classicSmooth  = "Classic Smooth"

    /// - Cut
    case womens_haircut = "Women's Haircut"
    case girls_haircut = "Girls Haircut"
    
    /// * Eyes & Brows *
    ///
    /// - Threading
    case eyebrows = "Eye-Brows"
    case upperLip = "Upper Lip"
    case fullFace = "Full Face"

    /// - Waxing
    case eyebrowsWax = "Eye-Brow "
    case upperLipWax = "Upper Lip "
    
    /// * Nails *
    ///
    /// - Manicure / Pedicure
    case regular = "Regular"
    case acrylic = "Acrylic"
    case gel = "Gel"
    
    var id : Int {
        switch self {
        case .womens_haircut :
            return 1
        case .girls_haircut :
            return 2
        case .messyUpdue :
            return 4
        case .braidedUpdue :
            return 5
        case .chignonUpdue  :
            return 6
        case .oldFashionedWaves :
            return 7
        case .straightWithBody :
            return 8
        case .looseCurls :
            return 9
        case .beachCurls :
            return 10
        case .volumeCurls :
            return 11
        case .classicSmooth :
            return 12
        case .waterfall_Braiding :
            return 13
        case .french_Braiding :
            return 14
        case .strand_Braiding :
            return 15
        case .mermaid_Braiding :
            return 16
        case .bonded_Extensions :
            return 17
        case .weft_Extensions :
            return 18
        case .weave_Extensions :
            return 19
        case .regular :
            return 25
        case .acrylic :
            return 26
        case .gel :
            return 27
        case .eyebrows :
            return 31
        case .upperLip :
            return 32
        case .fullFace :
            return 33
        case .eyebrowsWax :
            return 34
        case .upperLipWax :
            return 35
        case .color:
            return 3
        case .womensHaircut:
            return 1
        }
    }
    
    static func serviceNameFor(id: Int) -> String {
        switch id {
        case 1 :
            return "Womens Haircut"
        case 2 :
            return "Girls Haircut"
        case 3:
            return "Color"
        case 4 :
            return "Messy Updue"
        case 5 :
            return "Braided Updue"
        case 6  :
            return "Chingon Updue"
        case 7 :
            return "Old Fashioned Waves"
        case 8 :
            return "Straight With Body"
        case 9 :
            return "Loose Curls"
        case 10 :
            return "Beach Curls"
        case 11 :
            return "Volume Curls"
        case 12 :
            return "Classic Smooth"
        case 13 :
            return "Waterfall Braiding"
        case 14 :
            return "French Braiding"
        case 15 :
            return "Strand Braiding"
        case 16 :
            return "Mermaid Braiding"
        case 17 :
            return "Bonded Extensions"
        case 18 :
            return "Weft Extensions"
        case 19 :
            return "Weave Extensions"
        case 25 :
            return "Regular"
        case 26 :
            return "Acrylic"
        case 27 :
            return "Gel"
        case 31 :
            return "Eyebrows"
        case 32 :
            return "Upper Lip"
        case 33 :
            return "Full Face"
        case 34 :
            return "Eyebrow Wax"
        case 35 :
            return "Upper Lip Wax"
        default:
            return ""
        }
    }
    
    static func shortNameFor(id: Int) -> String {
        switch id {
        case 1 :
            return "Haircut"
        case 2 :
            return "Haircut"
        case 3 :
            return "Color"
        case 4 :
            return "Updue"
        case 5 :
            return "Updue"
        case 6  :
            return "Updue"
        case 7 :
            return "Blow-Dry"
        case 8 :
            return "Blow-Dry"
        case 9 :
            return "Blow-Dry"
        case 10 :
            return "Blow-Dry"
        case 11 :
            return "Blow-Dry"
        case 12 :
            return "Blow-Dry"
        case 13 :
            return "Braiding"
        case 14 :
            return "Braiding"
        case 15 :
            return "Braiding"
        case 16 :
            return "Braiding"
        case 17 :
            return "Hair Extensions"
        case 18 :
            return "Hair Extensions"
        case 19 :
            return "Hair Extensions"
        case 25 :
            return "Nails"
        case 26 :
            return "Nails"
        case 27 :
            return "Nails"
        case 31 :
            return "Brow Threading"
        case 32 :
            return "Brow Threading"
        case 33 :
            return "Brow Threading"
        case 34 :
            return "Waxing"
        case 35 :
            return "Waxing"
        default:
            return ""
        }
        
    }
}

extension ServiceModel {
    
    static func addServicesToCategory(_ category: CategoryModel) -> [ServiceModel]  {
        switch category.name {
        case "Hair":
            return [
                ServiceModel(
                    id: 0, parent: category, name: "Cut", subTypes: [
                        ServiceSubType.womens_haircut,
                        ServiceSubType.girls_haircut
                    ]),
                ServiceModel(
                    id: 3, parent: category, name: "Color", subTypes: []),
                ServiceModel(
                    id: 0, parent: category, name: "Updue", subTypes: [
                        ServiceSubType.messyUpdue,
                        ServiceSubType.braidedUpdue,
                        ServiceSubType.chignonUpdue
                    ]),
                ServiceModel(
                    id: 0, parent: category, name: "Blow-Dry", subTypes: [
                        ServiceSubType.oldFashionedWaves,
                        ServiceSubType.straightWithBody,
                        ServiceSubType.looseCurls,
                        ServiceSubType.beachCurls,
                        ServiceSubType.volumeCurls,
                        ServiceSubType.classicSmooth
                    ]),
                ServiceModel(
                    id: 0, parent: category, name: "Braiding", subTypes: [
                        ServiceSubType.waterfall_Braiding,
                        ServiceSubType.french_Braiding,
                        ServiceSubType.strand_Braiding,
                        ServiceSubType.mermaid_Braiding
                    ]),
                ServiceModel(
                    id: 0, parent: category, name: "Extensions", subTypes: [
                        ServiceSubType.bonded_Extensions,
                        ServiceSubType.weft_Extensions,
                        ServiceSubType.weave_Extensions
                    ]),
            ]
            
        case "Make-Up":
            return [
                ServiceModel(
                    id: 20, parent: category, name: "Bridal", subTypes: []),
                ServiceModel(
                    id: 21, parent: category, name: "Costume", subTypes: []),
                ServiceModel(
                    id: 22, parent: category, name: "Airbrush", subTypes: []),
                ServiceModel(
                    id: 23, parent: category, name: "Evening", subTypes: []),
                ServiceModel(
                    id: 24, parent: category, name: "Glamorous", subTypes: [])
            ]
            
        case "Nails":
            return [
                ServiceModel(
                    id: 0, parent: category, name: "Manicure", subTypes: [
                        ServiceSubType.regular,
                        ServiceSubType.acrylic,
                        ServiceSubType.gel
                    ]),
                ServiceModel(
                    id: 0, parent: category, name: "Pedicure", subTypes: [
                        ServiceSubType.regular,
                        ServiceSubType.gel
                    ]),
                ServiceModel(
                    id: 28, parent: category, name: "Acrylic Fill", subTypes: []),
                ServiceModel(
                    id: 29, parent: category, name: "Design", subTypes: []),
                ServiceModel(
                    id: 30, parent: category, name: "Gel/Acrylic Removal", subTypes: [])
            ]
            
        case "Eyes & Brows":
            return [
                ServiceModel(
                    id: 0, parent: category, name: "Threading", subTypes: [
                        ServiceSubType.eyebrows,
                        ServiceSubType.upperLip,
                        ServiceSubType.fullFace
                    ]),
                ServiceModel(
                    id: 0, parent: category, name: "Waxing", subTypes: [
                        ServiceSubType.eyebrowsWax,
                        ServiceSubType.upperLipWax
                    ]),
                ServiceModel(
                    id: 36, parent: category, name: "Micro-Blading", subTypes: []),
                ServiceModel(
                    id: 37, parent: category, name: "Eye Brow Tinting", subTypes: []),
                ServiceModel(
                    id: 38, parent: category, name: "Eye Lash Extensions", subTypes: []),
                ServiceModel(
                    id: 39, parent: category, name: "Eye Lash Lift", subTypes: [])
            ]
            
        case "Men's":
            return [
                ServiceModel(
                    id: 40, parent: category, name: "Men's Haircut", subTypes: []),
                ServiceModel(
                    id: 41, parent: category, name: "Boy's Haircut", subTypes: []),
                ServiceModel(
                    id: 42,  parent: category, name: "Facial", subTypes: [])
            ]
            
        default:
            return []
        }
    }
}

typealias ServiceObject = (id: Int, name: String, price: Int)

struct ServiceDatasource {
    var name: String
    var services: [ServiceObject]

    static func servicesOfferedByExpert() -> [ServiceDatasource] {
        return [
            CategoryModel(name: "Hair", image: UIImage(named: "hairImg") ?? UIImage()),
            CategoryModel(name: "Make-Up", image: UIImage(named: "makeUpImg") ?? UIImage()),
            CategoryModel(name: "Nails", image: UIImage(named: "nailsImg") ?? UIImage()),
            CategoryModel(name: "Eyes & Brows", image: UIImage(named: "eyesBrowsImg") ?? UIImage()),
            CategoryModel(name: "Men's", image: UIImage(named: "menImg") ?? UIImage())
            ]
            .compactMap ({ category -> ServiceDatasource in
                return ServiceDatasource(
                    name    : category.name,
                    services: ServiceModel.addServicesToCategory(category)

                        .compactMap ({ value -> [ServiceObject] in
                            guard value.id != 0 else {
                                return value.subTypes

                                    .compactMap ({ type -> ServiceObject in
                                        return ServiceObject(
                                            id  : type.id,
                                            name: ServiceSubType.serviceNameFor(id: type.id),
                                            price: 0
                                        )
                                    })
                            }
                            return [ServiceObject(id: value.id, name: value.name, price: 0)]
                        })
                        .reduce([], +)
                )
            })
    }
}

// Only For reference
//
//enum ServiceId: Int {
//    case womansHairCut = 1
//    case girlsHairCut = 2
//    case color = 3
//    case messyUpdue = 4
//    case braidedUpdue = 5
//    case chignonUpdue  = 6
//    case oldFashionedWaves = 7
//    case straightWithBody = 8
//    case looseCurls = 9
//    case beachCurls = 10
//    case volumeCurls = 11
//    case classicSmooth = 12
//    case waterfall_Braiding = 13
//    case french_Braiding = 14
//    case strand_Braiding = 15
//    case mermaid_Braiding = 16
//    case bonded_Extensions = 17
//    case weft_Extensions = 18
//    case weave_Extensions = 19
//    case bridal = 20
//    case costume = 21
//    case airbursh = 22
//    case evening = 23
//    case glamorous = 24
//    case regular = 25
//    case acrylic = 26
//    case gel = 27
//    case acrylicFill = 28
//    case design = 29
//    case acrylicGelRemoval = 30
//    case eyebrows = 31
//    case upperLip = 32
//    case fullFace = 33
//    case eyebrowsWax = 34
//    case upperLipWax = 35
//    case microBlading = 36
//    case eyeBrowTinting = 37
//    case eyeLashExtensions = 38
//    case eyeLashLift = 39
//    case mensHairCut = 40
//    case boysHairCut = 41
//    case mensFacial = 42
//}
