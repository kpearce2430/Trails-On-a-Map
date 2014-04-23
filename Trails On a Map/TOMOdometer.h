//
//  TOMOdometer.h
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 4/10/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOMSubView.h"
#import "TOM.h"
#import "TOMSpeed.h"
#import "TOMDistance.h"

@interface TOMOdometer : TOMSubView
{
@private
    NSDictionary *textDict;
    UIFont       *textFont;
}

@property (nonatomic,readwrite) CGFloat trailDistance;
// @property (nonatomic,readwrite) CGFloat totalDistance;

-(void) resetView;

@end
