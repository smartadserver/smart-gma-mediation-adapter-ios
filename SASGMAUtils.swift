//
//  SASGMAUtils.swift
//  NewSample
//
//  Created by Guillaume Laubier on 09/09/2021.
//

import Foundation
import GoogleMobileAds
import SASDisplayKit

class SASGMAAdNetworkExtras: NSObject, GADAdNetworkExtras {
    
    let keywords: [String]
    
    init(keywords: [String]) {
        self.keywords = keywords
        super.init()
    }
}

class SASGMAUtils {
    
    static let adapterVersion = 2
    
    static private let customEventServerSeparatorString = "/"
    
    static let kSASGMAErrorDomain = "kSASGMAErrorDomain"
    static let kSASGMAErrorCodeInvalidServerParameters = 100
    static let kSASGMAErrorCodeCannotFetchNativeAdAssets = 101
    static let kSASGMAErrorCodeFailToLoadNativeAd = 102
    
    static func placementWith(serverParameter: String?, request: GADCustomEventRequest?, extras: SASGMAAdNetworkExtras?) -> SASAdPlacement? {
        guard let param = serverParameter else {
            return nil
        }
        
        var siteId = 0
        var pageId: String? = nil
        var formatId = 0
        
        // Processing the server parameter string
        let stringComponents = param.components(separatedBy: customEventServerSeparatorString)
        stringComponents.forEach { string in
            switch (stringComponents.firstIndex(of: string)) {
            case 0:
                siteId = Int(string) ?? 0
                break
            case 1:
                pageId = string
                break
            case 2:
                formatId = Int(string) ?? 0
                break
            default:
                break
            }
        }
        
        // Rejecting invalid parameters
        if (siteId == 0 || pageId == nil || pageId?.count == 0 || formatId == 0) {
            return nil
        }
        
        var targetingString: String? = nil
        
        if let request = request {
            if let keywords = request.userKeywords as? [String] {
                targetingString = keywords.joined(separator: ";")
            }
            
            if (request.userHasLocation) {
                // Setting the location if available
                SASConfiguration.shared.manualLocation = CLLocationCoordinate2DMake(Double(request.userLatitude), Double(request.userLongitude))
            }
        }
        
        if let extras = extras {
            // Processing keywords targeting string
            targetingString = extras.keywords.joined(separator: ";")
        }
        
        // Configure the Smart Display SDK
        SASConfiguration.shared.configure(siteId: siteId)
        SASConfiguration.shared.primarySDK = false
    
        // Ad placement instantiation
        return SASAdPlacement(siteId: siteId, pageName: pageId!, formatId: formatId, keywordTargeting: targetingString)
    }
    
}
