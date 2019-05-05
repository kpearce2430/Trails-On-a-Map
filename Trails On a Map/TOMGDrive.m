//
//  TOMGDrive.m
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 4/12/15.
//  Copyright (c) 2015 Pearce Software Solutions. All rights reserved.
//

#ifdef __USE_GDRIVE__

#import "TOM.h"
#import "TOMGDrive.h"

@implementation TOMGDrive

@synthesize driveService;

- (id)initGDrive {
    self = [super init];
    if (self) {
        // Initialize the drive service & load existing credentials from the keychain if available
        driveService = [[GTLServiceDrive alloc] init];
        driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                        clientID:kClientID
                                                                                    clientSecret:kClientSecret];
    }
    return self;
}

- (BOOL) writeToGDrive: (NSString *) gdFileName mimeType: (NSString *) gdMimeType  data: (NSData *) d {
    
    if (!self.driveService || !self.driveService.authorizer ) {
        NSLog(@"ERROR %s %d drive service is nil",__PRETTY_FUNCTION__,__LINE__);
        return FALSE;
    }
    
    if (!self->drive_folder) {
        NSLog(@"ERROR %s drive folder not available",__PRETTY_FUNCTION__);
        return FALSE;
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"'on ('EEEE MMMM d, YYYY h:mm a, zzz')"];
    
    // NSData *metaData = nil;
    [self getFileContents:gdFileName];
    
    GTLDriveFile *file = [GTLDriveFile object];
    

    file.title = gdFileName;
    
    GTLDriveParentReference *parent = [GTLDriveParentReference object];
    parent.identifier = self->parent_identifier;
    // BOOL b = TRUE;
    // NSNumber *p = [[NSNumber alloc] initWithBool:b];
    //  q[parent setIsRoot: p];

    file.parents = @[parent]; // arron of 1
    
    file.descriptionProperty = [NSString stringWithFormat:@"Uploaded From %@ %@",@TRAILS_ON_A_MAP,[dateFormat stringFromDate:[NSDate date]]];
    file.mimeType = gdMimeType;
    
    NSData *data = d;
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:file.mimeType];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                       uploadParameters:uploadParameters];
    
    // UIAlertView *waitIndicator = [self showWaitIndicator:@"Uploading to Google Drive"];
    
    [self.driveService executeQuery:query
                  completionHandler:^(GTLServiceTicket *ticket,
                                      GTLDriveFile *insertedFile, NSError *error) {
                      // [waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
                      if (error == nil)
                      {
                          NSLog(@"File ID: %@", insertedFile.identifier);
                          // [self showAlert:@"Google Drive" message:@"File saved!"];
                      }
                      else
                      {
                          NSLog(@"An error occurred: %@", error);
                          // [self showAlert:@"Google Drive" message:@"Sorry, an error occurred!"];
                      }
                  }];
    
    return TRUE;
}

//
// * * * * * * * * * * * * * * * * * * *
//
// G Drive - Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
    [alert show];
}


// G Drive - Helper to check if user is authorized
- (BOOL)isAuthorized
{
    return [((GTMOAuth2Authentication *)self.driveService.authorizer) canAuthorize];
}

// G Drive Handle completion of the authorization process, and updates the Drive service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error
{
    if (error != nil)
    {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.driveService.authorizer = nil;
    }
    else
    {
        self.driveService.authorizer = authResult;
        [self trailsFolderExists];
        
    }
}

// G Drive Creates the auth controller for authorizing access to Google Drive.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDriveFile
                                                                clientID:kClientID
                                                            clientSecret:kClientSecret
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

#ifdef __NUA__
// G Drive Helper for showing a wait indicator in a popup
- (UIAlertView*)showWaitIndicator:(NSString *)title
{
    UIAlertView *progressAlert;
    progressAlert = [[UIAlertView alloc] initWithTitle:title
                                               message:@"Please wait..."
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil];
    [progressAlert show];
    
    UIActivityIndicatorView *activityView;
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.center = CGPointMake(progressAlert.bounds.size.width / 2,
                                      progressAlert.bounds.size.height - 45);
    
    [progressAlert addSubview:activityView];
    [activityView startAnimating];
    return progressAlert;
}

