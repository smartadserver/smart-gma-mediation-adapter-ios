//
//  SASGMARewardedAdapter.swift
//  NewSample
//
//  Created by Guillaume Laubier on 09/09/2021.
//

import Foundation
import SASDisplayKit
import GoogleMobileAds

@objc(SASGMARewardedAdapter)
class SASGMARewardedAdapter : NSObject, GADMediationAdapter, GADMediationRewardedAd, SASRewardedVideoManagerDelegate {
    
    private var rewardedVideoManager: SASRewardedVideoManager?
    
    private var loadCompletionHandler: GADMediationRewardedLoadCompletionHandler?
    private var delegate: GADMediationRewardedAdEventDelegate?
    
    required override init() {
    }
    
    static func adapterVersion() -> GADVersionNumber {
        var version = GADVersionNumber()
        version.majorVersion = SASGMAUtils.adapterVersion
        return version
    }
    
    static func adSDKVersion() -> GADVersionNumber {
        var version = GADVersionNumber()
        version.majorVersion = 7
        return version
    }
    
    static func networkExtrasClass() -> GADAdNetworkExtras.Type? {
        return SASGMAAdNetworkExtras.self
    }
    
    // Pragma - Adapter lifecycle
    
    func loadRewardedAd(for adConfiguration: GADMediationRewardedAdConfiguration, completionHandler: @escaping GADMediationRewardedLoadCompletionHandler) {
        guard let placement = SASGMAUtils.placementWith(serverParameter: adConfiguration.credentials.settings["parameter"] as? String, request: nil, extras: adConfiguration.extras as? SASGMAAdNetworkExtras) else {
            // Placement is invalid, sending an error
            let error = NSError(domain: SASGMAUtils.kSASGMAErrorDomain, code: SASGMAUtils.kSASGMAErrorCodeInvalidServerParameters, userInfo: nil)
            _ = completionHandler(nil, error)
            return
        }
        
        loadCompletionHandler = completionHandler
        
        // Instantiating the rewarded video manager
        rewardedVideoManager = SASRewardedVideoManager(placement: placement, delegate: self)
        
        // Load the rewarded video ad
        rewardedVideoManager?.load()
    }
    
    func loadRewardedInterstitialAd(for adConfiguration: GADMediationRewardedAdConfiguration, completionHandler: @escaping GADMediationRewardedLoadCompletionHandler) {
        loadRewardedAd(for: adConfiguration, completionHandler: completionHandler)
    }
    
    func present(from viewController: UIViewController) {
        if (rewardedVideoManager?.adStatus == SASAdStatus.ready) {
            // Show rewarded video only if ready
            rewardedVideoManager?.show(from: viewController)
        }
    }
    
    // Pragma - SASRewardedVideoManagerDelegate implementation
    
    func rewardedVideoManager(_ manager: SASRewardedVideoManager, didLoad ad: SASAd) {
        delegate = loadCompletionHandler?(self, nil)
    }
    
    func rewardedVideoManager(_ manager: SASRewardedVideoManager, didFailToLoadWithError error: Error) {
        _ = loadCompletionHandler?(nil, error)
    }
    
    func rewardedVideoManager(_ manager: SASRewardedVideoManager, didAppearFrom viewController: UIViewController) {
        delegate?.willPresentFullScreenView()
        delegate?.reportImpression()
    }
    
    func rewardedVideoManager(_ manager: SASRewardedVideoManager, didDisappearFrom viewController: UIViewController) {
        delegate?.willDismissFullScreenView()
    }
    
    func rewardedVideoManager(_ manager: SASRewardedVideoManager, didCollect reward: SASReward) {
        let gadReward = GADAdReward(rewardType: reward.currency, rewardAmount: NSDecimalNumber(nonretainedObject: reward.amount))
        delegate?.didRewardUser(with: gadReward)
    }
    
    func rewardedVideoManager(_ manager: SASRewardedVideoManager, didClickWith URL: URL) {
        delegate?.reportClick()
    }
}
