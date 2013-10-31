//
//  TOMProperties.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/16/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMProperties.h"

@implementation TOMProperties

@synthesize ptMapType, ptName, ptUserTrackingMode,ptDistanceFilter,ptLocationAccuracy, showLocations, showPictures, showStops, showNotes, showSounds, showInfoBar, showSpeedBar;

-(id) initWithTitle: (NSString *) title
{
    self = [super init];
    if (self)
    {
        // initialize with defaults
        [self setPtName:title];
        [self setPtMapType:MKMapTypeStandard];
        [self setPtUserTrackingMode:MKUserTrackingModeNone];
        [self setPtDistanceFilter:50.0];
        [self setPtLocationAccuracy:kCLLocationAccuracyBestForNavigation];
        [self setShowLocations:YES];
        [self setShowPictures:YES];
        [self setShowStops:YES];
        [self setShowNotes:YES];
        [self setShowSounds:YES];
        [self setShowInfoBar:YES];
        [self setShowSpeedBar:YES];
    }
    return self;
}

@end
