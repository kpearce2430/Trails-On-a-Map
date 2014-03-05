//
//  TOMImageStore.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/25/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOMImageStore : NSObject

#ifdef __NUA__
// {
//     NSMutableDictionary *dictionary;
// }

+ (TOMImageStore *) sharedStore;

- (void) setImage:(UIImage *)i forKey:(NSString *)s;
- (BOOL) setImage:(UIImage *)i forKey:(NSString *)s save:(BOOL) yn;

- (UIImage *) imageForKey:(NSString *) s;

- (void) deleteImageForKey:(NSString *) s;
- (BOOL) deleteImageForKey:(NSString *) s remove:(BOOL) yn;
#endif

+ (NSString *) pathForImage:(NSString *)key;
+ (BOOL) saveImage:(UIImage *)i forKey:(NSString *)s;
+ (UIImage *) loadImage: (NSString *) s  warn:(BOOL) yn;
+ (BOOL) removeImage: (NSString *) s;

@end
