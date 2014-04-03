//
//  TOMViewSlider.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/9/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#include "TOM.h"


@interface TOMViewSlider : UIView

{
@private
    // BOOL  displayup;  // YES - Display is up and visable; NO - Display is down
    NSMutableArray   *displayAltitudes;
    NSMutableArray   *displaySpeeds;
}

@property (nonatomic, readwrite) BOOL displayup;
@property (nonatomic, readwrite) BOOL active;
@property (nonatomic, readwrite) NSInteger startIndex;
@property (nonatomic, readwrite) CLLocationSpeed maxSpeed;
@property (nonatomic, readwrite) CLLocationSpeed minSpeed;
@property (nonatomic, readwrite) CLLocationDistance maxAltitude;
@property (nonatomic, readwrite) CLLocationDistance minAltitude;

// Public Methods
- (void) addSpeed: (CLLocationSpeed) sp Altitude: (CLLocationDistance) alt;
- (void) clearSpeedsAndAltitudes;



@end
