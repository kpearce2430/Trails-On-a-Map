//
//  TOMTripTimer.m
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 4/10/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import "TOMTripTimer.h"

@implementation TOMTripTimer

@synthesize duration;

- (id)initWithFramePortrait:(CGRect)pFrame Landscape:(CGRect) lFrame
{
    self = [super initWithFramePortrait:pFrame Landscape:lFrame];
    if (self) {
        duration = 0.0f;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) resetView
{
    textDict = nil;
    textFont = nil;
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    
    if  (currentOrientation != orientation) {
        orientation = currentOrientation;
        [self resetView];
    }
    
    [self setBackgroundColor:[UIColor grayColor]];
    
    CGFloat myWidth = rect.size.width;
    CGFloat myHeight = rect.size.height;
    
    if ([self displayup]) {
        [self setAlpha: 8.0];
        //  Build the outer box
        CGRect myFrame = CGRectMake( 0.00f , 0.00f, myWidth, myHeight);
        CGContextSetRGBStrokeColor(myContext, 0.0, 0.0, 0.0, 1.0);
        CGContextSetLineWidth(myContext, 3.0 );
        CGContextAddRect(myContext, myFrame);
        CGContextStrokePath(myContext);
        
        if (!textFont)
            textFont = [UIFont fontWithName: @TOM_FONT size: (myHeight/3.0f) ];
        
        if (!textDict) {
            NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [style setAlignment:NSTextAlignmentCenter];
            textDict = [[NSDictionary alloc] initWithObjectsAndKeys: textFont, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName,  nil ];
        }
        
        CGFloat yOffSet = (myHeight - textFont.pointSize) / 2.0f;
        CGRect textRect = CGRectMake(0.0, yOffSet, myWidth, textFont.pointSize);
        NSString *curtTimeText = [[NSString alloc] initWithFormat:@"%@", [self elapseTimeString] ];
        [curtTimeText drawInRect:textRect withAttributes:textDict];
    }
    else {
        [self setAlpha: 0.80];
        CGFloat myStartY = ((1.0/5.0) * myHeight);
        CGFloat myEndY =   ((4.0/5.0) * myHeight);
        CGFloat myX = myWidth / 2.0; // (myHeight - 5);
        CGContextSetRGBStrokeColor(myContext, 1.0, 1.0, 1.0, 1.0);
        CGContextSetLineWidth(myContext, 1.0 );
        CGContextSetLineCap( myContext, kCGLineCapRound );
        CGContextBeginPath (myContext);
        CGContextMoveToPoint(myContext, myX, myStartY);
        CGContextAddLineToPoint(myContext, myX, myEndY);
        CGContextStrokePath(myContext);
        
        myStartY =  ((2.0/5.0) * myHeight);
        myEndY =    ((3.0/5.0) * myHeight);
        CGContextSetLineWidth(myContext, 3.0 );
        CGContextBeginPath (myContext);
        CGContextMoveToPoint(myContext, myX, myStartY);
        CGContextAddLineToPoint(myContext, myX, myEndY);
        CGContextStrokePath(myContext);
    }
}

//
// * * * * * * * * * * * * * * * * * * * * * *
//
- (NSString *) elapseTimeString {
    NSString *myTimeString = NULL;
    
    NSTimeInterval mytime = [self duration];
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    
    if (mytime > 3600.00) {
        hours = mytime / 3600;
        mytime -= (hours * 3600);
    }
    
    if (mytime > 60.00) {
        minutes = mytime / 60;
        mytime -= (minutes * 60);
    }
    seconds = mytime;
    
    if  (hours > 0 )
        myTimeString = [[NSString alloc] initWithFormat:@"%0d:%02d:%02d",hours,minutes,seconds];
    else if (minutes > 0 )
        myTimeString = [[NSString alloc] initWithFormat:@"%0d:%02d",minutes,seconds];
    else
        myTimeString = [[NSString alloc] initWithFormat:@"%02d",seconds];
    
    // NSLog(@"%s %@",__func__, myTimeString);
    return myTimeString;
}


@end
