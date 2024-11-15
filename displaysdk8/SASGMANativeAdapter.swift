//
//  SASGMANativeAdapter.swift
//  Adapter for Google Mobile Ad Mediation
//
//  Created by Julien GOMEZ on 17/09/2024.
//

import Foundation
import SASDisplayKit
import GoogleMobileAds

class SASMediatedNativeAd : NSObject, GADMediationNativeAd {
    var gadDelegate: GADMediationNativeAdEventDelegate?
    
    private let sasNativeAdView: SASNativeAdView
    private let sasNativeAdAssets: SASNativeAdAssets

    private var mappedImages: [GADNativeAdImage]?
    
    init(nativeAdView: SASNativeAdView, nativeAdAssets: SASNativeAdAssets, customerFeedbackButtonContainer: UIView?) {
        sasNativeAdView = nativeAdView
        sasNativeAdAssets = nativeAdAssets
    }
    
    var adChoicesView: UIView? {
        return nil
    }
    
    var advertiser: String?
    
    var body: String? {
        return sasNativeAdAssets.body
    }
    
    var callToAction: String? {
        return sasNativeAdAssets.callToAction
    }
    
    var extraAssets: [String : Any]?
    
    var hasVideoContent: Bool {
        return false
    }
    
    var headline: String? {
        return sasNativeAdAssets.title
    }
    
    var icon: GADNativeAdImage?
    
    var images: [GADNativeAdImage]? {
        return mappedImages
    }
    
    var mediaView: UIView? {
        return nil
    }
    
    var price: String?
    
    var starRating: NSDecimalNumber? {
        if let rating = sasNativeAdAssets.rating {
            return NSDecimalNumber(decimal:rating.decimalValue)
        }
        return nil
    }
    
    var store: String?
    
    func didRender(
        in view: UIView, clickableAssetViews: [GADNativeAssetIdentifier: UIView],
        nonclickableAssetViews: [GADNativeAssetIdentifier: UIView],
        viewController: UIViewController
    ) {
        // Tracking the mediation view using the Equativ SDK in order to fire
        // the impression & tracking pixels and in order to handle the click properly
        sasNativeAdView.trackMediationView(view)
        
        // Logging impression to GMA
        gadDelegate?.reportImpression()
    }
    
    fileprivate func fetchAssetsIfNeeded(completionHandler: @escaping (Error?) -> Void) {
        var errorOccured = false
        let downloadAssetsGroup = DispatchGroup()
        
        if let iconUrl = sasNativeAdAssets.iconImage?.url {
            let dataTask = URLSession.shared.dataTask(with: iconUrl) { data, _, _ in
                if let data = data,
                   let iconImage = UIImage(data: data) {
                    self.icon = GADNativeAdImage(image: iconImage)
                } else {
                    errorOccured = true
                }
                
                downloadAssetsGroup.leave()
            }
            
            downloadAssetsGroup.enter()
            dataTask.resume()
        }
        
        if let mainViewUrl = sasNativeAdAssets.mainView?.url {
            let dataTask = URLSession.shared.dataTask(with: mainViewUrl) { data, _, _ in
                if let data = data,
                   let mainViewImage = UIImage(data: data) {
                    self.mappedImages = [GADNativeAdImage(image: mainViewImage)]
                } else {
                    errorOccured = true
                }
                
                downloadAssetsGroup.leave()
            }
            
            downloadAssetsGroup.enter()
            dataTask.resume()
        }
        
        downloadAssetsGroup.notify(queue: DispatchQueue.main) {
            if (errorOccured) {
                let error = NSError(domain: SASGMAUtils.kSASGMAErrorDomain, code: SASGMAUtils.kSASGMAErrorCodeCannotFetchNativeAdAssets, userInfo: nil)
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
}

@objc(SASGMANativeAdapter)
class SASGMANativeAdapter : NSObject, GADMediationAdapter, SASNativeAdViewDelegate {
    private var nativeAdView: SASNativeAdView
    private var nativeAdAssets: SASNativeAdAssets?
    
    private var loadCompletionHandler: GADMediationNativeLoadCompletionHandler?
    private var delegate: GADMediationNativeAdEventDelegate?
    
    private var mediatedNativeAd: SASMediatedNativeAd?
    
    private var nativeAdViewBaseLayout = UIView(frame: .zero)
    private var nativeAdViewCustomerFeedbackButtonContainer = UIView(frame: .zero)

    required override init() {
        nativeAdView = SASNativeAdView(frame: .zero)
        super.init()
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
    
    func loadNativeAd(for adConfiguration: GADMediationNativeAdConfiguration, completionHandler: @escaping GADMediationNativeLoadCompletionHandler) {
        guard let placement = SASGMAUtils.placementWith(adConfiguration: adConfiguration) else {
            // Placement is invalid, sending an error
            let error = NSError(domain: SASGMAUtils.kSASGMAErrorDomain, code: SASGMAUtils.kSASGMAErrorCodeInvalidServerParameters, userInfo: nil)
            _ = completionHandler(nil, error)
            return
        }
        
        loadCompletionHandler = completionHandler
        
        nativeAdView.modalParentViewController = adConfiguration.topViewController
        nativeAdView.delegate = self
        
        // Load the native ad
        nativeAdView.loadAd(with: placement)
    }
    
    func handlesUserClicks() -> Bool {
        return true
    }
    
    func handlesUserImpressions() -> Bool {
        return true
    }
    
    func didRender(
        in view: UIView, clickableAssetViews: [GADNativeAssetIdentifier: UIView],
        nonclickableAssetViews: [GADNativeAssetIdentifier: UIView],
        viewController: UIViewController
    ) {
        // Logging impression to GMA
        mediatedNativeAd?.gadDelegate?.reportImpression()
    }
    
    func nativeAdView(_ nativeAdView: SASNativeAdView, didLoadWith adInfo: SASAdInfo, nativeAdAssets: SASNativeAdAssets) {
        self.nativeAdAssets =  nativeAdAssets
    
        mediatedNativeAd = SASMediatedNativeAd(nativeAdView: nativeAdView, nativeAdAssets: nativeAdAssets, customerFeedbackButtonContainer: nativeAdViewCustomerFeedbackButtonContainer)
        
        self.mediatedNativeAd?.fetchAssetsIfNeeded() { error in
            if let error = error {
                _ = self.loadCompletionHandler?(nil, error)
            } else {
                self.delegate = self.loadCompletionHandler?(self.mediatedNativeAd!, nil)
                self.mediatedNativeAd?.gadDelegate = self.delegate
            }
        }

    }
    
    func nativeAdView(_ nativeAdView: SASNativeAdView, didFailToLoad error: any Error) {
        delegate = loadCompletionHandler?(nil, error)
    }
    
    func nativeAdViewClicked(_ nativeAdView: SASNativeAdView) {
        self.delegate?.reportClick()
    }
}
