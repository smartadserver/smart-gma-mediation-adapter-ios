//
//  SASAdView+GAD.h
//
//  Created by Julien Gomez on 23/06/16.
//  Copyright © 2016 Smart AdServer. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>

#import "SASAdView.h"


@interface SASAdView (GAD)

- (void)loadFormatWithDFPServerParameter:(NSString *)serverParameter request:(GADCustomEventRequest *)request;

@end
