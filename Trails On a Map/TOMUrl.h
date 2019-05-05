//
//  TOMUrl.h
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 2/21/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TOM.h"

#ifndef TOM_TEAM_ID
#define TOM_TEAM_ID "HV9L49AFR8"
#endif

#ifndef TOM_ICLOUDDRIVE_ID
#define TOM_ICLOUDDRIVE_ID  "iCloud"
#endif

@interface TOMUrl : NSObject

+ (NSURL *) urlForDocumentsDirectory ;

+ (BOOL) isIcloudAvailable;

+ (NSURL *) urlForICloud;
+ (NSURL *) urlForICloudDocuments;
+ (NSURL *) urlForICloudDrive;
+ (NSURL *) urlForLocalDocuments;
+ (NSURL *) urlForImageDirectory :(NSString *) title;
+ (NSURL *) urlForImageFile:(NSString *) title key:(NSString *) key;
+ (NSURL *) urlForFile:(NSString *) title key:(NSString *) filename;
+ (NSURL *) urlForTrail:(NSString *) title;

+ (BOOL) checkTrailExists:(NSString *) title;
+ (BOOL) checkDirectory: (NSURL *) theURL create:(BOOL)yn;
+ (BOOL) removeURL:(NSURL *)targetURL;
+ (NSURL *) temporaryDir: (NSString *) ext;
+ (BOOL) isValidURL:(NSURL *) theURL;
+ (BOOL) isUsingICloud;

@end
