//
//  TOMUrl.h
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 2/21/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TOM.h"

#define TOM_TEAM_ID "HV9L49AFR8.com.pearcesoftwaresolutions.trailsonamap"

@interface TOMUrl : NSObject

+ (NSURL *) urlForDocumentsDirectory ;
+ (NSURL *) fileUrlForTitle :(NSString *) title;
+ (BOOL) isIcloudAvailable;
+ (NSURL *) urlForICloud;
+ (NSURL *) urlForICloudDocuments;
+ (NSURL *) urlForDefaultDocuments;

@end
