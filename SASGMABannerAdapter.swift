//
//  SASGMABannerAdapter.swift
//  Adapter for Google Mobile Ad Mediation
//
//  Created by Julien Gomez on 01/03/2022.
//

import Foundation
import SASDisplayKit
import GoogleMobileAds

@objc(SASGMABannerAdapter)
class SASGMABannerAdapter : NSObject, GADMediationAdapter, GADMediationBannerAd, SASBannerViewDelegate {
        
    var view: UIView
    private var loadCompletionHandler: GADMediationBannerLoadCompletionHandler?
    private var delegate: GADMediationBannerAdEventDelegate?
    
    required override init() {
        view = SASBannerView(frame: CGRect.zero) as UIView
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
    
    func loadBanner(for adConfiguration: GADMediationBannerAdConfiguration, completionHandler: @escaping GADMediationBannerLoadCompletionHandler) {
        guard let placement = SASGMAUtils.placementWith(adConfiguration: adConfiguration) else {
            // Placement is invalid, sending an error
            let error = NSError(domain: SASGMAUtils.kSASGMAErrorDomain, code: SASGMAUtils.kSASGMAErrorCodeInvalidServerParameters, userInfo: nil)
            _ = completionHandler(nil, error)
            return
        }
        
        loadCompletionHandler = completionHandler
        
        if let bannerView = view as? SASBannerView {
            bannerView.frame = CGRect(x: 0, y: 0, width: adConfiguration.adSize.size.width, height: adConfiguration.adSize.size.height)
            bannerView.modalParentViewController = adConfiguration.topViewController
            bannerView.delegate = self
            
            // Load the banner ad
            bannerView.load(with: placement)
        }
    }
    
    // Pragma - SASBannerViewDelegate implementation
    
    func bannerViewDidLoad(_ bannerView: SASBannerView) {
        delegate = loadCompletionHandler?(self, nil)
        self.delegate?.reportImpression()
    }
    
    func bannerView(_ bannerView: SASBannerView, didFailToLoadWithError error: Error) {
        _ = loadCompletionHandler?(nil, error)
    }
    
    func bannerView(_ bannerView: SASBannerView, didClickWith URL: URL) {
        delegate?.reportClick()
    }
    
    func bannerViewWillPresentModalView(_ bannerView: SASBannerView) {
        delegate?.willPresentFullScreenView()
    }
    
    func bannerViewWillDismissModalView(_ bannerView: SASBannerView) {
        delegate?.willDismissFullScreenView()
    }
    
    

    
    
}
