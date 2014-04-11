//
//  TOMTripTimer.h
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 4/10/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOM.h"
#import "TOMSubView.h"

@interface TOMTripTimer : TOMSubView
{
@private
    NSDictionary *textDict;
    UIFont       *textFont;
}

@property (nonatomic,readwrite) NSTimeInterval duration;

-(void) resetView;

@end
