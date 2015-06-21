//
//  TOMGDrive.h
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 4/12/15.
//  Copyright (c) 2015 Pearce Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

static NSString *const kKeychainItemName = @"Trails On A Map";
static NSString *const kClientID = @"355021435130-k1d0dvd2qls3cqlms34t13lmddp3una4.apps.googleusercontent.com";
static NSString *const kClientSecret = @"BQodroqzqWbiz-wq6TYo7v4A";

@interface TOMGDrive : NSObject
{
    @private
    BOOL exists;
    BOOL drive_folder;
    NSString *parent_identifier;
}

@property (nonatomic, retain) GTLServiceDrive *driveService;

- (id) initGDrive;

- (BOOL)isAuthorized;

- (BOOL)writeToGDrive: (NSString *) gdFileName mimeType: (NSString *) gdMimeType  data: (NSData *) d ;

- (void)showAlert:(NSString *)title message:(NSString *)message;

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error;

- (GTMOAuth2ViewControllerTouch *)createAuthController;

// - (UIAlertView*)showWaitIndicator:(NSString *)title;

- (void) getFileContents:(NSString *)myFileURL;
+ (NSString *) getPathName;
+ (BOOL) isGDriveEnabled;

- (void) trailsFolderExists;

@end
