//
//  SASGMAUtils.swift
//  Adapter for Google Mobile Ad Mediation
//
//  Created by Guillaume Laubier on 22/01/2024.
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
    
    static let SASImplementationInfo_PrimarySDKName             = "GoogleMobileAds"
    static let SASImplementationInfo_MediationAdapterVersion_Major    = 2
    static let SASImplementationInfo_MediationAdapterVersion_Minor    = 0
    static let SASImplementationInfo_MediationAdapterVersion_Patch    = 0
    static let adaptersVersionString = "\(SASImplementationInfo_MediationAdapterVersion_Major).\(SASImplementationInfo_MediationAdapterVersion_Minor).\(SASImplementationInfo_MediationAdapterVersion_Patch)"
    
    static private let customEventServerSeparatorString = "/"
    
    static let kSASGMAErrorDomain = "kSASGMAErrorDomain"
    static let kSASGMAErrorCodeInvalidServerParameters = 100
    static let kSASGMAErrorCodeCannotFetchNativeAdAssets = 101
    static let kSASGMAErrorCodeFailToLoadNativeAd = 102
    
    static func adapterVersion() -> GADVersionNumber {
        return GADVersionNumber.init(majorVersion: SASImplementationInfo_MediationAdapterVersion_Major,
                                     minorVersion: SASImplementationInfo_MediationAdapterVersion_Minor,
                                     patchVersion: SASImplementationInfo_MediationAdapterVersion_Patch)
    }
    
    static func adSDKVersion() -> GADVersionNumber {
        let versions = SASFrameworkInfo.shared.frameworkVersionString.components(separatedBy: ".")
        let majorVersion = versions.indices.contains(0) ? Int(versions[0]) ?? 0 : 0
        let minorVersion = versions.indices.contains(1) ? Int(versions[1]) ?? 0 : 0
        let patchVersion = versions.indices.contains(2) ? Int(versions[2]) ?? 0 : 0
        
        return GADVersionNumber.init(majorVersion: majorVersion, minorVersion: minorVersion, patchVersion: patchVersion)
    }
    
    static func placementWith(adConfiguration: GADMediationAdConfiguration) -> SASAdPlacement? {
        guard let parameter = adConfiguration.credentials.settings["parameter"] as? String else {
            return nil
        }
        
        var siteId = 0
        var pageId = 0
        var formatId = 0
        
        // Processing the server parameter string
        let stringComponents = parameter.components(separatedBy: customEventServerSeparatorString)
        stringComponents.forEach { string in
            switch (stringComponents.firstIndex(of: string)) {
            case 0:
                siteId = Int(string) ?? 0
                break
            case 1:
                pageId = Int(string) ?? 0
                break
            case 2:
                formatId = Int(string) ?? 0
                break
            default:
                break
            }
        }
        
        // Rejecting invalid parameters
        if (siteId == 0 || pageId == 0 || formatId == 0) {
            return nil
        }
        
        var targetingString: String? = nil
        
        if let extras = adConfiguration.extras as? SASGMAAdNetworkExtras {
            // Processing keywords targeting string
            targetingString = extras.keywords.joined(separator: ";")
        }
        
        // Configure the Equativ Display SDK
        SASConfiguration.shared.configure()

        SASConfiguration.shared.secondaryImplementationInfo = SASSecondaryImplementationInfo(primarySDKName: SASImplementationInfo_PrimarySDKName,
                                                                                             primarySDKVersion: GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber),
                                                                                             mediationAdapterVersion: adaptersVersionString)
        
        // Ad placement instantiation
        return SASAdPlacement(siteId: siteId, pageId: pageId, formatId: formatId, keywordTargeting: targetingString)
    }
    
    @available(*, deprecated, message: "use placementWith(adConfiguration: GADMediationAdConfiguration) instead")
    static func placementWith(serverParameter: String?, request: GADCustomEventRequest?, extras: SASGMAAdNetworkExtras?) -> SASAdPlacement? {
        guard let param = serverParameter else {
            return nil
        }
        
        var siteId = 0
        var pageId = 0
        var formatId = 0
        
        // Processing the server parameter string
        let stringComponents = param.components(separatedBy: customEventServerSeparatorString)
        stringComponents.forEach { string in
            switch (stringComponents.firstIndex(of: string)) {
            case 0:
                siteId = Int(string) ?? 0
                break
            case 1:
                pageId = Int(string) ?? 0
                break
            case 2:
                formatId = Int(string) ?? 0
                break
            default:
                break
            }
        }
        
        // Rejecting invalid parameters
        if (siteId == 0 || pageId == 0 || formatId == 0) {
            return nil
        }
        
        var targetingString: String? = nil
        
        if let request = request {
            if let keywords = request.userKeywords as? [String] {
                targetingString = keywords.joined(separator: ";")
            }
        }
        
        if let extras = extras {
            // Processing keywords targeting string
            targetingString = extras.keywords.joined(separator: ";")
        }
        
        // Configure the Equativ Display SDK
        SASConfiguration.shared.configure()
        SASConfiguration.shared.secondaryImplementationInfo = SASSecondaryImplementationInfo(primarySDKName: SASImplementationInfo_PrimarySDKName, 
                                                                                             primarySDKVersion: GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber),
                                                                                             mediationAdapterVersion: adaptersVersionString)
    
        // Ad placement instantiation
        return SASAdPlacement(siteId: siteId, pageId: pageId, formatId: formatId, keywordTargeting: targetingString)
    }
    
}
