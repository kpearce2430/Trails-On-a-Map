//
//  TOMDistance.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/30/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TOM.h"

@interface TOMDistance : NSObject

// CLLocationDistance
+ (CLLocationDistance) displayDistance: (CLLocationDistance) d;
+ (NSString *) displayDistanceUnits;
+ (TOMDisplayDistanceType) distanceType;
+ (CLLocationDistance) distanceFilter;
+ (CLLocationDistance) distanceFrom: (CLLocation *) loc1 To:(CLLocation *) loc2;

@end
