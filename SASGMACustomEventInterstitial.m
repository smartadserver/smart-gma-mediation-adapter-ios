//
//  SASGMACustomEventInterstitial.m
//
//  Created by Julien Gomez on 22/06/16.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASGMACustomEventInterstitial.h"
#import <SASDisplayKit/SASDisplayKit.h>
#import "SASGMACustomEventConstants.h"
#import "SASGMAUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface SASGMACustomEventInterstitial () <SASInterstitialManagerDelegate>

@property(nonatomic, strong) SASInterstitialManager *interstitialManager;

@end

@implementation SASGMACustomEventInterstitial

@synthesize delegate;

#pragma mark GMACustomEventInterstitial implementation

- (void)requestInterstitialAdWithParameter:(nullable NSString *)serverParameter
                                     label:(nullable NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request {
        
    // Placement parsing from the server string
    SASAdPlacement *adPlacement = [SASGMAUtils placementWithDFPServerParameter:serverParameter request:request];
    
    if (adPlacement != nil) {
        
        // Instantiating an interstitial manager and loading an interstitial from it
        self.interstitialManager = [[SASInterstitialManager alloc] initWithPlacement:adPlacement delegate:self];
        [self.interstitialManager load];
        
    } else {
        
        // Placement is invalid, sending an error
        NSError *error = [NSError errorWithDomain:kSASGMAErrorDomain code:kSASGMAErrorCodeInvalidServerParameters userInfo:nil];
        [self.delegate customEventInterstitial:self didFailAd:error];
        
    }

}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (self.interstitialManager.adStatus == SASAdStatusReady) {
        // Showing the interstitial if ready
        [self.interstitialManager showFromViewController:rootViewController];
    }
}

#pragma mark SASAdViewDelegate implementation

- (void)interstitialManager:(SASInterstitialManager *)manager didLoadAd:(SASAd *)ad {
    [self.delegate customEventInterstitialDidReceiveAd:self];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didFailToLoadWithError:(NSError *)error {
    [self.delegate customEventInterstitial:self didFailAd:error];
}

- (BOOL)interstitialManager:(SASInterstitialManager *)manager shouldHandleURL:(NSURL *)URL {
    [self.delegate customEventInterstitialWasClicked:self];
    return YES;
}

- (void)interstitialManager:(SASInterstitialManager *)manager didAppearFromViewController:(UIViewController *)viewController {
    [self.delegate customEventInterstitialWillPresent:self];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didDisappearFromViewController:(UIViewController *)viewController {
    [self.delegate customEventInterstitialDidDismiss:self];
}

@end

NS_ASSUME_NONNULL_END
