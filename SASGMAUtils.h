//
//  SASGMAUtils.h
//
//  Created by Julien Gomez on 23/06/16.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASGMAUtils : NSObject

/**
 Creates an ad placement from the server parameter string and the request if available.
 
 @param serverParameter The server parameter string retrieved from GMA.
 @param request The GMA request if available, nil otherwise.
 @return An ad placement if the server parameter string is valid, nil otherwise.
 */
+ (nullable SASAdPlacement *)placementWithDFPServerParameter:(nullable NSString *)serverParameter request:(nullable GADCustomEventRequest *)request;

@end

NS_ASSUME_NONNULL_END
