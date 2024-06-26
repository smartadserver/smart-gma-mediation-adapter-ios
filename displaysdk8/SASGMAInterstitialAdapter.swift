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
    
    // Pragma - Adapter lifecycle
    
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
    
    // Pragma - SASInterstitialManager implementation
    
    func interstitialManager(_ interstitialManager: SASInterstitialManager, didLoadWith adInfo: SASAdInfo) {
        delegate = loadCompletionHandler?(self, nil)
    }
    
    func interstitialManager(_ interstitialManager: SASInterstitialManager, didFailToLoad error: Error) {
        _ = loadCompletionHandler?(nil, error)
    }
    
    func interstitialManager(_ manager: SASInterstitialManager, didAppearFrom viewController: UIViewController) {
        delegate?.willPresentFullScreenView()
        delegate?.reportImpression()
    }
    
    func interstitialManager(_ manager: SASInterstitialManager, didDisappearFrom viewController: UIViewController) {
        delegate?.willDismissFullScreenView()
    }
    
    func interstitialManager(_ manager: SASInterstitialManager, didClickWith URL: URL) {
        delegate?.reportClick()
    }
}