#endif

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

+ (NSString *) getPathName
{
    NSString *pathName = nil;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_GOOGLE_DRIVE_PATH] != nil)
    {
            pathName = [[NSString alloc ] initWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@KEY_GOOGLE_DRIVE_PATH]];
    }
    else {
        pathName = @TRAILS_DEFAULT_NAME;
    }
    
    return pathName;
}

+ (BOOL) isGDriveEnabled
{
    BOOL yn;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_GOOGLE_DRIVE_ENABLED] != nil)
    {
        yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_GOOGLE_DRIVE_ENABLED];
    }
    else {
        yn = NO; // Default is no until the user asks for it.
    }
    return  yn;
    
}

- (void) getFileContents:(NSString *)myTitle
{
    if (!self.driveService || !self.driveService.authorizer ) {
        NSLog(@"ERROR: %s %d driveService is nil",__PRETTY_FUNCTION__,__LINE__ );
        return ;
    }

    NSString *search = [NSString stringWithFormat:@"title = '%@' and trashed=false",myTitle];
    NSLog(@"search string: %@",search);
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.q = search;
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                  GTLDriveFileList *files,
                                                  NSError *error) {
        if (error == nil) {
            NSLog(@"Have results %lu",(unsigned long)[files.items count]);
            for (int i = 0 ; i < [files.items count]; i++) {
                GTLDriveFile *f = [files.items objectAtIndex:i];
                NSLog(@"Drive File %@ %@",f.title, f.identifier);
            }
            // Iterate over files.items array
            
        } else {
            NSLog(@"An error occurred: %@", error);
        }
    }];
    
    return;
}

// mimeType='application/vnd.google-apps.folder' and 'root' in parents and trashed=false
- (void) trailsFolderExists
{
    if (!self.driveService || !self.driveService.authorizer ) {
        NSLog(@"ERROR: %s %d driveService is nil",__PRETTY_FUNCTION__,__LINE__ );
        return ;
    }
    
    NSString *search = [NSString stringWithFormat:@"title = '%@' and mimeType='application/vnd.google-apps.folder' and 'root' in parents and trashed=false",[TOMGDrive getPathName]];
    NSLog(@"search string: %@",search);
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.q = search;
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLDriveFileList *files,
                                                              NSError *error) {
        if (error == nil) {
            NSLog(@"Have results %lu",(unsigned long)[files.items count]);
            if ([files.items count] == 0) {
                [self trailsFolderCreate];
            }
            else { // Iterate over files.items array
                for (int i = 0 ; i < [files.items count]; i++) {
                    GTLDriveFile *f = [files.items objectAtIndex:i];
                    NSLog(@"Drive File %@ %@",f.title, f.identifier);
                    self->drive_folder = TRUE;
                    self->parent_identifier = f.identifier;
                }
            }
        } else {
            NSLog(@"ERROR: %s An error occurred: %@", __PRETTY_FUNCTION__, error);
            self->drive_folder = FALSE;
        }
    }];
    
    return;
}

- (void) trailsFolderCreate
{
    if (!self.driveService || !self.driveService.authorizer ) {
        NSLog(@"ERROR: %s %d driveService is nil",__PRETTY_FUNCTION__,__LINE__ );
        return ;
    }
    
    
    GTLDriveFile *folder = [GTLDriveFile object];
    folder.title = [TOMGDrive getPathName];
    folder.mimeType = @"application/vnd.google-apps.folder";
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:folder uploadParameters:nil];
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                  GTLDriveFile *updatedFile,
                                                  NSError *error) {
        if (error == nil) {
            NSLog(@"Created folder");
            self->drive_folder = TRUE;
            NSLog(@"File ID: %@", updatedFile.identifier);
            self->parent_identifier = updatedFile.identifier;
        } else {
            NSLog(@"An error occurred: %@", error);
            self->drive_folder = FALSE;
        }
    }];

   
    return;
}
@end

#endif
