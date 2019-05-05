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
    // NSLog(@"Team ID: %@",teamID);
    // NSLog(@"Container ID: %@",containerID);
    NSLog(@"%s Team and Container ID: %@",__PRETTY_FUNCTION__,teamIDandContainerID);
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

+ (NSURL *) urlForICloudDrive {
    NSString *teamID = @TOM_ICLOUDDRIVE_ID;
    NSString *containerID = [[NSBundle mainBundle] bundleIdentifier];
    NSString *teamIDandContainerID = [NSString stringWithFormat:@"%@.%@",teamID,containerID];
    NSURL *documentsFolderURLIniCloud = Nil;
    
#ifdef DEBUG
    // NSLog(@"Team ID: %@",teamID);
    // NSLog(@"Container ID: %@",containerID);
    NSLog(@"%s Team and Container ID: %@",__PRETTY_FUNCTION__,teamIDandContainerID);
#endif
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *theURL = [fileManager URLForUbiquityContainerIdentifier:teamIDandContainerID];
    
    if (theURL)
        documentsFolderURLIniCloud = [theURL URLByAppendingPathComponent:@"Documents" isDirectory:YES];
    
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
        NSLog(@"ERROR: %s with empty title",__PRETTY_FUNCTION__);
        return nil;
    }
    
    if (!filename) {
         NSLog(@"ERROR: %s with empty filename",__PRETTY_FUNCTION__);
        return nil;
    }
    
    NSURL *fileURL = nil;
    
    if ([title isEqualToString:@TRAILS_ON_A_MAP]) {
        NSURL *tmpURL = [TOMUrl temporaryDir:nil];
        NSString *newFileName = [title stringByAppendingString:@TOM_FILE_EXT];
        fileURL = [tmpURL URLByAppendingPathComponent:newFileName isDirectory:NO];
        return fileURL;
    }

    // else,
    // Build up the URL

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

+ (BOOL) checkTrailExists:(NSString *) title {

    // No title, NO URL
    if (!title) {
        NSLog(@"ERROR: %s with empty title",__PRETTY_FUNCTION__);
        return NO;
    }
    
    // The default name should not get here, so return nil
    if ([title isEqualToString:@TRAILS_ON_A_MAP]) {
        return NO;
    }
    
    NSURL *documentsURL = [TOMUrl urlForDocumentsDirectory];
    NSURL *rootURL = [documentsURL URLByAppendingPathComponent:title isDirectory:YES];
    
    if ([TOMUrl checkDirectory:rootURL create:NO])
        return YES;
    // else
    return NO;
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
#ifdef DEBUG
                else {
                    NSLog(@"%s: FAILED to create %@: %@",__PRETTY_FUNCTION__,theURL, err);
                }
#endif
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
   
    if (err)
    {
        NSLog(@"%s ERROR: %@",__PRETTY_FUNCTION__ ,err);
        return NO;
    }
    else
        return removeSuccess;
}

+(BOOL) isValidURL:(NSURL *) theURL
{
    NSString *path = [theURL path];
    if (!path)
        return NO;
    
    return YES;
    
}

+ (BOOL) isUsingICloud {
    BOOL yn = NO;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_ICLOUD] != nil)
    {
        yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_ICLOUD];
    }
    else
        yn = NO;
    
    return yn;
}

#ifdef __SAMPLE__
- (IBAction)btnStoreTapped:(id)sender {
    // Let's get the root directory for storing the file on iCloud Drive
    [self rootDirectoryForICloud:^(NSURL *ubiquityURL) {
        NSLog(@"1. ubiquityURL = %@", ubiquityURL);
        if (ubiquityURL) {
            
            // We also need the 'local' URL to the file we want to store
            NSURL *localURL = [self localPathForResource:@"demo" ofType:@"pdf"];
            NSLog(@"2. localURL = %@", localURL);
            
            // Now, append the local filename to the ubiquityURL
            ubiquityURL = [ubiquityURL URLByAppendingPathComponent:localURL.lastPathComponent];
            NSLog(@"3. ubiquityURL = %@", ubiquityURL);
            
            // And finish up the 'store' action
            NSError *error;
            if (![[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:localURL destinationURL:ubiquityURL error:&error]) {
                NSLog(@"Error occurred: %@", error);
            }
        }
        else {
            NSLog(@"Could not retrieve a ubiquityURL");
        }
    }];
}
#endif

- (void)rootDirectoryForICloud:(void (^)(NSURL *))completionHandler {

#ifdef __FFU__
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#endif
        NSURL *rootDirectory = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil]URLByAppendingPathComponent:@"Documents"];
        
        if (rootDirectory) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:rootDirectory.path isDirectory:nil]) {
                NSLog(@"Create directory");
                [[NSFileManager defaultManager] createDirectoryAtURL:rootDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
#ifdef __FFU__
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(rootDirectory);
        });
    });
#endif
    
}

- (NSURL *)localPathForResource:(NSString *)resource ofType:(NSString *)type {
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *resourcePath = [[documentsDirectory stringByAppendingPathComponent:resource] stringByAppendingPathExtension:type];
    return [NSURL fileURLWithPath:resourcePath];
}

@end
