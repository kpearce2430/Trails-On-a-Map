//
//  TOMImageStore.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/25/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMImageStore.h"

@implementation TOMImageStore

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (TOMImageStore *) sharedStore
{
    static TOMImageStore *sharedStore = nil;
    
    if (!sharedStore)
    {
        // Create the singleton
        sharedStore = [[super allocWithZone:NULL] init];
    }
    return sharedStore;
}

-(id) init
{
    self = [super init];
    if (self) {
        dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

//
// setImage
//
-(BOOL) setImage:(UIImage *)i forKey:(NSString *)s save:(BOOL)yn
{
    [dictionary setObject:i  forKey:s];
    if (yn == YES)
    {
        return [self saveImage:i forKey:s];
    }
    else
        return YES;
}

-(void) setImage:(UIImage *)i forKey:(NSString *)s
{
    [dictionary setObject:i forKey:s];
}

-(UIImage *) imageForKey:(NSString *)s
{
    return [dictionary objectForKey:s];
}

//
// delete image methods
//
- (BOOL) deleteImageForKey:(NSString *)s remove:(BOOL)yn
{
    [self deleteImageForKey:s ];
    if (yn == YES)
        return [self removeImage:s];
    else
        return YES;
}

//

- (void) deleteImageForKey:(NSString *)s
{
    if (!s)
        return;
    else
        [dictionary removeObjectForKey:s];
}
//
// Functions for save and loading images
//
- (NSString *) pathForImage:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [ key stringByAppendingString:@".jpg"]; // future property
    
    NSLog( @"Image Filename:%@", fileName );
    
    // Get one and only one document directory
    NSString *documentDirectory = [ documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:fileName];
    
}

- (BOOL) saveImage:(UIImage *)i forKey:(NSString *)s
{
    // Here is code to save to the Documents directory on iOS that is from working code.
    
    // Convert UIImage to JPEG
    NSData *imgData = UIImageJPEGRepresentation(i, 1);
    
    // Identify the path
    NSString  *jpgPath = [self pathForImage: s];
    
    // Write the file.  Choose YES atomically to enforce an all or none write. Use the NO flag if partially written files are okay which can occur in cases of corruption
    return [imgData writeToFile:jpgPath atomically:YES];
    // return YES;
}

- (UIImage *) loadImage: (NSString *) s
{
    NSError *err = nil;
    // Identify the path
    NSString  *jpgPath = [self pathForImage: s];
    
    NSData *data = [NSData dataWithContentsOfFile:jpgPath
                                          options:NSDataReadingUncached
                                            error:&err];
    
    if (err) {
        NSLog(@"%@",err);
        return nil;
    }
    else {
        UIImage *img = [UIImage imageWithData:data];
        return img;
    }
}

- (BOOL) removeImage: (NSString *) s
{
    // Identify the path
    NSError *err = nil;
    NSString  *jpgPath = [self pathForImage: s];
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    
    BOOL removeSuccess = [fileMgr removeItemAtPath:jpgPath error:&err];
    
    if (err)
    {
        NSLog(@"%@",err);
        return NO;
    }
    return removeSuccess;
}


@end
