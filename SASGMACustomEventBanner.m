//
//  SASGMACustomEventBanner.m
//
//  Created by Julien Gomez on 21/06/16.
//  Copyright © 2016 Smart AdServer. All rights reserved.
//

#import "SASGMACustomEventBanner.h"
#import "SASBannerView.h"
#import "SASAdView+GMA.h"


@interface SASGMACustomEventBanner () <SASAdViewDelegate>

@property(nonatomic, strong) SASBannerView *bannerView;

@end

@implementation SASGMACustomEventBanner

@synthesize delegate;

#pragma mark GMACustomEventBanner implementation

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request {

    // Create the bannerView with the appropriate size.
    self.bannerView = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, adSize.size.width, adSize.size.height)];
    self.bannerView.modalParentViewController = self.delegate.viewControllerForPresentingModalView;
    self.bannerView.delegate = self;

    [self.bannerView loadFormatWithDFPServerParameter:serverParameter request:request];

}

#pragma mark SASAdViewDelegate implementation

- (void)adViewDidLoad:(SASAdView *)adView {
    [self.delegate customEventBanner:self didReceiveAd:adView];
}


- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
    [self.delegate customEventBanner:self didFailAd:error];
}


- (BOOL)adView:(SASAdView *)adView shouldHandleURL:(NSURL *)URL {
    [self.delegate customEventBannerWasClicked:self];
    return YES;
}


- (void)adViewWillPresentModalView:(SASAdView *)adView {
    [self.delegate customEventBannerWillPresentModal:self];
}


- (void)adViewWillDismissModalView:(SASAdView *)adView {
    [self.delegate customEventBannerWillDismissModal:self];
}

@end
