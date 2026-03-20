//
//  SASGMAInterstitialAdapter.swift
//  Adapter for Google Mobile Ad Mediation
//
//  Created by Guillaume Laubier on 22/01/2024.
//

import Foundation
import SASDisplayKit
import GoogleMobileAds

@objc(SASGMAInterstitialAdapter)
class SASGMAInterstitialAdapter : NSObject, MediationAdapter, MediationInterstitialAd, SASInterstitialManagerDelegate {
    
    private var interstitialManager: SASInterstitialManager?
    
    private var loadCompletionHandler: GADMediationInterstitialLoadCompletionHandler?
    private var delegate: MediationInterstitialAdEventDelegate?
    
    required override init() {
    }
    
    static func adapterVersion() -> VersionNumber {
        return SASGMAUtils.adapterVersion()
    }
    
    static func adSDKVersion() -> VersionNumber {
        return SASGMAUtils.adSDKVersion()
    }
    
    static func networkExtrasClass() -> AdNetworkExtras.Type? {
        return SASGMAAdNetworkExtras.self
    }
    
    // MARK: - Adapter lifecycle
    
    func loadInterstitial(for adConfiguration: MediationInterstitialAdConfiguration, completionHandler: @escaping GADMediationInterstitialLoadCompletionHandler) {
        guard let placement = SASGMAUtils.placementWith(adConfiguration: adConfiguration) else {
            // Placement is invalid, sending an error
            let error = NSError(domain: SASGMAUtils.kSASGMAErrorDomain, code: SASGMAUtils.kSASGMAErrorCodeInvalidServerParameters, userInfo: nil)
            _ = completionHandler(nil, error)
            return
        }
        
        loadCompletionHandler = completionHandler
        
        // Instantiating the interstitial manager
        interstitialManager = SASInterstitialManager(adPlacement: placement)
        interstitialManager?.delegate = self
        
        // Load the interstitial ad
        interstitialManager?.loadAd()
    }
       
    func present(from viewController: UIViewController) {
        if (interstitialManager?.adStatus == SASAdStatus.ready) {
            // Show rewarded video only if ready
            interstitialManager?.show(from: viewController)
        }
    }
    
    // MARK: - SASInterstitialManager implementation
    
    func interstitialManager(_ interstitialManager: SASInterstitialManager, didLoadWith adInfo: SASAdInfo) {
        delegate = loadCompletionHandler?(self, nil)
    }
    
    func interstitialManager(_ interstitialManager: SASInterstitialManager, didFailToLoad error: any Error) {
        _ = loadCompletionHandler?(nil, error)
    }
    
    func interstitialManagerDidShow(_ interstitialManager: SASInterstitialManager) {
        delegate?.willPresentFullScreenView()
        delegate?.reportImpression()
    }
    
    func interstitialManagerDidClose(_ interstitialManager: SASInterstitialManager) {
        delegate?.willDismissFullScreenView()
    }
    
    func interstitialManagerClicked(_ interstitialManager: SASInterstitialManager) {
        delegate?.reportClick()
    }
}
