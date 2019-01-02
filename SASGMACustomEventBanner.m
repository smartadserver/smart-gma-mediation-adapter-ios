//
//  SASGMACustomEventBanner.m
//
//  Created by Julien Gomez on 21/06/16.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASGMACustomEventBanner.h"
#import <SASDisplayKit/SASDisplayKit.h>
#import "SASGMACustomEventConstants.h"
#import "SASGMAUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface SASGMACustomEventBanner () <SASBannerViewDelegate>

@property(nonatomic, strong) SASBannerView *bannerView;

@end

@implementation SASGMACustomEventBanner

@synthesize delegate;

#pragma mark GMACustomEventBanner implementation

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(nullable NSString *)serverParameter
                  label:(nullable NSString *)serverLabel
                request:(GADCustomEventRequest *)request {
    
    // Placement parsing from the server string
    SASAdPlacement *adPlacement = [SASGMAUtils placementWithDFPServerParameter:serverParameter request:request];
    
    if (adPlacement != nil) {
        
        // Create the bannerView with the appropriate size
        self.bannerView = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, adSize.size.width, adSize.size.height)];
        self.bannerView.modalParentViewController = self.delegate.viewControllerForPresentingModalView;
        self.bannerView.delegate = self;
        
        // Load the previously retrieved ad placement
        [self.bannerView loadWithPlacement:adPlacement];
        
    } else {
        
        // Placement is invalid, sending an error
        NSError *error = [NSError errorWithDomain:kSASGMAErrorDomain code:kSASGMAErrorCodeInvalidServerParameters userInfo:nil];
        [self.delegate customEventBanner:self didFailAd:error];
        
    }

}

#pragma mark SASAdViewDelegate implementation

- (void)bannerViewDidLoad:(SASBannerView *)bannerView {
    [self.delegate customEventBanner:self didReceiveAd:bannerView];
}

- (void)bannerView:(SASBannerView *)bannerView didFailToLoadWithError:(NSError *)error {
    [self.delegate customEventBanner:self didFailAd:error];
}

- (BOOL)bannerView:(SASBannerView *)bannerView shouldHandleURL:(NSURL *)URL {
    [self.delegate customEventBannerWasClicked:self];
    return YES;
}

- (void)bannerViewWillPresentModalView:(SASBannerView *)bannerView {
    [self.delegate customEventBannerWillPresentModal:self];
}

- (void)bannerViewWillDismissModalView:(SASBannerView *)bannerView {
    [self.delegate customEventBannerWillDismissModal:self];
}

@end

NS_ASSUME_NONNULL_END
