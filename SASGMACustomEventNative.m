//
//  SASGMACustomEventNative.m
//  Sample
//
//  Created by Loïc GIRON DIT METAZ on 09/07/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import "SASGMACustomEventNative.h"
#import <SASDisplayKit/SASDisplayKit.h>
#import "SASGMAUtils.h"
#import "SASGMACustomEventConstants.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Unified native ad view

@interface SASMediatedNativeAd : NSObject <GADMediatedUnifiedNativeAd, SASNativeAdDelegate>

@property(nonatomic, strong) SASNativeAd *sasNativeAd;
@property(nonatomic, strong) SASAdChoicesView *sasAdChoicesView;
@property(nonatomic, strong, nullable) SASNativeAdMediaView *sasMediaView;

@property(nonatomic, copy) NSArray *mappedImages;
@property(nonatomic, strong) GADNativeAdImage *icon;

- (nullable instancetype)initWithNativeAd:(nonnull SASNativeAd *)nativeAd;

@end

@implementation SASMediatedNativeAd

- (nullable instancetype)initWithNativeAd:(nonnull SASNativeAd *)nativeAd {
    if (self = [super init]) {
        self.sasNativeAd = nativeAd;
                
        self.sasAdChoicesView = [[SASAdChoicesView alloc] init];
        
        if ([self.sasNativeAd hasMedia]) {
            self.sasMediaView = [[SASNativeAdMediaView alloc] init];
        }
    }
    
    return self;
}

- (void)fetchAssetsIfNeededWithCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler {
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    __block BOOL errorOccured = NO;
    
    dispatch_group_t downloadAssetsGroup = dispatch_group_create();
                
    if (self.sasNativeAd.icon != nil) {
        NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithURL:self.sasNativeAd.icon.URL
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                errorOccured = YES;
            } else {
                UIImage *iconImage = [[UIImage alloc] initWithData:data];
                if (iconImage != nil) {
                    self.icon = [[GADNativeAdImage alloc] initWithImage:iconImage];
                } else {
                    errorOccured = YES;
                }
            }
            
            dispatch_group_leave(downloadAssetsGroup);
        }];
        
        dispatch_group_enter(downloadAssetsGroup);
        [dataTask resume];
    }
    
    if (self.sasNativeAd.coverImage != nil) {
        NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithURL:self.sasNativeAd.coverImage.URL
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                errorOccured = YES;
            } else {
                UIImage *coverImage = [[UIImage alloc] initWithData:data];
                if (coverImage != nil) {
                    self.mappedImages = @[ [[GADNativeAdImage alloc] initWithImage:coverImage] ];
                } else {
                    errorOccured = YES;
                }
            }
            
            dispatch_group_leave(downloadAssetsGroup);
        }];
        
        dispatch_group_enter(downloadAssetsGroup);
        [dataTask resume];
    }
    
    dispatch_group_notify(downloadAssetsGroup, dispatch_get_main_queue(),^{
        if (errorOccured) {
            NSError *error = [NSError errorWithDomain:kSASGMAErrorDomain code:kSASGMAErrorCodeCannotFetchNativeAdAssets userInfo:nil];
            completionHandler(error);
        } else {
            completionHandler(nil);
        }
    });
}

- (nullable NSString *)advertiser {
    return nil;
}

- (nullable NSString *)body {
    return self.sasNativeAd.body;
}

- (nullable NSString *)callToAction {
    return self.sasNativeAd.callToAction;
}

- (nullable NSDictionary<NSString *,id> *)extraAssets {
    return nil;
}

- (nullable NSString *)headline {
    return self.sasNativeAd.title;
}

- (nullable NSArray<GADNativeAdImage *> *)images {
    return self.mappedImages;
}

- (nullable NSString *)price {
    return nil;
}

- (nullable NSDecimalNumber *)starRating {
    return [[NSDecimalNumber alloc] initWithFloat:self.sasNativeAd.rating];
}

- (nullable NSString *)store {
    return nil;
}

- (nullable UIView *)adChoicesView {
    return self.sasAdChoicesView;
}

- (BOOL)nativeAd:(SASNativeAd *)nativeAd shouldHandleClickURL:(NSURL *)URL {
    // Logging click to GMA
    [GADMediatedUnifiedNativeAdNotificationSource mediatedNativeAdDidRecordClick:self];
    
    return YES;
}

