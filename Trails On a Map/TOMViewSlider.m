//
//  TOMViewSlider.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/9/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMViewSlider.h"


@implementation TOMViewSlider

@synthesize minAltitude,maxAltitude,minSpeed,maxSpeed,startIndex;

- (id)initWithFramePortrait:(CGRect)pFrame Landscape:(CGRect) lFrame
{
    self = [super initWithFramePortrait:pFrame Landscape:lFrame];
    if (self) {
        // Initialization code
        [self resetSlider];
        [self resetView];
    }
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft ];
    [self addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight ];
    [self addGestureRecognizer:swipeRight];
    
    [self setActive:YES];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self resetSlider];
        [self resetView];
    }
 
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft ];
    [self addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight ];
    [self addGestureRecognizer:swipeRight];


    return self;
}

#pragma __gesture_methods__

//The event handling methods:
#ifdef __FFU__
- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    
    // Do stuff here...
    // CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    // NSLog(@"%s : Location(%.2f.%.2f)",__PRETTY_FUNCTION__,location.x, location.y);
    
    CGPoint tapPoint = [sender locationInView:self];
    NSLog(@"%s tapPoint[%.1f,%.1f",__PRETTY_FUNCTION__,tapPoint.x,tapPoint.y);
    

    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    
    if (currentOrientation != orientation) {
        orientation = currentOrientation;
        font = nil;
        speedDict = nil;
        altDict = nil;
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    if (UIDeviceOrientationIsLandscape(orientation))
        screenWidth = screenRect.size.height - 200.0f;
    
    CGRect myframe = [self frame];
    if (myframe.size.width <= TOM_SLIDER_MIN_X ) {
        // increase
        displayup = YES;
        myframe.size.width = screenWidth;
    }
    else {
        // decrease
        displayup = NO;
        myframe.size.width = TOM_SLIDER_MIN_X;
    }

    [self setFrame:myframe];
    [self setNeedsDisplay];
  
}

#endif

#ifndef __FFU__
#endif
- (IBAction)swipedRight:(UISwipeGestureRecognizer *)recognizer
{
    // NSLog(@"swiped right");
    if ((startIndex + TOM_SLIDER_HALF_PTS) > [displayAltitudes count] - TOM_SLIDER_NUM_PTS )
    {
        startIndex = [displayAltitudes count] - TOM_SLIDER_NUM_PTS;
        [self setActive:YES];
    }
    else {
        startIndex += TOM_SLIDER_HALF_PTS;
    }
    
    [self setNeedsDisplay];
    // NSLog(@"%s Swipped Right Start Index:%ld Active:%hhd",__PRETTY_FUNCTION__,(long)startIndex,active);
    
}

- (IBAction)swipedLeft:(UISwipeGestureRecognizer *)recognizer
{
    // NSLog(@"swiped left");
    if (startIndex - TOM_SLIDER_HALF_PTS < 0)
        startIndex = 0;
    else
        startIndex = startIndex - TOM_SLIDER_HALF_PTS;
    
    [self setActive:NO];
    [self setNeedsDisplay];
    // NSLog(@"%s Swipped Left Start Index:%d Active:%hhd",__PRETTY_FUNCTION__ ,startIndex,active);
}


// * * * * * * * * * * * * * * * * * * * * * * * * *

#pragma class_methods

- (void) clearSpeedsAndAltitudes
{
    if (displayAltitudes) {
        [displayAltitudes removeAllObjects];
    }
    
    if (displaySpeeds) {
        [displaySpeeds removeAllObjects];
    }
    
    maxSpeed  = 0.0f;
    minSpeed  = 99999.0f;
    maxAltitude = 0.0f;
    minAltitude = 99999.0f;

}

