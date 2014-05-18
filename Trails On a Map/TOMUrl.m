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
    
#ifdef __DEBUG
    NSLog(@"Team ID: %@",teamID);
    NSLog(@"Container ID: %@",containerID);
    NSLog(@"Team and Container ID: %@",teamIDandContainerID);
#endif

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

+ (NSURL *) urlForLocalDocuments {
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
        NSString *thePath = [theURL path];
        if ([fileManager fileExistsAtPath:thePath] == NO ) {
            
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

+ (NSURL *) temporaryDir: (NSString *) ext
{
    NSURL *turl = nil;
    
    if (ext) {
        turl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:ext]];
    }
    else {
        turl = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    }
    
    return turl;
}

+ (BOOL) removeURL:(NSURL *)targetURL
{
    
    if (!targetURL) {
        NSLog(@"ERROR: %s %d No Key Provided",__PRETTY_FUNCTION__,__LINE__);
        return NO;
    }
 
    BOOL removeSuccess = NO;
    NSError *err = nil;
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if ([fileManager fileExistsAtPath:[targetURL path]] == YES )  {
        removeSuccess = [fileManager removeItemAtURL:targetURL error:&err];
    }
#ifdef DEBUG
    else {
        NSLog(@"%s Warning - No File at URL %@",__PRETTY_FUNCTION__,targetURL);
        // removeSuccess = NO;
    }
#endif
    
    if (err)
    {
        NSLog(@"%s ERROR: %@",__PRETTY_FUNCTION__ ,err);
        return NO;
    }
    else
        return removeSuccess;
}

@end