- (BOOL)hasVideoContent {
    return [self.sasNativeAd hasMedia];
}

- (nullable UIView *)mediaView {
    return self.sasMediaView;
}

- (void)didRenderInView:(UIView *)view
    clickableAssetViews:(NSDictionary<GADUnifiedNativeAssetIdentifier, UIView *> *)clickableAssetViews
 nonclickableAssetViews:(NSDictionary<GADUnifiedNativeAssetIdentifier, UIView *> *)nonclickableAssetViews
         viewController:(UIViewController *)viewController {
    
    // Registering the rendering view on the native ad to handle clicks and impression automatically
    [self.sasNativeAd registerView:view modalParentViewController:viewController];
    
    // Registering sas ad choices view
    [self.sasAdChoicesView registerNativeAd:self.sasNativeAd modalParentViewController:viewController];

    
    // Registering media view if necessary
    if ([self.sasNativeAd hasMedia]) {
        [self.sasMediaView registerNativeAd:self.sasNativeAd];
    }
    
    // Logging impression to GMA
    [GADMediatedUnifiedNativeAdNotificationSource mediatedNativeAdDidRecordImpression:self];
}

- (void)didUntrackView:(nullable UIView *)view {
    // Unregistering views
    [self.sasNativeAd unregisterViews];
}

@end

#pragma mark - Custom event

@interface SASGMACustomEventNative () <SASNativeAdDelegate>

@property (nonatomic, strong, nullable) SASNativeAdManager *nativeAdManager;
@property (nonatomic, strong, nullable) SASNativeAd *nativeAd;
@property (nonatomic, strong, nullable) SASMediatedNativeAd *mediatedNativeAd;

@end

@implementation SASGMACustomEventNative

@synthesize delegate;

- (void)requestNativeAdWithParameter:(NSString *)serverParameter
                             request:(GADCustomEventRequest *)request
                             adTypes:(NSArray *)adTypes
                             options:(NSArray *)options
                  rootViewController:(UIViewController *)rootViewController {
    
    // Checking the native ad type and triggering error if not supported
    if (![adTypes containsObject:kGADAdLoaderAdTypeUnifiedNative]) {
        NSString *description = @"You must request the unified native ad format!";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : description, NSLocalizedFailureReasonErrorKey : description};
        NSError *error = [NSError errorWithDomain:@"com.google.mediation.sample" code:0 userInfo:userInfo];
        [self.delegate customEventNativeAd:self didFailToLoadWithError:error];

        return;
    }
                      
    // Placement parsing from the server string
    SASAdPlacement *adPlacement = [SASGMAUtils placementWithDFPServerParameter:serverParameter request:request];

    if (adPlacement != nil) {

        // Native ad manager instantiation
        self.nativeAdManager = [[SASNativeAdManager alloc] initWithPlacement:adPlacement];
        
        // Requesting native ad from Smart
        [self.nativeAdManager requestAd:^(SASNativeAd *ad, NSError *error) {
            
            if (ad != nil) {
                // Processing ad
                [self processAd:ad request:request];
            } else {
                // Reporting ad loading failure to the primary SDK
                [self.delegate customEventNativeAd:self didFailToLoadWithError:error];
            }
            
        }];

    } else {

        // Placement is invalid, sending an error
        NSError *error = [NSError errorWithDomain:kSASGMAErrorDomain code:kSASGMAErrorCodeInvalidServerParameters userInfo:nil];
        [self.delegate customEventNativeAd:self didFailToLoadWithError:error];

    }
    
}

- (BOOL)handlesUserClicks {
    return YES;
}

- (BOOL)handlesUserImpressions {
    return YES;
}

- (void)processAd:(SASNativeAd *)nativeAd request:(GADCustomEventRequest *)request {
    // Converting Smart native ad into a GMA unified native ad
    self.mediatedNativeAd = [[SASMediatedNativeAd alloc] initWithNativeAd:nativeAd];
    [self.mediatedNativeAd fetchAssetsIfNeededWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            [self.delegate customEventNativeAd:self didFailToLoadWithError:error];
        } else {
            [self.delegate customEventNativeAd:self didReceiveMediatedUnifiedNativeAd:self.mediatedNativeAd];
        }
    }];
}

@end

NS_ASSUME_NONNULL_END
