//
//  TOMSubView.m
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 4/6/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import "TOMSubView.h"

@implementation TOMSubView

@synthesize displayup,active;

- (id)initWithFramePortrait:(CGRect)pFrame Landscape:(CGRect) lFrame
{
    orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(orientation)) {
        self = [super initWithFrame:lFrame];
    }
    else
        self = [super initWithFrame:pFrame];
    
    if (self) {
        // Initialization code
        
        orientation = [[UIDevice currentDevice] orientation];
        self->landscapeRect = lFrame;
        self->portraitRect = pFrame;
        active = NO;
        displayup = NO;
        
        UITapGestureRecognizer *doubleFingerTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleFingerTap setNumberOfTapsRequired:2];
        [self addGestureRecognizer:doubleFingerTap];
        [self handleDoubleTap:nil]; // force one thru to get the right screen
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        orientation = [[UIDevice currentDevice] orientation];
        [self setFrame:frame];
        [self saveFrame:frame];
        
        UITapGestureRecognizer *doubleFingerTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleFingerTap setNumberOfTapsRequired:2];
        [self addGestureRecognizer:doubleFingerTap];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void) saveFrame: (CGRect) myFrame
{
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    if (currentOrientation != orientation) {
        orientation = currentOrientation;
        [self resetView];
    }
    
    if (displayup) {
        if (UIDeviceOrientationIsLandscape(orientation)) {
            landscapeRect = myFrame;
        }
        else {
            portraitRect = myFrame;
        }
    }
    else {
        if (UIDeviceOrientationIsLandscape(orientation)) {
            landscapeRect.origin.x = myFrame.origin.x;
            landscapeRect.origin.y = myFrame.origin.y;
        }
        else {
            portraitRect.origin.x = myFrame.origin.x;
            portraitRect.origin.y = myFrame.origin.y;
        }
    }
}

- (CGRect) getFrame
{
    CGRect minRect;
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    if (currentOrientation != orientation) {
        orientation = currentOrientation;
        [self resetView];
    }

    // NSLog(@"MY CENTER: %.2f %.2f ",self.center.x,self.center.y);
    
    if (UIDeviceOrientationIsLandscape(orientation))
        minRect = landscapeRect;
    else
        minRect = portraitRect;

    if (displayup == NO) {
 
        CGRect screenRect = [[UIScreen mainScreen] bounds];
    
        CGFloat screenWidth = screenRect.size.width;
        if (UIDeviceOrientationIsLandscape(orientation))
            screenWidth = screenRect.size.height;
        
        if (minRect.origin.x > (screenWidth / 2.0f))
            minRect.origin.x = screenWidth - TOM_SLIDER_MIN_X;
        else
            minRect.origin.x = 0.0f;
    
        minRect.size.width = TOM_SLIDER_MIN_X;
    }
    return minRect;
}


- (void) resetView
{
    NSLog(@"%s WARNING Method needs to be implemented in you class",__PRETTY_FUNCTION__);
    return;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    
    //Do stuff here...
    // CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    // NSLog(@"%s : Location(%.2f.%.2f)",__PRETTY_FUNCTION__,location.x, location.y);
    
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    if (currentOrientation != orientation) {
        orientation = currentOrientation;
        [self resetView];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGFloat screenWidth = screenRect.size.width;
    if (UIDeviceOrientationIsLandscape(orientation))
        screenWidth = screenRect.size.height;
    
    CGRect myframe;
    
    if (recognizer && [self displayup] == NO) {
        // increase
        [self setDisplayup:YES];
        myframe = [self getFrame];
    }
    else {
        // decrease
        [self setDisplayup:NO];
        myframe = [self getFrame];
    }
    
    [self setFrame:myframe];
    [self setNeedsDisplay];
}

@end
