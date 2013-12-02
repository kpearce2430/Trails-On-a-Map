//
//  TOMViewSlider.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/9/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMViewSlider.h"
#import "TOMSpeed.h"

@implementation TOMViewSlider

@synthesize displayup,minSpeed,maxSpeed,numSpeeds;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        numSpeeds = 0;
        maxSpeed  = 0.0;
        minSpeed  = 9999.0;
    }
    return self;
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
    CGFloat myHieight = rect.size.height;
    
    
    if (displayup) {
        
        CGFloat oneSegX = myWidth / 12.0;
        CGFloat oneSegY = myHieight / 12.0;
        UIFont *font = [UIFont fontWithName: @TOM_FONT size: oneSegY ];
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentRight];
        
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
        
        NSString *maxText = [[NSString alloc] initWithFormat:@"%.0f",[TOMSpeed displaySpeed: maxSpeed]];
        NSString *minText = [[NSString alloc] initWithFormat:@"%.0f",[TOMSpeed displaySpeed: minSpeed]];

        [maxText drawAtPoint:CGPointMake(5.0f, 10.0f ) withAttributes:dictionary];
        [minText drawAtPoint:CGPointMake(5.0f, (myHieight-((3*oneSegY)/2.0))) withAttributes:dictionary];
                                         
        //  Build the outer box
        CGContextSetRGBStrokeColor(myContext, 0.0, 0.0, 0.0, 1.0);
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
        // Build the horizontal grid.
        CGContextBeginPath (myContext);
        CGContextMoveToPoint(myContext, oneSegX, 6.0 * oneSegY );
        CGContextAddLineToPoint(myContext, TOM_SLIDER_NUM_PTS * oneSegX, 6.0 * oneSegY );
        CGContextStrokePath(myContext);
        
        CGFloat incX = ((myWidth - (2*oneSegX))/(TOM_SLIDER_NUM_PTS-1));
        CGFloat incY = ((myHieight - (2*oneSegY))/1.0);
        
        if (numSpeeds >= 2) {
            CGContextBeginPath (myContext);
            CGContextSetRGBStrokeColor(myContext, 1.0, 0.0, 0.0, 1.0);
            CGContextSetLineWidth(myContext, 3.0 );
            // NSLog(@"0: sp:%.2f x:%.2f y:%.2f min: %.2f max: %.2f num:%ld" ,displaySpeeds[0], oneSegX, oneSegY + ([self percentY:0] * incY), minSpeed, maxSpeed, (long)numSpeeds );
            CGContextMoveToPoint(myContext, oneSegX, oneSegY + ([self percentY:0] * incY) );
            for (NSInteger i = 1 ; i < numSpeeds; i++) {
                // NSLog(@"%ld sp:%.2f x:%.2f y:%.2f (p:%.2f)",(long)i, displaySpeeds[i] ,oneSegX + (i*incX), oneSegY + ([self percentY:i] * incY),[self percentY:i]);
                CGContextAddLineToPoint(myContext, oneSegX + (i*incX), oneSegY + ([self percentY:i] * incY));
            }
            CGContextStrokePath(myContext);
        }
    }
    else {
        CGFloat myStartX = ((1.0/5.0) * myWidth);
        CGFloat myEndX =   ((4.0/5.0) * myWidth);
        CGFloat myY = TOM_SLIDER_MIN_Y / 2.0; // (myHeight - 5);
        CGContextSetRGBStrokeColor(myContext, 1.0, 1.0, 1.0, 1.0);
        CGContextSetLineWidth(myContext, 1.0 );
        CGContextSetLineCap( myContext, kCGLineCapRound );
        CGContextBeginPath (myContext);
        CGContextMoveToPoint(myContext, myStartX, myY);
        CGContextAddLineToPoint(myContext, myEndX, myY);
        CGContextStrokePath(myContext);
        
        myStartX = ((2.0/5.0) * myWidth);
        myEndX =   ((3.0/5.0) * myWidth);
        CGContextSetLineWidth(myContext, 3.0 );
        CGContextBeginPath (myContext);
        CGContextMoveToPoint(myContext, myStartX, myY);
        CGContextAddLineToPoint(myContext, myEndX, myY);
        CGContextStrokePath(myContext);
    }
}
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
#ifdef __DEBUGGING__
    NSLog(@"In touches Began %@",event);
    NSEnumerator *enumerator = [touches objectEnumerator];
    id value;
    
    while ((value = [enumerator nextObject])) {
        /* code that acts on the set’s values */
        NSLog(@"%@",value);
    }
#endif
    
    CGRect myframe = [self frame];
    if (myframe.size.height <= TOM_SLIDER_MIN_Y ) {
        // increase
        displayup = YES;
        myframe.size.height += TOM_SLIDER_MAX_Y;
        myframe.origin.y -= TOM_SLIDER_MAX_Y;
    }
    else {
        // decrease
        displayup = NO;
        myframe.size.height -= TOM_SLIDER_MAX_Y;
        myframe.origin.y += TOM_SLIDER_MAX_Y;
    }

    [self setFrame:myframe];
    [self setNeedsDisplay];
}

//
//
//
- (void) addSpeed: (CLLocationSpeed) sp
{
    // NSLog(@"ADDING:%.2f",sp);
    CLLocationSpeed mySpeed;
    
    if ( sp < 0.00) {
        mySpeed = 0.00;
    }
    else {
        mySpeed = sp;
    }
    if (numSpeeds < TOM_SLIDER_NUM_PTS) {
        displaySpeeds[numSpeeds] = mySpeed;
        numSpeeds++;
    }
    else {
        for (int i = 0; i < TOM_SLIDER_NUM_PTS-1 ; i++) {
            displaySpeeds[i] = displaySpeeds[i+1];
        }
        displaySpeeds[TOM_SLIDER_NUM_PTS-1] = mySpeed;
    }

    if (sp > maxSpeed) {
        // NSLog(@"New Max Speed:%.2f Prev:%.2f",sp,maxSpeed);
        maxSpeed = sp;
    }
    
    if (sp < minSpeed) {
        // NSLog(@"NEW Min Speed:%.2f Prev:%.2f",sp,minSpeed);
        minSpeed = sp;
    }
    // NSLog(@"MAX:%.2f MIN:%.2f",maxSpeed,minSpeed);
}
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
//  This function is used to place the Y coordinate of the graph.
//  Since the Y coordinates to from 0 at the top to max Y at the bottom,
//  I need to return the inverted percentage for the correct location.
//
- (CGFloat) percentY: (NSInteger) i
{
    CGFloat y;
    if (maxSpeed > 0.00f)
        y = 1.00f - (displaySpeeds[i] / maxSpeed );
    else
        y = 1.00f;
    
    return y;
}

@end
