//
//  SASGMARewardedAdapter.m
//
//  Created by Loïc GIRON DIT METAZ on 19/12/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASGMARewardedAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>
#import "SASGMACustomEventConstants.h"
#import "SASGMAUtils.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Rewarded video manager extension

@interface SASRewardedVideoManager (GADMediationRewardedAd) <GADMediationRewardedAd>

@end

@implementation SASRewardedVideoManager (GADMediationRewardedAd)

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
    [self showFromViewController:viewController];
}

@end

#pragma mark - Main adapter class

@interface SASGMARewardedAdapter () <SASRewardedVideoManagerDelegate>

@property (nonatomic, strong, nullable) SASRewardedVideoManager *rewardedVideoManager;

@property (nonatomic, copy, nullable) GADMediationRewardedLoadCompletionHandler loadCompletionHandler;
@property (nonatomic, weak, nullable) id<GADMediationRewardedAdEventDelegate> delegate;

@end

@implementation SASGMARewardedAdapter

#pragma mark - Adapter lifecycle

- (void)loadRewardedAdForAdConfiguration:(nonnull GADMediationRewardedAdConfiguration *)adConfiguration
                       completionHandler:(nonnull GADMediationRewardedLoadCompletionHandler)completionHandler {
    SASAdPlacement *adPlacement = [SASGMAUtils placementWithDFPServerParameter:adConfiguration.credentials.settings[@"parameter"] request:nil];
    
    if (adPlacement != nil) {
        self.loadCompletionHandler = completionHandler;
        
        // Instantiating a rewarded manager and loading a rewarded video from it
        self.rewardedVideoManager = [[SASRewardedVideoManager alloc] initWithPlacement:adPlacement delegate:self];
        [self.rewardedVideoManager load];
    } else {
        // Placement is invalid, sending an error
        NSError *error = [NSError errorWithDomain:kSASGMAErrorDomain code:kSASGMAErrorCodeInvalidServerParameters userInfo:nil];
        completionHandler(nil, error);
    }
    
}


- (void)loadRewardedInterstitialAdForAdConfiguration:(nonnull GADMediationRewardedAdConfiguration *)adConfiguration
                                   completionHandler:(nonnull GADMediationRewardedLoadCompletionHandler)completionHandler {
    SASAdPlacement *adPlacement = [SASGMAUtils placementWithDFPServerParameter:adConfiguration.credentials.settings[@"parameter"] request:nil];
    
    if (adPlacement != nil) {
        self.loadCompletionHandler = completionHandler;
        
        // Instantiating a rewarded manager and loading a rewarded video from it
        self.rewardedVideoManager = [[SASRewardedVideoManager alloc] initWithPlacement:adPlacement delegate:self];
        [self.rewardedVideoManager load];
    } else {
        // Placement is invalid, sending an error
        NSError *error = [NSError errorWithDomain:kSASGMAErrorDomain code:kSASGMAErrorCodeInvalidServerParameters userInfo:nil];
        completionHandler(nil, error);
    }
}

#pragma mark - Misc adapter methods

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

+ (GADVersionNumber)adSDKVersion {
    GADVersionNumber version;
    version.majorVersion = 7;
    return version;
}

+ (GADVersionNumber)version {
    GADVersionNumber version;
    version.majorVersion = 1;
    return version;
}

#pragma mark - Rewarded video manager delegate

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didLoadAd:(SASAd *)ad {
    self.delegate = self.loadCompletionHandler(self.rewardedVideoManager, nil);
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didFailToLoadWithError:(NSError *)error {
    self.loadCompletionHandler(nil, error);
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didAppearFromViewController:(UIViewController *)viewController {
    [self.delegate willPresentFullScreenView];
    [self.delegate reportImpression];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didDisappearFromViewController:(UIViewController *)viewController {
    [self.delegate willDismissFullScreenView];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didCollectReward:(SASReward *)reward {
    GADAdReward *gadReward = [[GADAdReward alloc] initWithRewardType:reward.currency
                                                        rewardAmount:[NSDecimalNumber decimalNumberWithDecimal:[reward.amount decimalValue]]];
    [self.delegate didRewardUserWithReward:gadReward];
}

- (BOOL)rewardedVideoManager:(SASRewardedVideoManager *)manager shouldHandleURL:(NSURL *)URL {
    [self.delegate reportClick];
    return YES;
}

@end

NS_ASSUME_NONNULL_END