//
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    
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
        
        CGFloat oneSegX = myWidth / 12.0;
        CGFloat oneSegY = myHeight / 12.0;
        
        if (!font)
            font = [UIFont fontWithName: @TOM_FONT size: oneSegY ];
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentRight];
        
        if (!speedDict)
            speedDict = [[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName, [UIColor greenColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];

        NSString *maxText = nil;
        NSString *minText = nil;
        
        if (maxSpeed > 0.00f)
            maxText = [[NSString alloc] initWithFormat:@"%.0f",[TOMSpeed displaySpeed: maxSpeed]];
        else
            maxText = @"0";
        
        if (minSpeed < 1000.f && minSpeed > 0.00f)
            minText = [[NSString alloc] initWithFormat:@"%.0f",[TOMSpeed displaySpeed: minSpeed]];
        else
            minText =  @"0";
        
        [maxText drawAtPoint:CGPointMake(5.0f, 10.0f ) withAttributes:speedDict];
        [minText drawAtPoint:CGPointMake(5.0f, (myHeight -((3*oneSegY)/2.0))) withAttributes:speedDict];

        if (!altDict)
            altDict = [[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName, [UIColor redColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
        
        NSString *altMaxText = nil;
        NSString *altMinText = nil;
        
        if (maxAltitude > 0.00)
            altMaxText = [[NSString alloc] initWithFormat:@"%.0f",maxAltitude];
        else
            altMaxText = @"0";
        
        if (minAltitude < 13500 && minAltitude > 0.00)  // 13500m is higher than most commercial airliners fly
            altMinText = [[NSString alloc] initWithFormat:@"%.0f",minAltitude];
        else
            altMinText = @"0";
        
        [altMaxText drawAtPoint:CGPointMake(myWidth-oneSegX, 10.0f ) withAttributes:altDict];
        [altMinText drawAtPoint:CGPointMake(myWidth-oneSegX, (myHeight -((3*oneSegY)/2.0))) withAttributes:altDict];
        
        //  Build the box to contain the grid.
        myFrame = CGRectMake( oneSegX, oneSegY, 10.0 * oneSegX , 10.0 * oneSegY);
        CGContextSetRGBStrokeColor(myContext, 0.0, 0.0, 0.0, 1.0);
        CGContextSetLineWidth(myContext, 3.0 );
        CGContextAddRect(myContext, myFrame);
        CGContextStrokePath(myContext);
        
        //  Build the veritical grid
        CGContextSetRGBStrokeColor(myContext, 0.0, 0.0, 0.0, 1.0);
        CGContextSetLineWidth(myContext, 1.0 );
        for (CGFloat i = 2.0 ; i <= 10.0; i++ ) {
            // CGContextSetLineCap( myContext, kCGLineCapRound );
            CGContextBeginPath (myContext);
            CGContextMoveToPoint(myContext, i * oneSegX, oneSegY    );
            CGContextAddLineToPoint(myContext, i * oneSegX, 11.0 * oneSegY );
            CGContextStrokePath(myContext);
        }
        // Build the horizontal grid. (currently only one line at the half way point)
        CGContextBeginPath (myContext);
        CGContextMoveToPoint(myContext, oneSegX, 6.0 * oneSegY );
        CGContextAddLineToPoint(myContext, (11.0 * oneSegX),( 6.0 * oneSegY) );
        CGContextStrokePath(myContext);
        
        CGFloat incX = ((myWidth - (2*oneSegX))/(TOM_SLIDER_NUM_PTS-1));
        CGFloat incY = ((myHeight - (2*oneSegY))/1.0);
        
        // Draw the arrows
        CGContextSetRGBStrokeColor(myContext, 0.0, 0.0, 0.0, 1.0);
        CGContextSetRGBFillColor(myContext, 0.0, 0.0, 0.0, 1.0);
        CGContextSetLineWidth(myContext, 1.0);
        
        // int startSpeedIndex;
        if ([displaySpeeds count ] > TOM_SLIDER_NUM_PTS ) {
            if ([self active])
                startIndex = (int) ([displaySpeeds count] - (TOM_SLIDER_NUM_PTS));
        }
        else
            startIndex = 0;
            [self setAlpha: 0.80];
        // Draw them with a 2.0 stroke width so they are a bit more visible.
            if ((startIndex != 0) && ([displaySpeeds count] > TOM_SLIDER_NUM_PTS)) {
                CGContextMoveToPoint(myContext,    oneSegX,      9.0f*oneSegY );
                CGContextAddLineToPoint(myContext, oneSegX/2.0f, 6.0f*oneSegY );
                CGContextAddLineToPoint(myContext, oneSegX,      3.0f*oneSegY );
                CGContextAddLineToPoint(myContext, oneSegX,      9.0f*oneSegY );
                CGContextFillPath(myContext);
                CGContextStrokePath(myContext);
            }
        
            if (![self active] && (startIndex <  ([displaySpeeds count] - TOM_SLIDER_NUM_PTS))) {
                CGContextMoveToPoint(myContext,    11.0f * oneSegX, 9.0f*oneSegY );
                CGContextAddLineToPoint(myContext, 11.5f * oneSegX, 6.0f*oneSegY );
                CGContextAddLineToPoint(myContext, 11.0f * oneSegX, 3.0f*oneSegY );
                CGContextAddLineToPoint(myContext, 11.0f * oneSegX, 9.0f*oneSegY );
                CGContextFillPath(myContext);
                CGContextStrokePath(myContext);
            }

            // Begin the Altitude Graph Line
            if ([displaySpeeds count] >= 2) {
                CGContextBeginPath (myContext);
                CGContextSetRGBStrokeColor(myContext, 1.0, 0.0, 0.0, 1.0);
                CGContextSetLineWidth(myContext, 3.0 );
                int numPts = 1;
            
                // NSLog(@"0: sp:%.2f x:%.2f y:%.2f min: %.2f max: %.2f num:%ld" ,displaySpeeds[0], oneSegX, oneSegY + ([self percentSpeedY:0] * incY), minSpeed, maxSpeed, (long)numSpeeds );
                CGContextMoveToPoint(myContext, oneSegX, oneSegY + ([self percentAltitudeY:startIndex] * incY) );
                for (NSInteger i = startIndex+1 ; i < [displayAltitudes count] && numPts < TOM_SLIDER_NUM_PTS; i++) {
                    // NSLog(@"%ld sp:%@ x:%.2f y:%.2f (p:%.2f)",(long)i, displayAltitudes[i] ,oneSegX + (numPts*incX), oneSegY + ([self percentAltitudeY:i] * incY),[self percentAltitudeY:i]);
                    CGContextAddLineToPoint(myContext, oneSegX + (numPts*incX), oneSegY + ([self percentAltitudeY:i] * incY));
                    numPts++;
                }
            CGContextStrokePath(myContext);
          
            // Begin the Speeds Graph Line
            CGContextBeginPath (myContext);
            CGContextSetRGBStrokeColor(myContext, 0.0, 1.0, 0.0, 1.0);
            CGContextSetLineWidth(myContext, 3.0 );
            CGContextMoveToPoint(myContext, oneSegX, oneSegY + ([self percentSpeedY:startIndex] * incY) );
            numPts = 1;
            for (NSInteger i = startIndex+1 ; i < [displaySpeeds count] && numPts < TOM_SLIDER_NUM_PTS; i++) {
                // NSLog(@"%ld sp:%@ x:%.2f y:%.2f (p:%.2f)",(long)i, displaySpeeds[i] ,oneSegX + (numPts*incX), oneSegY + ([self percentY:i] * incY),[self percentY:i]);
                CGContextAddLineToPoint(myContext, oneSegX + (numPts*incX), oneSegY + ([self percentSpeedY:i] * incY));
                numPts++;
            }
            CGContextStrokePath(myContext);
            
        }
    }
    else {
        // [self setAlpha: 1.00];

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
//
//
- (void) addSpeed: (CLLocationSpeed) sp Altitude: (CLLocationDistance) alt
{
    // NSLog(@"ADDING:%.2f",sp);
    NSNumber *mySpeed = nil;
    NSNumber *myAltitude = nil; // [[NSNumber alloc] initWithDouble:alt];

    if ( sp < 0.00) {
        mySpeed = [[NSNumber alloc] initWithDouble:0.0f];
    }
    else {
        mySpeed = [[NSNumber alloc] initWithDouble:sp];
    }
    
    [displaySpeeds addObject:mySpeed];

#ifdef DEBUG
    if (alt <= 0.00f) {
        static CLLocationDistance testAlt = 300.0f;
        int theCount = [displayAltitudes count] / 10.0f;
        
        if (theCount & 1)
            testAlt += (random() % 10);
        else
            testAlt -= (random() % 10);
        myAltitude = [[NSNumber alloc] initWithDouble:testAlt];
    }
    else
#endif
        myAltitude = [[NSNumber alloc] initWithDouble:alt];
    
    [displayAltitudes addObject:myAltitude];
    
      if ([mySpeed doubleValue] > maxSpeed) {
        maxSpeed = [mySpeed doubleValue];
        // NSLog(@"SPEED MAX:%.2f",minSpeed);
    }
    
    if ([mySpeed doubleValue] < minSpeed) {
        minSpeed = [mySpeed doubleValue];
        // NSLog(@"SPEED MIN:%.2f",minSpeed);
    }
    
    // NSLog(@"SPEED MAX:%.2f MIN:%.2f",maxSpeed,minSpeed);
    
    if ([myAltitude doubleValue] > maxAltitude) {
        maxAltitude = [myAltitude doubleValue] ;
        // NSLog(@"ALT MAX:%.2f",maxAltitude);
    }
    
    if ([myAltitude doubleValue] < minAltitude) {
        minAltitude = [myAltitude doubleValue] ;
        // NSLog(@"ALT MIN:%.2f",minAltitude);
    }
    
    if ([displaySpeeds count] > TOM_SLIDER_NUM_PTS*10) {
        [displaySpeeds removeObjectAtIndex:0];
    }

    if ([displayAltitudes count] > TOM_SLIDER_NUM_PTS*10) {
        [displayAltitudes removeObjectAtIndex:0];
    }

}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
//  This function is used to place the Y coordinate of the graph.
//  Since the Y coordinates to from 0 at the top to max Y at the bottom,
//  I need to return the inverted percentage for the correct location.
//
- (CGFloat) percentSpeedY: (NSInteger) i
{
    CGFloat y;
    NSNumber *s = [displaySpeeds objectAtIndex:i];
    
    if (maxSpeed > 0.00f)
    {
        if (maxSpeed > 0.00f)
            y = 1.00f - ([s doubleValue] / maxSpeed );
        else
            y = 0.00f;
    }
    else
        y = 1.00f;
    
    if (y > 1.00f)
        return 1.00f;
    else if (y < 0.00f)
        return 0.00f;
    else
        return y;
}

- (CGFloat) percentAltitudeY: (NSInteger) i
{
    CGFloat y;
    NSNumber *s = [displayAltitudes objectAtIndex:i];
    CLLocationDistance myAlt = [s doubleValue];
    
    if (maxAltitude > 0.00f) {
        
        CLLocationDistance altRange = maxAltitude - minAltitude;
        CLLocationDistance myRange = myAlt - minAltitude;
        
        if (altRange > 0.0f)
            y = 1.0f - (myRange / altRange);
        else
            y = 0.00f;
    }
    else
        y = 1.00f;
    
    if (y > 1.00f)
        return 1.00f;
    else if (y < 0.00f)
        return 0.00f;
    else
        return y;
}

-(void) resetSlider
{
    maxSpeed  = 0.0f;
    minSpeed  = 99999.0f;
    maxAltitude = 0.0f;
    minAltitude = 99999.0f;
    displaySpeeds = [[NSMutableArray alloc] initWithCapacity:1000];
    displayAltitudes = [[NSMutableArray alloc] initWithCapacity:1000];
    startIndex = 0;
    font = nil;
    speedDict = nil;
    altDict = nil;
}


-(void) resetView
{
    font = nil;
    speedDict = nil;
    altDict = nil;
}

@end
