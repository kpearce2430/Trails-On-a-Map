//
//  TOMProperties.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/16/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "TOM.h"

@interface TOMProperties : NSObject

@property (nonatomic, strong)    NSString  *ptName;
@property (nonatomic, readwrite) MKMapType  ptMapType;
@property (nonatomic, readwrite) MKUserTrackingMode ptUserTrackingMode;
@property (nonatomic, readwrite) CLLocationDistance ptDistanceFilter;
@property (nonatomic, readwrite) CLLocationAccuracy ptLocationAccuracy;
@property (nonatomic, readwrite) BOOL showLocations;
@property (nonatomic, readwrite) BOOL showPictures;
@property (nonatomic, readwrite) BOOL showStops;
@property (nonatomic, readwrite) BOOL showNotes;
@property (nonatomic, readwrite) BOOL showSounds;
@property (nonatomic, readwrite) BOOL showInfoBar;
@property (nonatomic, readwrite) BOOL showSpeedBar;
@property (nonatomic, readwrite) TOMDisplaySpeedType ptDisplaySpeedType;


-(id) initWithTitle: (NSString *) title;

@end
