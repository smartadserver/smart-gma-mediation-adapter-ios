//
//  SASGMACustomEventNative.swift
//  NewSample
//
//  Created by Guillaume Laubier on 13/09/2021.
//

import Foundation
import SASDisplayKit
import GoogleMobileAds

class SASMediatedNativeAd : NSObject, GADMediatedUnifiedNativeAd, SASNativeAdDelegate {
    private let sasNativeAd: SASNativeAd
    private let sasNativeAdMediaView: SASNativeAdMediaView?
    private let sasAdChoicesView: SASAdChoicesView
    
    private var mappedImages: [GADNativeAdImage]?
    
    init(withNativeAd nativeAd: SASNativeAd) {
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
        GADMediatedUnifiedNativeAdNotificationSource.mediatedNativeAdDidRecordClick(self)
    }
    
    func didRender(in view: UIView, clickableAssetViews: [GADNativeAssetIdentifier : UIView], nonclickableAssetViews: [GADNativeAssetIdentifier : UIView], viewController: UIViewController) {
        // Registering the rendering view on the native ad to handle clicks and impression automatically
        sasNativeAd.register(view, modalParentViewController: viewController)
        
        // Registering SASAdChoicesView
        sasAdChoicesView.register(sasNativeAd, modalParentViewController: viewController)
        
        // Registering media view if necessary
        if sasNativeAd.hasMedia {
            sasNativeAdMediaView?.registerNativeAd(sasNativeAd)
        }
        
        // Logging impression to GMA
        GADMediatedUnifiedNativeAdNotificationSource.mediatedNativeAdDidRecordImpression(self)
    }
    
    func didUntrackView(_ view: UIView?) {
        // Unregistering views
        sasNativeAd.unregisterViews()
    }
}

@objc(SASGMACustomEventNative)
class SASGMACustomEventNative : NSObject, GADCustomEventNativeAd, SASNativeAdDelegate {
    var delegate: GADCustomEventNativeAdDelegate?
    
    private var nativeAdManager: SASNativeAdManager?
    private var nativeAd: SASNativeAd?
    private var mediatedNativeAd: SASMediatedNativeAd?
    
    required override init() {
    }
    
    func request(withParameter serverParameter: String, request: GADCustomEventRequest, adTypes: [Any], options: [Any], rootViewController: UIViewController) {
        // Checking the native ad type and triggering error if not supported
        guard adTypes.contains(where: { element in
            if let type = element as? GADAdLoaderAdType {
                return type == GADAdLoaderAdType.native
            }
            return false
        }) else {
            let description = "You must request the native ad format!"
            var userInfo = [String: String]()
            userInfo[NSLocalizedDescriptionKey] = description
            userInfo[NSLocalizedFailureReasonErrorKey] = description
            let error = NSError(domain: "com.google.mediation.sample", code: 0, userInfo: userInfo)
            delegate?.customEventNativeAd(self, didFailToLoadWithError: error)
            return
        }
        
        // Placement parsing from the server string
        guard let placement = SASGMAUtils.placementWith(serverParameter: serverParameter, request: request, extras: nil) else {
            // Placement is invalid, sending an error
            let error = NSError(domain: SASGMAUtils.kSASGMAErrorDomain, code: SASGMAUtils.kSASGMAErrorCodeInvalidServerParameters, userInfo: nil)
            delegate?.customEventNativeAd(self, didFailToLoadWithError: error)
            return
        }
        
        // Native ad manager instantiation
        nativeAdManager = SASNativeAdManager(placement: placement)
        
        // Requesting native ad from Smart
        nativeAdManager?.requestAd({ nativeAd, error in
            if let nativeAd = nativeAd {
                // Process ad
                self.mediatedNativeAd = SASMediatedNativeAd(withNativeAd: nativeAd)
                self.mediatedNativeAd?.fetchAssetsIfNeeded(withCompletionHandler: { error in
                    if let error = error {
                        self.delegate?.customEventNativeAd(self, didFailToLoadWithError: error)
                    } else {
                        self.delegate?.customEventNativeAd(self, didReceive: self.mediatedNativeAd!)
                    }
                })
            } else if let error = error {
                // Reporting ad loading failure to GAM
                self.delegate?.customEventNativeAd(self, didFailToLoadWithError: error)
            } else {
                let error = NSError(domain: SASGMAUtils.kSASGMAErrorDomain, code: SASGMAUtils.kSASGMAErrorCodeFailToLoadNativeAd, userInfo: nil)
                self.delegate?.customEventNativeAd(self, didFailToLoadWithError: error)
            }
        })
        
    }
    
    func handlesUserClicks() -> Bool {
        return true
    }
    
    func handlesUserImpressions() -> Bool {
        return true
    }
}
