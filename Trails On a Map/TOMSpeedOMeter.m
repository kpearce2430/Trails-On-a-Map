//
//  TOMSpeedOMeter.m
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 4/2/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import "math.h"

#import "TOMSpeedOMeter.h"



#define deg2rad (3.1415926/180.0)

@implementation TOMSpeedOMeter

@synthesize currentSpeed,lastType,maximumSpeed,maximumDisplay;

- (id)initWithFramePortrait:(CGRect)pFrame Landscape:(CGRect) lFrame
{
    self = [super initWithFramePortrait:pFrame Landscape:lFrame];
    if (self) {
        [self resetSpeedOMeter];
        [self resetView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self resetSpeedOMeter];
        [self resetView];
    }
    return self;
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
        [self setAlpha: 0.90];
        //  Build the outer box
        CGRect myFrame = CGRectMake( 0.00f , 0.00f, myWidth, myHeight);
        CGContextSetRGBStrokeColor(myContext, 0.0, 0.0, 0.0, 1.0);
        CGContextSetLineWidth(myContext, 3.0 );
        CGContextAddRect(myContext, myFrame);
        CGContextStrokePath(myContext);
    
        CGPoint centerPt = CGPointMake((myWidth/2.0f), (myHeight/2.0f));
    
        CGFloat radius = MIN(centerPt.x, centerPt.y);
        radius -= (.25f * radius);
        
        //
        // Draw the upright tic on the speedO
        CGFloat ticRadious = radius - (.2f *radius);
        CGFloat centerAngle = deg2rad*270.0f; // points up
        CGPoint ticPnt = CGPointMake(centerPt.x + (ticRadious * cos(centerAngle)), centerPt.y + (ticRadious * sin(centerAngle)));
        CGPoint midPnt = CGPointMake(centerPt.x + (radius * cos(centerAngle)), centerPt.y + (radius * sin(centerAngle)));
    
        // CGPoint minPoint = CGPointMake(minX, minY);
        CGContextBeginPath (myContext);
        CGContextSetRGBStrokeColor(myContext, 0.2, 0.2, 0.2, 1.0);
        CGContextMoveToPoint(myContext, ticPnt.x, ticPnt.y );
        CGContextAddLineToPoint(myContext, midPnt.x, midPnt.y );
        CGContextStrokePath(myContext);
    
        // Draw the Minimum Line
        CGFloat minAngle = deg2rad*135.0f;
        CGPoint minPnt = CGPointMake(centerPt.x + (radius * cos(minAngle)),centerPt.y + (radius * sin(minAngle)));

        CGContextBeginPath (myContext);
        CGContextSetRGBStrokeColor(myContext, 0.2, 0.2, 0.2, 1.0);
        CGContextMoveToPoint(myContext, centerPt.x, centerPt.y );
        CGContextAddLineToPoint(myContext, minPnt.x, minPnt.y );
        CGContextStrokePath(myContext);
    
        // Draw the Maximum Line
        CGFloat maxAngle = deg2rad*45.0f;
        CGPoint maxPnt = CGPointMake(centerPt.x + (radius * cos(maxAngle)), centerPt.y + (radius * sin(maxAngle)));
        CGContextBeginPath (myContext);
        CGContextSetRGBStrokeColor(myContext, 0.2, 0.2, 0.2, 1.0);
        CGContextMoveToPoint(myContext, centerPt.x, centerPt.y );
        CGContextAddLineToPoint(myContext, maxPnt.x, maxPnt.y );
        CGContextStrokePath(myContext);

        // Draw the Arc
        CGContextBeginPath (myContext);
        CGContextSetRGBStrokeColor(myContext, 0.2, 0.2, 0.2, 1.0);
        CGContextAddArc(myContext, centerPt.x, centerPt.y, radius, minAngle, maxAngle, NO);
        CGContextStrokePath(myContext);

        CGFloat currSpeedPct = 0.0f;
        CGFloat maxSpeedPct = 0.0f;

        // Draw the current and maximum speed arcs
        if (maximumDisplay > 0.0f) {
            currSpeedPct = currentSpeed / maximumDisplay;
            maxSpeedPct = maximumSpeed / maximumDisplay;
        }

        //
        // Draw the maximum speed line.
        CGFloat maxSpeedAngle =  (270.0f * maxSpeedPct) + 135.0f;
        maxSpeedAngle = fmodf(maxSpeedAngle, 360.0f );
        maxSpeedAngle = maxSpeedAngle * deg2rad;
        CGPoint maxSpeed = CGPointMake(0.0f, 0.0f);
        maxSpeed.x = centerPt.x + (radius * cos(maxSpeedAngle));
        maxSpeed.y = centerPt.y + (radius * sin(maxSpeedAngle));

        CGContextBeginPath (myContext);
        CGContextSetRGBStrokeColor(myContext, 1.0, 0.2, 0.2, 1.0);
        CGContextMoveToPoint(myContext, centerPt.x, centerPt.y );
        CGContextAddLineToPoint(myContext, maxSpeed.x, maxSpeed.y);
        CGContextStrokePath(myContext);
        
        // Draw the current speed line.
        CGFloat currSpeedAngle = (270.0f * currSpeedPct) + 135.0f;
        currSpeedAngle = fmodf(currSpeedAngle, 360.0f);
        currSpeedAngle = currSpeedAngle * deg2rad;
        CGPoint currSpeed = CGPointMake(0.0f, 0.0f);
        currSpeed.x = centerPt.x + (radius * cos(currSpeedAngle));
        currSpeed.y = centerPt.y + (radius * sin(currSpeedAngle));
        
        CGContextBeginPath (myContext);
        CGContextSetRGBStrokeColor(myContext, 0.0, 1.0, 0.0, 1.0);
        CGContextMoveToPoint(myContext, centerPt.x, centerPt.y );
        CGContextAddLineToPoint(myContext, currSpeed.x, currSpeed.y);
        CGContextStrokePath(myContext);
    
        if (!textFont) {
            textFont = [UIFont fontWithName: @TOM_FONT size: (radius/4.0f) ];
        }
        
        if (!mphFont) {
            mphFont = [UIFont fontWithName:@TOM_FONT size:(radius/3.0f)];
        }
    
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentRight];
    
        if (!textDict)
            textDict = [[NSDictionary alloc] initWithObjectsAndKeys: textFont, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    
        if (!redDict)
            redDict = [[NSDictionary alloc] initWithObjectsAndKeys: textFont, NSFontAttributeName, [UIColor redColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    
        if (!mphDict)
            mphDict = [[NSDictionary alloc] initWithObjectsAndKeys:mphFont,  NSFontAttributeName, [UIColor greenColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
        
        CLLocationSpeed tempSpeed = [TOMSpeed displaySpeed:currentSpeed];
        NSString *currSpeedText = [[NSString alloc] initWithFormat:@"%.1f %@", tempSpeed,[TOMSpeed displaySpeedUnits]];
        
        CGFloat currSpeedTextAngle = 110.0f * deg2rad;
        CGPoint currSpeedTextPnt = CGPointMake(centerPt.x + (radius * cos(currSpeedTextAngle)), centerPt.y + (radius * sin(currSpeedTextAngle)));
        [currSpeedText drawAtPoint:currSpeedTextPnt withAttributes:mphDict];
    
        NSString *minSpeedText = nil;
        NSString *format = nil;
        
        //
        // Note that Minutes per Mile are an inverse
        //  Therefore the faster the person is going, the smaller
        //  the max speed is.
        if ( lastType == tomDSMinutesPerMile) {
            format = @"%.2f";
            minSpeedText = @"999";
        }
        else {
            format = @"%.0f";
            minSpeedText = @"0";
        }
        
        [minSpeedText drawAtPoint:minPnt withAttributes:textDict];
        
        NSString *midSpeedText =  [[NSString alloc] initWithFormat:format, [TOMSpeed displaySpeed:(maximumDisplay/2.0f)]];
        [midSpeedText drawAtPoint:midPnt withAttributes:textDict];
    
        NSString *maxDisplayText =  [[NSString alloc] initWithFormat:format, [TOMSpeed displaySpeed:maximumDisplay]];
        [maxDisplayText drawAtPoint:maxPnt withAttributes:textDict];
    
        NSString *maxSpeedText =  [[NSString alloc] initWithFormat:format, [TOMSpeed displaySpeed:maximumSpeed]];
        [maxSpeedText drawAtPoint:maxSpeed withAttributes:redDict];
    }
    else { // Display is put away
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

-(void) updateSpeed: (CGFloat) sp
{
    if( maximumSpeed < sp )
        maximumSpeed = sp;
    
    if (lastType != [TOMSpeed speedType]) {
        maximumDisplay = 0.00f;
        lastType = [TOMSpeed speedType];
    }

    if (maximumSpeed  > maximumDisplay ) {
        
        if (lastType != tomDSMinutesPerMile) {
            CLLocationSpeed maxDisplayInDisplayUnits = [TOMSpeed displaySpeed:maximumSpeed];
   
            maxDisplayInDisplayUnits += 10.0f; //  Add 10 of the speed units
            maxDisplayInDisplayUnits -= fmodf(maxDisplayInDisplayUnits, 10.0f); // trim down to the next 10 of the speed unit.
        
            maximumDisplay = [TOMSpeed speedToMPS:maxDisplayInDisplayUnits];
        }
        else
            maximumDisplay = maximumSpeed + 5.0f;
    }
    
    currentSpeed = sp;
}


-(void) resetSpeedOMeter
{
    currentSpeed = 0.00f;
    maximumSpeed = 0.00f;
    maximumDisplay = 0.00f;
}

-(void) resetView
{
    textDict = nil;
    mphDict = nil;
    redDict = nil;
    textFont = nil;
    mphFont = nil;
    
}

@end
