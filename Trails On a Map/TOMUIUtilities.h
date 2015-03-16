//
//  TOMUIUtilities.h
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 3/14/15.
//  Copyright (c) 2015 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TOMUIUtilities : NSObject

+ (void) screenRect: (CGRect *) screenRect;
+ (Boolean) isIOS8;
+ (NSString *) printOrientation: (UIDeviceOrientation) myOrientation;

@end
