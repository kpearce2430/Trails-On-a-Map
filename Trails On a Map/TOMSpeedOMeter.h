//
//  TOMSpeedOMeter.h
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 4/2/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOM.h"
#import "TOMSpeed.h"

@interface TOMSpeedOMeter : UIView
{
    @private
    NSDictionary *textDict;
    NSDictionary *redDict;
    UIFont *font;
    UIDeviceOrientation orientation;
}

@property (nonatomic, readwrite) CGFloat currentSpeed;
@property (nonatomic, readwrite) CGFloat maximumSpeed;
@property (nonatomic, readwrite) CGFloat maximumDisplay; // Will always be a little more of the maximum speed so the maximumSpeed line doesn't look pegged.
@property (nonatomic, readwrite) TOMDisplaySpeedType lastType;
@property (nonatomic, readwrite) BOOL displayup;
@property (nonatomic, readwrite) BOOL active;

-(void) resetSpeedOMeter;
-(void) updateSpeed: (CGFloat) sp;

@end
