
//
//  TOMImageStore.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/25/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMImageStore.h"
#import "TOMUrl.h"

@implementation TOMImageStore

+ (BOOL) imageExists: (NSString *) title key:(NSString *) key warn:(BOOL) yn
{
    if (!key) {  // can't do anything without a key:
        NSLog(@"ERROR: %s %d:No Key Provided",__FUNCTION__,__LINE__);
        return NO;
    }
    
    if  (!title) {
        NSLog(@"ERROR: %s %d:No Title Provided",__FUNCTION__,__LINE__);
        return NO;
    }
    
    NSURL *imageURL = [TOMUrl urlForImageFile:title key:key];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    return [fileManager fileExistsAtPath:[imageURL path]];
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

+ (UIImage *) loadImage: (NSString *) title key:(NSString *) key warn:(BOOL) yn
{
    
    if (!key) {
        NSLog(@"ERROR: %s %d:No Key Provided",__FUNCTION__,__LINE__);
        return NULL;
    }
    
    if  (!title) {
        NSLog(@"ERROR: %s %d:No Title Provided",__FUNCTION__,__LINE__);
        return NO;
    }
    
    NSError *err = nil;
    
    NSURL *imageURL = [TOMUrl urlForImageFile:title key:key];
    
    NSData *data = [NSData dataWithContentsOfURL:imageURL
                                         options:NSDataReadingUncached
                                           error:&err];
    
    if (err) {
        if (yn == YES)
            NSLog(@"%s %@",__func__,err);
        
        return nil;
    }
    else {
        UIImage *img = [UIImage imageWithData:data];
        return img;
    }
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

+ (BOOL) removeImage:(NSString *) title key: (NSString *) key {
    
    if (!key) {
        NSLog(@"ERROR: %s %d No Key Provided",__FUNCTION__,__LINE__);
        return NO;
    }
    if  (!title) {
        NSLog(@"ERROR: %s %d:No Title Provided",__FUNCTION__,__LINE__);
        return NO;
    }
    
    BOOL removeSuccess = NO;
    // Identify the path
    NSError *err = nil;
    
    NSURL *imageURL = [TOMUrl urlForImageFile:title key:key];
    
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    
    removeSuccess = [fileMgr removeItemAtURL:imageURL error:&err];
    
    if (err)
    {
        NSLog(@"ERROR: %s %@",__func__,err);
        return NO;
    }
    else
        return removeSuccess;
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

+ (BOOL) saveImage:(UIImage *)i title:(NSString *) title key:(NSString *)key
{
    // Here is code to save to the Documents directory on iOS that is from working code.
    if (!key) {
        NSLog(@"ERROR: %s %d No Key Provided",__FUNCTION__,__LINE__);
        return NO;
    }
    if  (!title) {
        NSLog(@"ERROR: %s %d:No Title Provided",__FUNCTION__,__LINE__);
        return NO;
    }
    if (!i) {
        NSLog(@"ERROR: %s %d:No Image Provided",__FUNCTION__,__LINE__);
        return NO;
    }
    
    // Send if off:
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Convert UIImage to JPEG
        NSData *imgData = UIImageJPEGRepresentation(i, 1);
    
        // Identify the path
        NSURL *imageURL = [TOMUrl urlForImageFile:title key:key];
    
        // Write the file.  Choose YES atomically to enforce an all or none write. Use the NO flag if partially written files are okay which can occur in cases of corruption
        if ([imgData writeToURL:imageURL atomically:YES] == NO)
            NSLog(@"ERROR: %s writing to URL %@",__func__,imageURL);
    });
    
    return YES;
}

@end
