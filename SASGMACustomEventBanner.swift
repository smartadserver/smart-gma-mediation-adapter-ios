//
//  SASGMACustomEventBanner.swift
//  NewSample
//
//  Created by Guillaume Laubier on 13/09/2021.
//

import Foundation
import SASDisplayKit
import GoogleMobileAds

@objc(SASGMACustomEventBanner)
class SASGMACustomEventBanner : NSObject, GADCustomEventBanner, SASBannerViewDelegate {
    var delegate: GADCustomEventBannerDelegate?
    
    private var bannerView: SASBannerView?
    
    required override init() {
    }
    
    func requestAd(_ adSize: GADAdSize, parameter serverParameter: String?, label serverLabel: String?, request: GADCustomEventRequest) {
        guard let placement = SASGMAUtils.placementWith(serverParameter: serverParameter, request: request, extras: nil) else {
            // Placement is invalid, sending an error
            let error = NSError(domain: SASGMAUtils.kSASGMAErrorDomain, code: SASGMAUtils.kSASGMAErrorCodeInvalidServerParameters, userInfo: nil)
            self.delegate?.customEventBanner(self, didFailAd: error)
            return
        }
        
        // Create the bannerView with the appropriate size
        bannerView = SASBannerView(frame: CGRect(x: 0, y: 0, width: adSize.size.width, height: adSize.size.height))
        bannerView?.modalParentViewController = delegate?.viewControllerForPresentingModalView
        bannerView?.delegate = self
        
        // Load the previously retrieved ad placement
        bannerView?.load(with: placement)
    }
    
    // Pragma - SASBannerViewDelegate implementation
    
    func bannerViewDidLoad(_ bannerView: SASBannerView) {
        delegate?.customEventBanner(self, didReceiveAd: bannerView)
    }
    
    func bannerView(_ bannerView: SASBannerView, didFailToLoadWithError error: Error) {
        delegate?.customEventBanner(self, didFailAd: error)
    }
    
    func bannerView(_ bannerView: SASBannerView, didClickWith URL: URL) {
        delegate?.customEventBannerWasClicked(self)
    }
    
    func bannerViewWillPresentModalView(_ bannerView: SASBannerView) {
        delegate?.customEventBannerWillPresentModal(self)
    }
    
    func bannerViewWillDismissModalView(_ bannerView: SASBannerView) {
        delegate?.customEventBannerWillDismissModal(self)
    }
    
}
