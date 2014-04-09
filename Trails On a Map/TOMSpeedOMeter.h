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
#import "TOMSubView.h"

@interface TOMSpeedOMeter : TOMSubView
{
    @private
    NSDictionary *textDict;
    NSDictionary *redDict;
    NSDictionary *mphDict;
    UIFont       *textFont;
    UIFont       *mphFont;
}

@property (nonatomic, readwrite) CGFloat currentSpeed;
@property (nonatomic, readwrite) CGFloat maximumSpeed;
@property (nonatomic, readwrite) CGFloat maximumDisplay; // Will always be a little more of the maximum speed so the maximumSpeed line doesn't look pegged.
@property (nonatomic, readwrite) TOMDisplaySpeedType lastType;

-(void) resetSpeedOMeter;
-(void) updateSpeed: (CGFloat) sp;
- (id)initWithFramePortrait:(CGRect)pFrame Landscape:(CGRect) lFrame;

@end
