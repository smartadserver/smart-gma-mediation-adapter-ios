//
//  SASGMAUtils.m
//
//  Created by Julien Gomez on 23/06/16.
//  Copyright © 2018 Google. All rights reserved.
//

#import "SASGMAUtils.h"
#import "SASGMACustomEventConstants.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASGMAUtils

+ (nullable SASAdPlacement *)placementWithDFPServerParameter:(nullable NSString *)serverParameter request:(nullable GADCustomEventRequest *)request {
    
    // No placement can be generated without a server parameter string
    if (serverParameter == nil) {
        return nil;
    }

    // Processing the server parameter string
    NSArray *stringComponents = [serverParameter componentsSeparatedByString:kSASGMACustomEventServerSeparatorString];
    NSInteger sid = 0;
    NSString *pid = nil;
    NSInteger fid = 0;

    for (NSString * string in stringComponents) {
        NSInteger index = [stringComponents indexOfObject:string];
        if (index == 0) {
            sid = [string integerValue];
        } else if (index == 1) {
            pid = string;
        } else if (index == 2) {
            fid = [string integerValue];
        }
    }

    // Processing keywords target
    NSString *tar = nil;
    if (request != nil) {
        tar = [request.userKeywords componentsJoinedByString:@";"];
    }
    
    // Rejecting invalid parameters
    if (sid <= 0 || pid == nil || [pid length] == 0 || fid <= 0) {
        return nil;
    }

    // Setting the location if available
    if (request != nil && request.userHasLocation) {
        [SASConfiguration sharedInstance].manualLocation = CLLocationCoordinate2DMake(request.userLatitude, request.userLongitude);
    }

    // Setting the base URL and the site ID
    [[SASConfiguration sharedInstance] configureWithSiteId:sid];
    [[SASConfiguration sharedInstance] setPrimarySDK:NO];
    
    // Ad placement instantiation
    return [SASAdPlacement adPlacementWithSiteId:sid pageName:pid formatId:fid keywordTargeting:tar];
}

@end

NS_ASSUME_NONNULL_END
