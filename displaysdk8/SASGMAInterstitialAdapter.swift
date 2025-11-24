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
class SASGMAInterstitialAdapter : NSObject, GADMediationAdapter, GADMediationInterstitialAd, SASInterstitialManagerDelegate {
    
    private var interstitialManager: SASInterstitialManager?
    
    private var loadCompletionHandler: GADMediationInterstitialLoadCompletionHandler?
    private var delegate: GADMediationInterstitialAdEventDelegate?
    
    required override init() {
    }
    
    static func adapterVersion() -> GADVersionNumber {
        return SASGMAUtils.adapterVersion()
    }
    
    static func adSDKVersion() -> GADVersionNumber {
        return SASGMAUtils.adSDKVersion()
    }
    
    static func networkExtrasClass() -> GADAdNetworkExtras.Type? {
        return SASGMAAdNetworkExtras.self
    }
    
    // MARK: - Adapter lifecycle
    
    func loadInterstitial(for adConfiguration: GADMediationInterstitialAdConfiguration, completionHandler: @escaping GADMediationInterstitialLoadCompletionHandler) {
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
