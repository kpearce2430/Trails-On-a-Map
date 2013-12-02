//
//  TOMSpeed.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/30/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TOM.h"

@interface TOMSpeed : NSObject

// FFU: @property (nonatomic, readwrite) CLLocationSpeed speed;

+ (CLLocationSpeed) displaySpeed: (CLLocationSpeed) s;
+ (NSString *) displaySpeedUnits;
+ (TOMDisplaySpeedType) speedType;

@end
