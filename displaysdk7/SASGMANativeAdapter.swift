//
//  SASGMANativeAdapter.swift
//  Adapter for Google Mobile Ad Mediation
//
//  Created by Julien Gomez on 03/03/2022.
//

import Foundation
import SASDisplayKit
import GoogleMobileAds

class SASMediatedNativeAd : NSObject, GADMediationNativeAd, SASNativeAdDelegate, SASNativeAdMediaViewDelegate {
    private let sasNativeAd: SASNativeAd
    private let sasNativeAdMediaView: SASNativeAdMediaView?
    private let sasAdChoicesView: SASAdChoicesView
    
    var gadDelegate: GADMediationNativeAdEventDelegate?
    
    private var mappedImages: [GADNativeAdImage]?
    
    init(nativeAd: SASNativeAd) {
        sasNativeAd = nativeAd
        sasAdChoicesView = SASAdChoicesView()
        
        if sasNativeAd.hasMedia {
            sasNativeAdMediaView = SASNativeAdMediaView()
        } else {
            sasNativeAdMediaView = nil
        }
    }
    
    func fetchAssetsIfNeeded(withCompletionHandler completionHandler:@escaping (Error?) -> Void) {
        let defaultSession = URLSession.init(configuration: URLSessionConfiguration.default)
        
        var errorOccured = false
        
        let downloadAssetsGroup = DispatchGroup()
        
        if let icon = sasNativeAd.icon {
            let dataTask = defaultSession.dataTask(with: icon.url) { data, urlResponse, error in
                if let _ = error {
                    errorOccured = true
                } else if let data = data {
                    if let iconImage = UIImage(data: data) {
                        self.icon = GADNativeAdImage(image: iconImage)
                    } else {
                        errorOccured = true
                    }
                } else {
                    errorOccured = true
                }
                
                downloadAssetsGroup.leave()
            }
            
            downloadAssetsGroup.enter()
            dataTask.resume()
        }
        
        if let cover = sasNativeAd.coverImage {
            let dataTask = defaultSession.dataTask(with: cover.url) { data, urlResponse, error in
                if let _ = error {
                    errorOccured = true
                } else if let data = data {
                    if let coverImage = UIImage(data: data) {
                        self.mappedImages = [GADNativeAdImage(image: coverImage)]
                    } else {
                        errorOccured = true
                    }
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
    
    var adChoicesView: UIView? {
        get {
            return sasAdChoicesView
        }
    }
    
    var advertiser: String?
    
    var body: String? {
        get {
            return sasNativeAd.body
        }
    }
    
    var callToAction: String? {
        get {
            return sasNativeAd.callToAction
        }
    }
    
    var extraAssets: [String : Any]?
    
    var hasVideoContent: Bool {
        get {
            return sasNativeAd.hasMedia
        }
    }
    
    var headline: String? {
        get {
            return sasNativeAd.title
        }
    }
    
    var icon: GADNativeAdImage?
    
    var images: [GADNativeAdImage]? {
        get {
            return mappedImages
        }
    }
    
    var mediaView: UIView? {
        get {
            return sasNativeAdMediaView
        }
    }
    
    var price: String?
    
    var starRating: NSDecimalNumber? {
        get {
            return NSDecimalNumber(value: sasNativeAd.rating)
        }
    }
    
    var store: String?
    
    func nativeAd(_ nativeAd: SASNativeAd, didClickWith URL: URL) {
        // Logging click to GMA
        gadDelegate?.reportClick()
    }
    
    func nativeAdMediaView(_ mediaView: SASNativeAdMediaView, didSend videoEvent: SASVideoEvent) {
        switch videoEvent {
        case .start:
            gadDelegate?.didPlayVideo()
        case .pause:
            gadDelegate?.didPauseVideo()
        case .complete:
            gadDelegate?.didEndVideo()
        case .enterFullscreen:
            gadDelegate?.willPresentFullScreenView()
        case .exitFullscreen:
            gadDelegate?.didDismissFullScreenView()
        default:
            break
        }
    }
    
    func didRender(in view: UIView, clickableAssetViews: [GADNativeAssetIdentifier : UIView], nonclickableAssetViews: [GADNativeAssetIdentifier : UIView], viewController: UIViewController) {
        // Set delegate to handle click report
        sasNativeAd.delegate = self
        // Registering the rendering view on the native ad to handle clicks and impression automatically
        sasNativeAd.register(view, modalParentViewController: viewController)
        
        // Registering SASAdChoicesView
        sasAdChoicesView.register(sasNativeAd, modalParentViewController: viewController)
        
        // Registering media view if necessary
        if sasNativeAd.hasMedia {
            sasNativeAdMediaView?.registerNativeAd(sasNativeAd)
            // Set mediaview delegate to handle video events
            sasNativeAdMediaView?.delegate = self
        }
        
        // Logging impression to GMA
        gadDelegate?.reportImpression()
    }
    
    func didUntrackView(_ view: UIView?) {
        // Unregistering views
        sasNativeAd.unregisterViews()
    }
}

@objc(SASGMANativeAdapter)
class SASGMANativeAdapter : NSObject, GADMediationAdapter {
    
    private var loadCompletionHandler: GADMediationNativeLoadCompletionHandler?
    private var delegate: GADMediationNativeAdEventDelegate?
    
    private var nativeAdManager: SASNativeAdManager?
    private var nativeAd: SASNativeAd?
    private var mediatedNativeAd: SASMediatedNativeAd?
    
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
    
    func loadNativeAd(for adConfiguration: GADMediationNativeAdConfiguration, completionHandler: @escaping GADMediationNativeLoadCompletionHandler) {
        guard let placement = SASGMAUtils.placementWith(adConfiguration: adConfiguration) else {
            // Placement is invalid, sending an error
            let error = NSError(domain: SASGMAUtils.kSASGMAErrorDomain, code: SASGMAUtils.kSASGMAErrorCodeInvalidServerParameters, userInfo: nil)
            _ = completionHandler(nil, error)
            return
        }
        
        loadCompletionHandler = completionHandler
        
        // Native ad manager instantiation
        nativeAdManager = SASNativeAdManager(placement: placement)
        
        // Requesting native ad from Smart
        nativeAdManager?.requestAd({ nativeAd, error in
            if let nativeAd = nativeAd {
                // Process ad
                self.mediatedNativeAd = SASMediatedNativeAd(nativeAd: nativeAd)
                self.mediatedNativeAd?.fetchAssetsIfNeeded(withCompletionHandler: { error in
                    if let error = error {
                        _ = self.loadCompletionHandler?(nil, error)
                    } else {
                        self.delegate = self.loadCompletionHandler?(self.mediatedNativeAd!, nil)
                        self.mediatedNativeAd?.gadDelegate = self.delegate
                    }
                })
            } else if let error = error {
                // Reporting ad loading failure to GAM
                _ = self.loadCompletionHandler?(nil, error)
            } else {
                let error = NSError(domain: SASGMAUtils.kSASGMAErrorDomain, code: SASGMAUtils.kSASGMAErrorCodeFailToLoadNativeAd, userInfo: nil)
                _ = self.loadCompletionHandler?(nil, error)
            }
        })

    }
}
