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

@interface SASGMARewardedAdapter () <SASRewardedVideoManagerDelegate>

@property (nonatomic, weak) id<GADMRewardBasedVideoAdNetworkConnector> connector;
@property (nonatomic, strong) NSString *serverParameter;

@property (nonatomic, strong, nullable) SASRewardedVideoManager *rewardedVideoManager;

@end

@implementation SASGMARewardedAdapter

#pragma mark - Adapter lifecycle

- (instancetype)initWithRewardBasedVideoAdNetworkConnector:(id<GADMRewardBasedVideoAdNetworkConnector>)connector {
    if (self = [super init]) {
        self.connector = connector;
        self.serverParameter = [[connector credentials] objectForKey:@"parameter"];
    }
    
    return self;
}

- (void)setUp {
    // Nothing to setup here
    [self.connector adapterDidSetUpRewardBasedVideoAd:self];
}

- (void)stopBeingDelegate {
    self.rewardedVideoManager = nil;
}

#pragma mark - Rewarded requesting & presentation

- (void)requestRewardBasedVideoAd {
    // Placement parsing from the server string
    SASAdPlacement *adPlacement = [SASGMAUtils placementWithDFPServerParameter:self.serverParameter request:nil];
    
    if (adPlacement != nil) {
        
        // Instantiating a rewarded manager and loading a rewarded video from it
        self.rewardedVideoManager = [[SASRewardedVideoManager alloc] initWithPlacement:adPlacement delegate:self];
        [self.rewardedVideoManager load];
        
    } else {
        
        // Placement is invalid, sending an error
        NSError *error = [NSError errorWithDomain:kSASGMAErrorDomain code:kSASGMAErrorCodeInvalidServerParameters userInfo:nil];
        [self.connector adapter:self didFailToLoadRewardBasedVideoAdwithError:error];
        
    }
}

- (void)presentRewardBasedVideoAdWithRootViewController:(UIViewController *)viewController {
    if (self.rewardedVideoManager.adStatus == SASAdStatusReady) {
        // Showing the rewarded video if ready
        [self.rewardedVideoManager showFromViewController:viewController];
    }
}

#pragma mark - Misc adapter methods

+ (NSString *)adapterVersion {
    return kSASAdapterVersion;
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

#pragma mark - Rewarded video manager delegate

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didLoadAd:(SASAd *)ad {
    [self.connector adapterDidReceiveRewardBasedVideoAd:self];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didFailToLoadWithError:(NSError *)error {
    [self.connector adapter:self didFailToLoadRewardBasedVideoAdwithError:error];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didAppearFromViewController:(UIViewController *)viewController {
    [self.connector adapterDidOpenRewardBasedVideoAd:self];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didDisappearFromViewController:(UIViewController *)viewController {
    [self.connector adapterDidCloseRewardBasedVideoAd:self];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didCollectReward:(SASReward *)reward {
    GADAdReward *gadReward = [[GADAdReward alloc] initWithRewardType:reward.currency
                                                        rewardAmount:[NSDecimalNumber decimalNumberWithDecimal:[reward.amount decimalValue]]];
    [self.connector adapter:self didRewardUserWithReward:gadReward];
}

- (BOOL)rewardedVideoManager:(SASRewardedVideoManager *)manager shouldHandleURL:(NSURL *)URL {
    [self.connector adapterDidGetAdClick:self];
    return YES;
}

@end

NS_ASSUME_NONNULL_END
