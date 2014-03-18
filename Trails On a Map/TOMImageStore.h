//
//  TOMImageStore.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/25/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOMImageStore : NSObject

+ (BOOL)        imageExists:(NSString *) title key:(NSString *) key warn:(BOOL) yn;
+ (UIImage *)     loadImage:(NSString *) title key:(NSString *) key warn:(BOOL) yn;
+ (BOOL)        removeImage:(NSString *) title key: (NSString *) key;
+ (BOOL)          saveImage:(UIImage *)i title:(NSString *) title key:(NSString *)key;

@end
