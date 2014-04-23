//
//  TOMOdometer.m
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 4/10/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import "TOMOdometer.h"

@implementation TOMOdometer

@synthesize trailDistance; // ,totalDistance;

- (id)initWithFramePortrait:(CGRect)pFrame Landscape:(CGRect) lFrame
{
    self = [super initWithFramePortrait:pFrame Landscape:lFrame];
    if (self) {
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


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

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
        NSString *currDistanceText = [[NSString alloc] initWithFormat:@"%.2f %@", [TOMDistance displayDistance:trailDistance],[TOMDistance displayDistanceUnits]];
        [currDistanceText drawInRect:textRect withAttributes:textDict];
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

@end
