//
//  TOMUIUtilities.m
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 3/14/15.
//  Copyright (c) 2015 Pearce Software Solutions. All rights reserved.
//

#import "TOMUIUtilities.h"

@implementation TOMUIUtilities


+ (void) screenRect: (CGRect *) screenRect {

    // static Boolean first = true;
    // CGFloat screenHeight = -1.0;
    // CGFloat screenWidth = -1.0;
    
    if (!screenRect) {
        return;
    }
    
    CGRect myScreenRect = [[UIScreen mainScreen] bounds];
    UIDeviceOrientation myOrientation = [[UIDevice currentDevice] orientation];

  

#ifdef __DEBUG
    NSLog(@"Start %s",__PRETTY_FUNCTION__);
    NSLog(@"mainScreen %@ orig[x:%f y:%f],size[w:%f h:%f]", [TOMUIUtilities printOrientation: myOrientation],
          myScreenRect.origin.x, myScreenRect.origin.y,
          myScreenRect.size.width, myScreenRect.size.height );

#endif

    screenRect->origin.x = myScreenRect.origin.x;
    screenRect->origin.y = myScreenRect.origin.y;
    
    
    if ([TOMUIUtilities isIOS8]) {


        switch (myOrientation) {
            case    UIDeviceOrientationLandscapeLeft:
            case    UIDeviceOrientationLandscapeRight:
            // case    UIDeviceOrientationPortraitUpsideDown:
                screenRect->size.width = MAX(myScreenRect.size.width, myScreenRect.size.height);
                screenRect->size.height = MIN(myScreenRect.size.width, myScreenRect.size.height);
                break;
                
            default: // Portrait, Face Down, Face Up
                screenRect->size.height = MAX(myScreenRect.size.width, myScreenRect.size.height);
                screenRect->size.width = MIN(myScreenRect.size.width, myScreenRect.size.height);
                break;
        }
    }
    
    else if ( UIDeviceOrientationIsLandscape(myOrientation)  ||
             myOrientation == UIDeviceOrientationPortraitUpsideDown ) {
        // Pre IOS 8 you have to flip these values;
        screenRect->size.width = myScreenRect.size.height;
        screenRect->size.height = myScreenRect.size.width;
    }
    else {
        screenRect->size.height = myScreenRect.size.height;
        screenRect->size.width = myScreenRect.size.width;
    }
#ifdef DEBUG
    NSLog(@"screenRect %@ orig[x:%f y:%f],size[w:%f h:%f]\n", [TOMUIUtilities printOrientation: myOrientation],
          screenRect->origin.x, screenRect->origin.y,
          screenRect->size.width, screenRect->size.height );
    // NSLog(@"End %s",__PRETTY_FUNCTION__);
#endif
    
    
}

// * * * * * * * * * * * * * * * * * * * *

+ (Boolean) isIOS8 {
    
    static Boolean myResult = false;
    static Boolean firstTime = true;
    
    if (!firstTime) {
        return myResult;
    }
   
    NSString *reqSysVer = @"7.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([[[UIDevice currentDevice] systemVersion] compare:reqSysVer options:NSNumericSearch] == NSOrderedDescending) {
        NSLog(@"Current Version:%@", currSysVer);
        
        if(NSClassFromString(@"NSProcessInfo")) {
            // Do something
            NSOperatingSystemVersion myVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
            if  (myVersion.majorVersion > 7) {
                firstTime = false;
                myResult  = true;
                return myResult;
            }
        }
    }
    firstTime = false;
    myResult  = false;
    return myResult;
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

+ (NSString *) printOrientation: (UIDeviceOrientation) myOrientation  {

    switch (myOrientation) {
        case UIDeviceOrientationUnknown:
            return @"Unknown";
            break;
        
        case UIDeviceOrientationPortrait:
            return @"Portrait";
            break;
        
        case UIDeviceOrientationPortraitUpsideDown:
            return @"Portrait Upside Down";
            break;
        
        case UIDeviceOrientationLandscapeLeft:
            return @"Landscape Left";
            break;
        
        case UIDeviceOrientationLandscapeRight:
            return @"Landscape Right";
            break;
        
        case UIDeviceOrientationFaceUp:
            return @"Face Up";
            break;
        
        case UIDeviceOrientationFaceDown:
            return @"Face Down";
            break;
            
            
        default:
            break;
    }

}
    
@end
