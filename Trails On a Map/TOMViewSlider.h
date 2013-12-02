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
    BOOL  displayup;  // YES - Display is up and visable; NO - Display is down
    CLLocationSpeed  displaySpeeds[TOM_SLIDER_NUM_PTS];
    CLLocationSpeed  maxSpeed;
    CLLocationSpeed  minSpeed;
    NSInteger        numSpeeds;
}

@property (nonatomic, readwrite) BOOL displayup;
@property (nonatomic, readwrite) CLLocationSpeed maxSpeed;
@property (nonatomic, readwrite) CLLocationSpeed minSpeed;
@property (nonatomic, readwrite) NSInteger numSpeeds;

// Methods
- (void) addSpeed: (CLLocationSpeed) sp;
- (CGFloat) percentY: (NSInteger) i;

@end
