//
//  SASAdView+DFPMediation.m
//  DFPBannerExample
//
//  Created by Julien Gomez on 23/06/16.
//  Copyright © 2016 Google. All rights reserved.
//

#import "SASAdView+GAD.h"
#import "SASGADCustomEventConstants.h"


@implementation SASAdView (GAD)

- (void)loadFormatWithDFPServerParameter:(NSString *)serverParameter request:(GADCustomEventRequest *)request {

    // Process placement ids
    NSArray *stringComponents = [serverParameter componentsSeparatedByString:kSASGADCustomEventServerSeparatorString];
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

    // Process keywords target
    NSString *tar = [request.userKeywords componentsJoinedByString:@";"];

    // Use location if available
    if(request.userHasLocation) {
        [SASAdView setLocation:[[CLLocation alloc] initWithLatitude:request.userLatitude longitude:request.userLongitude]];
    }

    // Load SAS Ad View with previous placement ids and target
    [SASAdView setSiteID:sid baseURL:kSASBaseURLString];
    [self loadFormatId:fid pageId:pid master:YES target:tar];

}
@end
