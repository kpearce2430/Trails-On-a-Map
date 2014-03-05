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
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
       if ([fileManager fileExistsAtPath:[theURL path]] == NO ) {
                
       NSError *err;
                
       BOOL created = [fileManager createDirectoryAtURL:theURL withIntermediateDirectories:YES attributes:nil error:&err];
                
       if (created) {
            NSLog(@"%s: Successfully Created %@",__func__,theURL);
            result = theURL;
       }
       else {
            NSLog(@"%s: FAILED to create documents: %@",__func__,err);
            }
       }
    else {
        NSLog(@"%s: Documents folder %@ already exists",__func__,theURL);
        result = theURL;
        }
    }
    
    return result;
}


+ (NSURL *) fileUrlForTitle :(NSString *) title
{
    
    NSString *newFileName = [title stringByAppendingString:@TOM_FILE_EXT];
    NSURL *documentsURL = [TOMUrl urlForDocumentsDirectory];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:newFileName];
    return fileURL;
}
@end
