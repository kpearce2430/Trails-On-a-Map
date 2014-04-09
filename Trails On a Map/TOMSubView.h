//
//  TOMSubView.h
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 4/6/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOM.h"

//
// Common items between all subviews of
// Trails on a Map
//
@interface TOMSubView : UIView
{
    UIDeviceOrientation orientation;
    
    // The subviews will remember their frames;
    CGRect landscapeRect;
    CGRect portraitRect;
}


@property (nonatomic, readwrite) BOOL displayup;
@property (nonatomic, readwrite) BOOL active;


// Class methods
- (void) saveFrame: (CGRect) myFrame;
- (CGRect) getFrame;

- (void) resetView;  // needs to be set up
- (id)initWithFramePortrait:(CGRect)pFrame Landscape:(CGRect) lFrame;

@end
