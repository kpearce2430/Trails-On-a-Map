//
//  TOMUrl.m
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 2/21/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import "TOMUrl.h"

@implementation TOMUrl

+ (NSURL *) urlForICloud {
    
    NSString *teamID = @TOM_TEAM_ID;
    NSString *containerID = [[NSBundle mainBundle] bundleIdentifier];
    NSString *teamIDandContainerID = [NSString stringWithFormat:@"%@.%@",teamID,containerID];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *theURL = [fileManager URLForUbiquityContainerIdentifier:teamIDandContainerID];
    return theURL;
}

+ (NSURL *) urlForICloudDocuments {
    
    NSURL *icloudURL = [self urlForICloud];
    NSURL *documentsFolderURLIniCloud = Nil;
    
    if (icloudURL) {
        documentsFolderURLIniCloud = [icloudURL URLByAppendingPathComponent:@"Documents" isDirectory:YES];
    }
    
    return documentsFolderURLIniCloud;
}

+ (BOOL) isIcloudAvailable {
    
    NSURL *theURL = [self urlForICloud];

    if (!theURL)
        return NO;
    else
        return YES;
}

+ (NSURL *) urlForDefaultDocuments {
    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsFolderURL = URLs[0];
    return documentsFolderURL;
}

+ (NSURL *) urlForDocumentsDirectory {
    
    static NSURL *result = nil;
    
    if  (result) {
        return result;
    }

    NSURL *theURL = [self urlForICloudDocuments];
    
    if (!theURL) {
        NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        theURL = URLs[0];
    }
 

    if (theURL) {
        
        if ([TOMUrl checkDirectory:theURL create:YES]) {
            result = theURL;
        }
    }
    
    return result;
}

+ (NSURL *) urlForImageFile:(NSString *) title key:(NSString *) key
{
    NSURL *imgDir = [TOMUrl urlForImageDirectory:title];
    NSURL *resultURL = nil;
    
    if (imgDir) {
        NSString *fileName = [key stringByAppendingString:@".jpg"];
        resultURL = [imgDir URLByAppendingPathComponent:fileName isDirectory:NO];
    }
    return resultURL;
}

+ (NSURL *) urlForImageDirectory:(NSString *) title
{

    return [TOMUrl urlForTrail:title];
    
#ifdef __FFU__
    //  Images are store in the trails subdirectory
    NSURL *imageURL = nil;
    
    NSURL *documentsURL = [self urlForDocumentsDirectory];
    
    if (documentsURL) {
        imageURL = [documentsURL URLByAppendingPathComponent:@"Images"];
        
        if ([TOMUrl checkDirectory:imageURL]) {
            return imageURL;
        }
    }
    return imageURL;
#endif
    
}

+ (NSURL *) urlForFile:(NSString *) title key:(NSString *) filename
{
    // No title, NO URL
    if (!title) {
        NSLog(@"ERROR: %s with empty title",__func__);
        return nil;
    }
    
    if (!filename) {
         NSLog(@"ERROR: %s with empty filename",__func__);
        return nil;
    }
    
    if ([title isEqualToString:@TRAILS_ON_A_MAP]) {
        return [TOMUrl urlForDocumentsDirectory];
    }

    // else,
    // Build up the URL
    NSURL *fileURL = nil;
    NSURL *trailURL = [TOMUrl urlForTrail:title];
    
    if  (trailURL) {
        NSString *newFileName = [title stringByAppendingString:@TOM_FILE_EXT];
        fileURL = [trailURL URLByAppendingPathComponent:newFileName];
    }
    

    return fileURL;
}

+ (NSURL *) urlForTrail:(NSString *)title
{
    // No title, NO URL
    if (!title) {
        return nil;
    }

    // The default name should not get here, so return nil
    if ([title isEqualToString:@TRAILS_ON_A_MAP]) {
        return nil;
    }

    // NSString *titlePath = [NSString stringWithFormat:@".%@",title];
    
    NSURL *documentsURL = [TOMUrl urlForDocumentsDirectory];
    NSURL *rootURL = [documentsURL URLByAppendingPathComponent:title isDirectory:YES];
    
    if ([TOMUrl checkDirectory:rootURL create:YES]) {
        return rootURL;
    }
    else
        return nil;
}

+ (BOOL) checkDirectory: (NSURL *) theURL create: (BOOL) yn
{
    // BOOL result = NO;
    
    if (theURL) {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        if ([fileManager fileExistsAtPath:[theURL path]] == NO ) {
            
            if (yn) {
                
                NSError *err;
                BOOL created = [fileManager createDirectoryAtURL:theURL withIntermediateDirectories:YES attributes:nil error:&err];
            
                if (created) {
                    // NSLog(@"%s: Successfully Created %@",__func__,theURL);
                    return YES;
                }
                else {
                    NSLog(@"%s: FAILED to create %@: %@",__func__,theURL, err);
                }
            }
        }
    else {
            // NSLog(@"%s: Folder %@ already exists",__func__,theURL);
            return YES;
        }
    }
    return NO;
}

@end
