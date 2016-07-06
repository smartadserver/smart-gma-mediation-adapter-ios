//
//  SASGADCustomEventInterstitial.m
//
//  Created by Julien Gomez on 22/06/16.
//  Copyright © 2016 Smart AdServer. All rights reserved.
//

#import "SASGADCustomEventInterstitial.h"
#import "SASInterstitialView.h"
#import "SASAdView+GAD.h"


@interface SASGADCustomEventInterstitial () <SASAdViewDelegate>

@property(nonatomic, strong) SASInterstitialView *interstitialView;

@end

@implementation SASGADCustomEventInterstitial

@synthesize delegate;

#pragma mark GADCustomEventInterstitial implementation

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
                                     label:(NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request {

    // Create the interstitialView using root view controller to determine the size of the interstitial
    UIViewController *rootViewController = [[[[UIApplication sharedApplication]delegate] window] rootViewController];
    self.interstitialView =
    [[SASInterstitialView alloc] initWithFrame:rootViewController.view.bounds];
    self.interstitialView.delegate = self;
    [self.interstitialView loadFormatWithDFPServerParameter:serverParameter request:request];

}


- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.delegate customEventInterstitialWillPresent:self];
    self.interstitialView.modalParentViewController = rootViewController;
    [rootViewController.view addSubview:self.interstitialView];
}

#pragma mark SASAdViewDelegate implementation

- (void)adViewDidLoad:(SASAdView *)adView {
    [self.delegate customEventInterstitialDidReceiveAd:self];
}


- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
    [self.delegate customEventInterstitial:self didFailAd:error];
}


- (BOOL)adView:(SASAdView *)adView shouldHandleURL:(NSURL *)URL {
    [self.delegate customEventInterstitialWasClicked:self];
    return YES;
}


- (void)adView:(SASAdView *)adView willPerformActionWithExit:(BOOL)willExit {
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}


- (void)adViewDidDisappear:(SASAdView *)adView {
    [self.delegate customEventInterstitialDidDismiss:self];
}

@end
