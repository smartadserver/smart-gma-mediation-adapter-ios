//
//  SASGMACustomEventInterstitial.swift
//  NewSample
//
//  Created by Guillaume Laubier on 09/09/2021.
//

import Foundation
import GoogleMobileAds
import SASDisplayKit

@objc(SASGMACustomEventInterstitial)
class SASGMACustomEventInterstitial : NSObject, GADCustomEventInterstitial, SASInterstitialManagerDelegate {
    
    private var interstitialManager: SASInterstitialManager?
    
    var delegate: GADCustomEventInterstitialDelegate?
    
    required override init() {
    }
    
    func requestAd(withParameter serverParameter: String?, label serverLabel: String?, request: GADCustomEventRequest) {
        guard let placement = SASGMAUtils.placementWith(serverParameter: serverParameter, request: request, extras: nil) else {
            // Placement is invalid, sending an error
            let error = NSError(domain: SASGMAUtils.kSASGMAErrorDomain, code: SASGMAUtils.kSASGMAErrorCodeInvalidServerParameters, userInfo: nil)
            self.delegate?.customEventInterstitial(self, didFailAd: error)
            return
        }
        
        // Instantiating an SASInterstitialManager
        interstitialManager = SASInterstitialManager(placement: placement, delegate: self)
        
        // Load the interstitial
        interstitialManager?.load()
    }
    
    func present(fromRootViewController rootViewController: UIViewController) {
        if (interstitialManager?.adStatus == SASAdStatus.ready) {
            // Showing the interstitial if ready
            interstitialManager?.show(from: rootViewController)
        }
    }
    
    // Pragma - SASInterstitialManagerDelegate implementation
    func interstitialManager(_ manager: SASInterstitialManager, didLoad ad: SASAd) {
        delegate?.customEventInterstitialDidReceiveAd(self)
    }
    
    func interstitialManager(_ manager: SASInterstitialManager, didFailToLoadWithError error: Error) {
        delegate?.customEventInterstitial(self, didFailAd: error)
    }
    
    func interstitialManager(_ manager: SASInterstitialManager, didAppearFrom viewController: UIViewController) {
        delegate?.customEventInterstitialWillPresent(self)
    }
    
    func interstitialManager(_ manager: SASInterstitialManager, didDisappearFrom viewController: UIViewController) {
        delegate?.customEventInterstitialDidDismiss(self)
    }
    
    func interstitialManager(_ manager: SASInterstitialManager, didClickWith URL: URL) {
        delegate?.customEventInterstitialWasClicked(self)
    }
}
