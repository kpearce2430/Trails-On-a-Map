//
//  TOMViewSlider.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/9/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMViewSlider.h"
#import "TOMSpeed.h"
#import "TOMDistance.h"

@implementation TOMViewSlider

@synthesize active,displayup,minAltitude,maxAltitude,minSpeed,maxSpeed,startIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        maxSpeed  = 0.0f;
        minSpeed  = 99999.0f;
        maxAltitude = 0.0f;
        minAltitude = 999999.0f;
        displaySpeeds = [[NSMutableArray alloc] initWithCapacity:100];
        displayAltitudes = [[NSMutableArray alloc] initWithCapacity:100];
        active = YES;
        startIndex = 0;
    }
    
    UITapGestureRecognizer *doubleFingerTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleFingerTap setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleFingerTap];

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

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    
    // Do stuff here...
    // CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    // NSLog(@"%s : Location(%.2f.%.2f)",__PRETTY_FUNCTION__,location.x, location.y);
    static UIDeviceOrientation orientation = UIDeviceOrientationUnknown;
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    
    if (currentOrientation != orientation) {
        orientation = currentOrientation;
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

- (IBAction)swipedRight:(UISwipeGestureRecognizer *)recognizer
{
    // NSLog(@"swiped right");
    // CGPoint locInView = [recognizer locationInView:self];
    // NSLog(@"location In View (%.1f,%.1f)",locInView.x,locInView.y);
    //
    // for (NSInteger i = 0 ; i < [recognizer numberOfTouches]; i++)
    // {
    //    CGPoint locOfTouch = [recognizer locationOfTouch:i inView:self];
    //    NSLog(@"location Of Touch %d (%.1f,%.1f)",(int)i,locOfTouch.x,locOfTouch.y);
    // }
    //
    // int half = TOM_SLIDER_NUM_PTS / 2.0f;
    if ((startIndex + TOM_SLIDER_HALF_PTS) > [displayAltitudes count] - TOM_SLIDER_NUM_PTS )
    {
        startIndex = [displayAltitudes count] - TOM_SLIDER_NUM_PTS;
        active = YES;
    }
    else {
        startIndex += TOM_SLIDER_HALF_PTS;
    }
    
    NSLog(@"%s Swipped Right Start Index:%ld Active:%hhd",__PRETTY_FUNCTION__,(long)startIndex,active);
    
}

- (IBAction)swipedLeft:(UISwipeGestureRecognizer *)recognizer
{
    // NSLog(@"swiped left");
    // CGPoint locInView = [recognizer locationInView:self];
    // NSLog(@"location In View (%.1f,%.1f)",locInView.x,locInView.y);
    //
    // CGPoint locOfTouch = [recognizer locationOfTouch:0 inView:nil];
    // NSLog(@"location Of Topuch (%.1f,%.1f)",locOfTouch.x,locOfTouch.y);
    //
    // int half = TOM_SLIDER_NUM_PTS / 2.0f;
    //
    if (startIndex - TOM_SLIDER_HALF_PTS < 0)
        startIndex = 0;
    else
        startIndex = startIndex - TOM_SLIDER_HALF_PTS;
    
    active = NO;
    NSLog(@"%s Swipped Left Start Index:%d Active:%hhd",__PRETTY_FUNCTION__ ,startIndex,active);
}
#ifdef __TRACKING_TOUCHES__
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
#ifdef DEBUG
    NSLog(@"%s In touches Began %@",__PRETTY_FUNCTION__,event);
    
    // NSEnumerator *enumerator = [touches objectEnumerator];
    // id value;
    
    // while ((value = [enumerator nextObject])) {
        /* code that acts on the set’s values */
        // NSLog(@"%@",value);
    // }
#endif
    
#ifdef __FFU__
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    // CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    CGRect myframe = [self frame];
    if (myframe.size.width <= TOM_SLIDER_MIN_X ) {
        // increase
        displayup = YES;
        myframe.size.width = screenWidth;
        // myframe.origin.y -= TOM_SLIDER_MAX_Y;
    }
    else {
        // decrease
        displayup = NO;
        myframe.size.width = TOM_SLIDER_MIN_X;
        // myframe.origin.y += TOM_SLIDER_MAX_Y;
    }
    
    [self setFrame:myframe];
    [self setNeedsDisplay];
#endif
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
#ifdef DEBUG
    NSLog(@"%s In touches Began %@",__PRETTY_FUNCTION__,event);
    
    // NSEnumerator *enumerator = [touches objectEnumerator];
    // id value;
    // UITouch *touch;
    // while ((touch = [enumerator nextObject])) {
        /* code that acts on the set’s values */
        // NSLog(@"Touch: %@",touch);
    // }
#else
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    // CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    CGRect myframe = [self frame];
    if (myframe.size.width <= TOM_SLIDER_MIN_X ) {
        // increase
        displayup = YES;
        myframe.size.width = screenWidth;
        // myframe.origin.y -= TOM_SLIDER_MAX_Y;
    }
    else {
        // decrease
        displayup = NO;
        myframe.size.width = TOM_SLIDER_MIN_X;
        // myframe.origin.y += TOM_SLIDER_MAX_Y;
    }
    
    [self setFrame:myframe];
    [self setNeedsDisplay];
#endif
    
}
#endif

#pragma class_methods

// * * * * * * * * * * * * * * * * * * * * * * * * *

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
    if (displayup)
        [self setAlpha: 0.50];
    else
        [self setAlpha: 0.80];

    CGFloat myWidth = rect.size.width;
    CGFloat myHeight = rect.size.height;

    if (displayup) {
        
        CGFloat oneSegX = myWidth / 12.0;
        CGFloat oneSegY = myHeight / 12.0;
        UIFont *font = [UIFont fontWithName: @TOM_FONT size: oneSegY ];
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentRight];
        
        NSDictionary *speedDict = [[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName, [UIColor greenColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];

        NSString *maxText = [[NSString alloc] initWithFormat:@"%.0f",[TOMSpeed displaySpeed: maxSpeed]];
        NSString *minText = [[NSString alloc] initWithFormat:@"%.0f",[TOMSpeed displaySpeed: minSpeed]];

        [maxText drawAtPoint:CGPointMake(5.0f, 10.0f ) withAttributes:speedDict];
        [minText drawAtPoint:CGPointMake(5.0f, (myHeight -((3*oneSegY)/2.0))) withAttributes:speedDict];

        NSDictionary *altDict = [[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName, [UIColor redColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
        NSString *altMaxText = [[NSString alloc] initWithFormat:@"%.0f",maxAltitude];
        NSString *altMinText = [[NSString alloc] initWithFormat:@"%.0f",minAltitude];
        
        [altMaxText drawAtPoint:CGPointMake(myWidth-oneSegX, 10.0f ) withAttributes:altDict];
        [altMinText drawAtPoint:CGPointMake(myWidth-oneSegX, (myHeight -((3*oneSegY)/2.0))) withAttributes:altDict];
        
        //  Build the outer box
        CGRect myFrame = CGRectMake( oneSegX, oneSegY, 10.0 * oneSegX , 10.0 * oneSegY);
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

        // int startSpeedIndex;
        if ([displaySpeeds count ] > TOM_SLIDER_NUM_PTS ) {
            if (active)
                startIndex = (int) ([displaySpeeds count] - (TOM_SLIDER_NUM_PTS));
        }
        else
            startIndex = 0;
        
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


@end
