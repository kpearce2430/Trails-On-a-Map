//
//  TOMRootViewController.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/15/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//
// #import <AssetsLibrary/AssetsLibrary.h>
#import "TOMRootViewController.h"
#import "TOMPhotoAlbumViewController.h"
#import "TOMPropertyViewController.h"
#import "TOMOrganizerViewController.h"
#import "TOMSpeed.h"
#import "TOMDistance.h"
#import "TOMUrl.h"

@interface TOMRootViewController ()

@end

@implementation TOMRootViewController

@synthesize amiUpdatingLocation,locationManager, worldView, theTrail, currentHeading, myProperties, imagePicker, updatedTrail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //
        // Set up for reading keys off iCloud:
        // listen for key-value store changes externally from the cloud
        NSUbiquitousKeyValueStore *defaultStore ;
        //
        // Set up listening for any updates on the properties.
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateCloudItems:)
                                                     name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                   object:defaultStore];
        
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        
        //
        //
        // Create the bottons on the NAV Bar
        //  Right button first...
        //
        UIImage *buttonBackground = [UIImage imageNamed:@"settings.png"];
        UIButton *modalViewButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [modalViewButton addTarget:self
                            action:@selector(propertiesView:)
                  forControlEvents:UIControlEventTouchUpInside];
        [modalViewButton setImage:buttonBackground forState:UIControlStateNormal];
        [modalViewButton setImage:buttonBackground forState:UIControlStateSelected];
        
        UIBarButtonItem *modalBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:modalViewButton];
        self.navigationItem.rightBarButtonItem = modalBarButtonItem;
        
        // CGFloat screenWidth = screenRect.size.width;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = screenRect.size.height;
        CGFloat screenWidth = screenRect.size.width;
        
        //
        // Create location manager object
        //
        locationManager = [[ CLLocationManager alloc] init ];
        [locationManager setDelegate:self];
        
        // New for IOS7
        //  For future, need to allow user to pick.
        [locationManager setActivityType:CLActivityTypeOtherNavigation];
        
        // Build up the MKMapView
        CGRect mapRect = CGRectMake( 0.0, 0.0, screenWidth, (screenHeight - TOM_TOOL_BAR_HEIGHT ));
        worldView = [[MKMapView alloc] initWithFrame:mapRect];
        [self.view addSubview:worldView];
        
        
        
        // Note for all 4 subviews: Height and Width are reversed on the landscape view.
        // Build the OdoMeter View
        CGRect myOdoMeterPortraitRect = CGRectMake(0.0f, (screenHeight - TOM_ODOMETER_DEFAULT_PORTRAIT_Y),
                                                   screenWidth/2.0f, TOM_ODOMETER_DEFAULT_HIEGHT );
        CGRect myOdoMeterLandscapeRect = CGRectMake(0.0f, (screenWidth - TOM_ODOMETER_DEFAULT_LANDSCAPE_Y),
                                                    screenHeight - TOM_SPEEDOMETER_DEFAULT_WIDTH, TOM_ODOMETER_DEFAULT_HIEGHT);
        myOdoMeter = [[ TOMOdometer alloc] initWithFramePortrait:myOdoMeterPortraitRect Landscape:myOdoMeterLandscapeRect];
        [self.view addSubview:myOdoMeter];
        
        CGRect myTripTimerPortraitRect = CGRectMake(screenWidth/2.0f, (screenHeight - TOM_ODOMETER_DEFAULT_PORTRAIT_Y),
                                                    screenWidth/2.0f, TOM_ODOMETER_DEFAULT_HIEGHT);
        
        CGRect myTripTimerLandscapeRect = CGRectMake(screenHeight - TOM_SPEEDOMETER_DEFAULT_WIDTH, (screenWidth - TOM_ODOMETER_DEFAULT_LANDSCAPE_Y),
                                                     TOM_SPEEDOMETER_DEFAULT_WIDTH, TOM_ODOMETER_DEFAULT_HIEGHT);
        
        myTripTimer = [[ TOMTripTimer alloc] initWithFramePortrait:myTripTimerPortraitRect Landscape:myTripTimerLandscapeRect];
        [self.view addSubview:myTripTimer];
        
        // Build the SpeedOMeter View
        CGRect mySpeedOMeterPortraitRect = CGRectMake(0.0f, (screenHeight - TOM_SPEEDOMETER_DEFAULT_Y ),
                                                      screenWidth, TOM_SPEEDOMETER_DEFAULT_HEIGHT);
        
        
        CGRect mySpeedOMeterLandscapeRect = CGRectMake(screenHeight-TOM_SPEEDOMETER_DEFAULT_HEIGHT, (screenWidth - TOM_SLIDER_DEFAULT_Y),
                                                       TOM_SPEEDOMETER_DEFAULT_WIDTH, TOM_SLIDER_MAX_Y);
        
        mySpeedOMeter = [[TOMSpeedOMeter alloc] initWithFramePortrait:mySpeedOMeterPortraitRect Landscape:mySpeedOMeterLandscapeRect ];
        [self.view addSubview:mySpeedOMeter];

        // Build the Slider View
        CGRect mySliderPortraitRect = CGRectMake( 0.0f , (screenHeight - TOM_SLIDER_DEFAULT_Y),
                                                 screenWidth, TOM_SLIDER_MAX_Y );
        CGRect mySliderLandScapeRect = CGRectMake( 0.0f , (screenWidth - TOM_SLIDER_DEFAULT_Y),
                                                  screenHeight - TOM_SPEEDOMETER_DEFAULT_WIDTH, TOM_SLIDER_MAX_Y );
        mySlider = [[TOMViewSlider alloc] initWithFramePortrait:mySliderPortraitRect Landscape:mySliderLandScapeRect];
        [self.view addSubview:mySlider];

        // Build out the tool bar
        CGRect toolbarRect;
        toolbarRect.origin.y = screenHeight - TOM_TOOL_BAR_HEIGHT;
        toolbarRect.origin.x = 0;
        toolbarRect.size.height = TOM_TOOL_BAR_HEIGHT;
        toolbarRect.size.width = screenRect.size.width;
        
        toolbar = [[UIToolbar alloc] initWithFrame:toolbarRect ];
        toolbar.barStyle = UIBarStyleDefault;

        [toolbar setBackgroundImage:nil forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
        
        flexItem = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                     target:nil
                                     action:nil];

        cameraItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                       target:self
                                       action:@selector(takePicture:)];

        startStopItem = [[UIBarButtonItem alloc]
                                          initWithTitle:@TOM_ON_TEXT
                                          style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(startStop:)];

        organizerItem = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                          target:self
                                          action:@selector(organizeTrails:)];

        NSArray *items = [NSArray arrayWithObjects: cameraItem, flexItem, startStopItem, flexItem, organizerItem, nil];
        [toolbar setItems:items];
        [self.view addSubview:toolbar];

        //
        // Initialize the variables
        //
        // Title
        self.title = @TRAILS_ON_A_MAP;
        // Set up a blank document, other was parts of the map will not work.
        NSURL *fileURL = [TOMUrl urlForFile:self.title key:self.title];
        theTrail = [[TOMPomSet alloc] initWithFileURL:fileURL];
        myProperties = [[TOMProperties alloc]initWithTitle:@TRAILS_ON_A_MAP];
        [[NSUserDefaults standardUserDefaults] setValue:@TRAILS_ON_A_MAP forKey:@KEY_NAME];

        //  Wait for the user to start updating location
        amiUpdatingLocation = NO;
        
        // Create the image store
        // imageStore = [[TOMImageStore alloc] init];
        
        // Please note that I have not created theTrail or the properties.
        // It's an empty UIDocument until the user turns on the navigation or
        // Selections a file name.
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setCenter:CGPointMake(screenWidth/2.0, screenHeight/2.0)];
        [activityIndicator hidesWhenStopped];
        [self.view addSubview:activityIndicator];
        
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleTheView:)];
        // [pinchGesture setDelegate:self];
        [self.view addGestureRecognizer:pinchGesture];
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [longGesture setMinimumPressDuration:2.0];
        [longGesture setAllowableMovement:1000.0];
        [self.view addGestureRecognizer:longGesture];
        
        [self setUpdatedTrail:NO];
    }
    [self checkProperties];
    return self;
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // [worldView setShowsUserLocation:YES];
    // Request to turn on accelerometer and begin receiving accelerometer events
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

    BOOL yn = NO;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_ICLOUD] != nil)
    {
        yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_ICLOUD];
    }
    else
        yn = NO;
    
    if (yn == NO) {
        //
        // Previously, the app marked that iCloud was not available.
        // Let's check to see if it is:
        //
        if ([TOMUrl isIcloudAvailable]) {
            //
            // It is available,  let see if the user has saved off any documents in the
            // local directory and copy them to the iCloud.
            //
            // NSLog(@"%s : iCloud Document Available",__func__);
            yn = YES;
            [[NSUserDefaults standardUserDefaults] setBool:yn forKey:@KEY_ICLOUD];
            
            // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSURL *icloudURL = [TOMUrl urlForICloudDocuments];
            
            // Look for local files on the device's documents directory and copy them
            // to the iCloud.
            NSURL *defaultURL = [TOMUrl urlForLocalDocuments];
            
            NSArray *keys = [NSArray arrayWithObjects:
                             NSURLIsDirectoryKey, NSURLIsPackageKey, NSURLLocalizedNameKey, nil];
            
            NSFileManager *fileManager = [[NSFileManager alloc]init];
            
            NSDirectoryEnumerator *enumerator = [fileManager
                                                 enumeratorAtURL:defaultURL
                                                 includingPropertiesForKeys:keys
                                                 options:(NSDirectoryEnumerationSkipsPackageDescendants |
                                                          NSDirectoryEnumerationSkipsHiddenFiles)
                                                 errorHandler:^(NSURL *url, NSError *error) {
                                                     // Handle the error.
                                                     // Return YES if the enumeration should continue after the error.
                                                     return     YES;
                                                 }];
            
            for (NSURL *url in enumerator) {
                
                BOOL isDirectory;
                NSError *err = nil;
                NSLog(@"Source URL:%@",[url path]);
                
                BOOL fileExistsAtPath = [fileManager fileExistsAtPath:[url path] isDirectory:&isDirectory];
                if (fileExistsAtPath) {
                    NSString *path = [url path];
                    NSArray *parts = [path componentsSeparatedByString:@"/"];
                    NSString *trailName = [parts objectAtIndex:[parts count]-2]; // Trail Name if it's not a Directory
                    NSString *fileName = [parts objectAtIndex:[parts count]-1];
                    if (isDirectory)
                    {
                        //It's a Directory.
                        NSURL *destinationURL = [icloudURL URLByAppendingPathComponent:fileName isDirectory:YES];
                        if (![fileManager fileExistsAtPath:[destinationURL path]]) {
                            NSLog(@"Dest URL:%@",[destinationURL path]);
                            [fileManager copyItemAtURL:url toURL:destinationURL error:&err];
                            if (err) {
                                NSLog(@"%s : Error copy to icloud: %@",__func__,err);
                            }
                        }
                    }
                    else if ([fileName hasSuffix:@TOM_FILE_EXT] || [fileName hasSuffix:@TOM_JPG_EXT] ) {
                        NSURL *destinationDir = [icloudURL URLByAppendingPathComponent:trailName isDirectory:YES];
                        NSURL *destinationURL = [destinationDir URLByAppendingPathComponent:fileName isDirectory:NO];
                        
                        if (![fileManager fileExistsAtPath:[destinationURL path] isDirectory:NO]) {
                            NSLog(@"Dest URL:%@",[destinationURL path]);
                            [fileManager copyItemAtURL:url toURL:destinationURL error:&err];
                            if (err) {
                                NSLog(@"%s : Error copy to icloud: %@",__func__,err);
                            }
                        }
                    }
#ifdef __NUA__
                    // Not used anymore - KML,GPX, and CSV files will only be available in the
                    // local directory
                    else if ([fileName hasSuffix:@TOM_KML_EXT] || [fileName hasSuffix:@TOM_GPX_EXT] || [fileName hasSuffix:@TOM_CSV_EXT] ) {
                        // User Created Files remain on the device

                        NSURL *destinationURL = [icloudURL URLByAppendingPathComponent:fileName isDirectory:NO];
                        if (![fileManager fileExistsAtPath:[destinationURL path]]) {
                            NSLog(@"Dest URL:%@",[destinationURL path]);
                            [fileManager copyItemAtURL:url toURL:destinationURL error:&err];
                            if (err) {
                                NSLog(@"%s : Error copy to icloud: %@",__func__,err);
                            }
                        }
                    }
#endif
                    else {
                        NSLog(@"%s Skipping File: %@",__PRETTY_FUNCTION__,fileName);
                    }
                } // fileExistsAtPath
            }    // for NSURL
            // });
        }
    }  // if (y/n)
    //
    // iCloud was available, let see if it still is
    //
    else if (![TOMUrl isIcloudAvailable]) {
        //
        // The user has turned off iCloud.  Mark it in the properties
        // Any subsequent functions/methods will need to address this too.
        //
        yn = NO;
        [[NSUserDefaults standardUserDefaults] setBool:yn forKey:@KEY_ICLOUD];
    }
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
-(void) viewDidDisappear {
    // Request to stop receiving accelerometer events and turn off accelerometer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    // Need to close any open documents here:
    if (![self.title isEqualToString:@TRAILS_DEFAULT_NAME]) {
        // Save document
        // NSLog(@"%s Saving trails", __func__ );
        // NSURL *fileURL = [TOMUrl fileUrlForTitle:self.title];
        [self saveTrails: NO]; // we are done?
    }
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//

- (void) viewDidAppear:(BOOL)animated {
    
    //
    //  This will center the world view on my current location.
    CLLocation *userCoordinate = locationManager.location;
    [worldView setCenterCoordinate:userCoordinate.coordinate animated:YES];
    [worldView setShowsUserLocation:YES];
    
    //
    // Name
    //
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_NAME] != nil)
    {
        // NSString *newPath = NULL;
        NSString *newTitle = [[NSUserDefaults standardUserDefaults] stringForKey:@KEY_NAME];
        //
        // It's not the default name and it's not the same as the old name,
        // Let's load up the new name and start up.
        //
        if ([newTitle isEqualToString:self.title]) {
            // Do nothing
#ifdef DEBUG
            NSLog(@"%s INFO Did not change title[%@]",__func__,newTitle);
#endif
        }
        else if ([self.title isEqualToString:@TRAILS_DEFAULT_NAME]) {
            //
            // What to do if the current name is the Deafult.
            // and the user has picked a new name either from the
            // orgainizer viewer or the properties views (or any subsequent
            // view added in the future.
            //
            NSURL *fileURL = [TOMUrl urlForFile:newTitle key:newTitle];
            NSFileManager *fm = [NSFileManager new];
            if ([fm fileExistsAtPath:[fileURL path]]) {
                //
                // User picked to load an existing trail from the default name
                // Clear everything:
                //
                if (amiUpdatingLocation == YES) {
                    amiUpdatingLocation = NO;
                    startStopItem.title = @TOM_ON_TEXT;
                    [locationManager stopUpdatingLocation];
                    [locationManager stopUpdatingHeading];
                    [ptTimer invalidate]; // Stop the timer
                }
                [worldView removeAnnotations:theTrail.ptTrack];
                
                // Clear any remaining annotations.
                for (id<MKAnnotation> currentAnnotation in worldView.annotations) {
                    [worldView removeAnnotation:currentAnnotation];
                }
                

                if (!mapPoms) {
                    mapPoms = [[TOMMapSet alloc] init];
                }
                else {
                    [worldView removeOverlay:(id <MKOverlay>)mapPoms];
                    [mapPoms clearPoms];
                }
                
                //
                [self->worldView addOverlay:(id <MKOverlay>)mapPoms];
                
                [self setTitle:newTitle];
                [myProperties setPtName:newTitle];
                
                // and load the new trail
                theTrail = [[TOMPomSet alloc] initWithFileURL:fileURL];
                [self loadTrails:fileURL];
                [self processMyLocation:userCoordinate type:ptUnknown];
                [self setUpdatedTrail:NO];
                // [mySlider clearSpeedsAndAltitudes];
                // [myTripTimer setDuration:[theTrail elapseTime]];
                // [myOdoMeter setTotalDistance:[theTrail distanceTotalMeters]];
            }
            else { // no file exests at path:
                //    the points of the trail will be kept as the new name
                //    no action required.
                theTrail = [[TOMPomSet alloc] initWithFileURL:fileURL];
                myProperties = [[TOMProperties alloc]initWithTitle:newTitle];
                
                [self setTitle:newTitle];
                [self setUpdatedTrail:YES];
                [myProperties setPtName:newTitle];
            }
            //
        } // end if old title is default
        else { // old title was not the default name
            //
            //  Save off the old track             //
            if (amiUpdatingLocation == YES) {
                // NSLog(@"Saving[%@]",self.title);
                // NSURL *fileURL = [TOMUrl fileUrlForTitle:self.title];
                if ([self updatedTrail] == YES)
                    [self saveTrails: NO]; //
                amiUpdatingLocation = NO;
                startStopItem.title = @TOM_ON_TEXT;
                [locationManager stopUpdatingLocation];
                [locationManager stopUpdatingHeading];
                [ptTimer invalidate]; // Stop the timer
            }

            if ([self updatedTrail] == YES) {
                [theTrail closeWithCompletionHandler:nil];
            }
            //
            // Clean it up
            //
            [worldView removeAnnotations:theTrail.ptTrack];
            for (id<MKAnnotation> currentAnnotation in worldView.annotations) {
                [worldView removeAnnotation:currentAnnotation];
            }
            [worldView removeOverlay:(id <MKOverlay>)mapPoms];
            
            if (!mapPoms) {
                mapPoms = [[TOMMapSet alloc] init];
            }
            else
                [mapPoms clearPoms];
            
            [self->worldView addOverlay:(id <MKOverlay>)mapPoms];
            [mySlider clearSpeedsAndAltitudes];
            
            //  Load in the new one.
            NSURL *fileURL = [TOMUrl urlForFile:newTitle key:newTitle];
            theTrail = [[TOMPomSet alloc] initWithFileURL:fileURL];
            myProperties = [[TOMProperties alloc]initWithTitle:newTitle];
            [self setTitle:newTitle];
            [myProperties setPtName:newTitle];
            
            
            if  (![newTitle isEqual: @TRAILS_DEFAULT_NAME]) {
                NSFileManager *fm = [NSFileManager new];
                if ([fm fileExistsAtPath:[fileURL path]]) {
                    [self loadTrails:fileURL];
                }
            }
            else {
                [worldView setDelegate:self];
                [mySlider resetView];
                [mySlider clearSpeedsAndAltitudes];
                [mySlider setNeedsDisplay];
                
                [mySpeedOMeter resetSpeedOMeter];
                [mySpeedOMeter setNeedsDisplay];
                
                [myTripTimer setDuration:0.0f];
                [myTripTimer setNeedsDisplay];
                
                [myOdoMeter setTrailDistance:0.0f];
                [myOdoMeter setNeedsDisplay];
            }
            [self setUpdatedTrail:NO];
            // [myTripTimer setDuration:[theTrail elapseTime]];
        }
    }
    else
    {   //
        // we don't have a name stored,
        // set up up the default.
        //
        [self.myProperties setPtName:@TRAILS_DEFAULT_NAME];  // default
        [self setTitle:@TRAILS_DEFAULT_NAME];
        [mySlider clearSpeedsAndAltitudes];
    }
    
    //
    //  Check the properties
    [self checkProperties];
    
    // Update all the pins
    [self updateAnnotations];
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma gesture_methods

-(void) longPress:(UILongPressGestureRecognizer *)longPressRecognizer
{
    UIView *theView = [longPressRecognizer view];
    static TOMSubView *workingView = nil;
    
    if ([longPressRecognizer numberOfTouches] > 1) {
        NSLog(@"%s Warning multiple touches found",__PRETTY_FUNCTION__);
    }
    
    CGPoint locationOne = [longPressRecognizer locationOfTouch:0 inView:theView];
    
    if (workingView == nil) {
        if (CGRectContainsPoint(mySlider.frame, locationOne)) {
            workingView = mySlider;
        }
        else if (CGRectContainsPoint(mySpeedOMeter.frame, locationOne)) {
            workingView = mySpeedOMeter;
        }
        else if (CGRectContainsPoint(myOdoMeter.frame, locationOne)) {
            workingView = myOdoMeter;
        }
        else if (CGRectContainsPoint(myTripTimer.frame, locationOne)) {
            workingView = myTripTimer;
        }

        else {
            return;
        }
    }
        
    if (longPressRecognizer.state == UIGestureRecognizerStateEnded) {
        // NSLog(@"Long press Ended .................");
        workingView.center = locationOne;
        [workingView saveFrame: workingView.frame];
        workingView = nil;
    }
    else {
        // NSLog(@"Long press detected .....................");
        workingView.center = locationOne;
    }
}

// * * * * * * * * * * *

-(void) scaleTheView:(UIPinchGestureRecognizer *)pinchRecognizer
{
    UIView *theView = [pinchRecognizer view];
    
    static TOMSubView *workingView = nil;
    static CGPoint locationOne;
    static CGPoint locationTwo;
    
    if ([pinchRecognizer numberOfTouches] == 2 ) {
        @try {
            locationOne = [pinchRecognizer locationOfTouch:0 inView:theView];
            locationTwo = [pinchRecognizer locationOfTouch:1 inView:theView];
            // NSLog(@"%s touch ONE  = %f, %f",__PRETTY_FUNCTION__, locationOne.x, locationOne.y);
            // NSLog(@"%s touch TWO  = %f, %f",__PRETTY_FUNCTION__, locationTwo.x, locationTwo.y);
        }
        @catch (NSException *exception)
        {
            // Print exception information
            NSLog( @"%s NSException caught",__PRETTY_FUNCTION__ );
            NSLog( @"%s Name: %@", __PRETTY_FUNCTION__, exception.name);
            NSLog( @"%s Reason: %@",__PRETTY_FUNCTION__, exception.reason );
            return;
        }
#ifdef __DEBUG
        @finally {
            NSLog(@"%s Finally block",__PRETTY_FUNCTION__);
        }
#endif
    }
    else {
        //
        // NSLog(@"%s Warning Invalid Number of Touches: %ld",__PRETTY_FUNCTION__,(long)[pinchRecognizer numberOfTouches]);
        if (workingView == nil)
            return;
    }

    if (workingView == nil) {
        if (CGRectContainsPoint(mySlider.frame, locationOne) &&
            CGRectContainsPoint(mySlider.frame, locationTwo)) {
            workingView = mySlider;
        }
        else if (CGRectContainsPoint(mySpeedOMeter.frame, locationOne) &&
                 CGRectContainsPoint(mySpeedOMeter.frame, locationTwo)) {
            workingView = mySpeedOMeter;
        }
        else if (CGRectContainsPoint(myOdoMeter.frame, locationOne) &&
                 (CGRectContainsPoint(myOdoMeter.frame, locationTwo))) {
            workingView = myOdoMeter;
        }
        else if (CGRectContainsPoint(myTripTimer.frame, locationOne) &&
                 (CGRectContainsPoint(myTripTimer.frame, locationTwo))) {
            workingView = myTripTimer;
        }
        else {
            return;
        }
    }
    
    CGRect myFrame =  CGRectMake(MIN(locationOne.x, locationTwo.x),
                                 MIN(locationOne.y, locationTwo.y),
                                 fabs(locationOne.x - locationTwo.x),
                                 fabs(locationOne.y - locationTwo.y));
    
    if ([pinchRecognizer state] == UIGestureRecognizerStateBegan) {
        // NSLog(@"StateBegan");
        self.worldView.zoomEnabled = NO;
        self.worldView.scrollEnabled = NO;
        self.worldView.userInteractionEnabled = NO;
    }
    else if ([pinchRecognizer state] == UIGestureRecognizerStateChanged) {
         // NSLog(@"StateChanged");
        [workingView setFrame:myFrame];
        [workingView setNeedsDisplay];

    }
    else if ([pinchRecognizer state] == UIGestureRecognizerStateCancelled) {
        // NSLog(@"StateCancelled");
        self.worldView.zoomEnabled = YES;
        self.worldView.scrollEnabled = YES;
        self.worldView.userInteractionEnabled = YES;
    }
    else if ([pinchRecognizer state] == UIGestureRecognizerStateEnded )
    {
        // NSLog(@"StateEnded");
        if (workingView) {
            [workingView setFrame:myFrame];
            [workingView saveFrame:myFrame];
            [workingView setNeedsDisplay];
            [workingView resetView];
            workingView = nil;
        }
        
        self.worldView.zoomEnabled = YES;
        self.worldView.scrollEnabled = YES;
        self.worldView.userInteractionEnabled = YES;
    }
    else {
        NSLog(@"%s Warning - Unrecognized UIGestureRecognizer State: %ld",__PRETTY_FUNCTION__,(long)[pinchRecognizer state]);
    }
}

#pragma location_methods
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
//  Location Methods
//
//
-(void) processMyLocation: (CLLocation *)newLocation type: (POMType) pt
{

    CLLocationCoordinate2D coord = [ newLocation coordinate ];
    MKMapRect updateRect;
    MKCoordinateRegion region;
    
    
    if (pt != ptUnknown &&
        pt != ptError ) {
        TOMPointOnAMap *mp = [[TOMPointOnAMap alloc] initWithLocationHeadingType:newLocation heading:currentHeading type:pt];
        [ theTrail addPointOnMap:mp ];
        [ self setUpdatedTrail:YES];
        
        // [ mySlider setNeedsDisplay ];
        if ((pt == ptLocation && [self.myProperties showLocations]) ||
            (pt == ptStop && [self.myProperties showStops]) ||
            (pt == ptPicture && [self.myProperties showPictures])) {
            [worldView addAnnotation:(id)mp];
        }
    }
    
    if (!mapPoms) {
        mapPoms = [[TOMMapSet alloc] initWithCenterCoordinate:coord];
        [worldView setDelegate:self]; // This is key...
        [self->worldView addOverlay:(id <MKOverlay>)mapPoms];
    }
    else {
        // [mapPebbles addCoordinate:[newLocation coordinate]];

        if (pt != ptUnknown &&
            pt != ptError ) {
            updateRect = [mapPoms addCoordinate:coord];
        }
        else {
            updateRect = [mapPoms getMyMapRect:coord];
        }

        if (!MKMapRectIsNull(updateRect))
        {
            // There is a non null update rect.
            // Compute the currently visible map zoom scale
            
            MKZoomScale currentZoomScale = (CGFloat)(worldView.bounds.size.width / worldView.visibleMapRect.size.width);
            // Find out the line width at this zoom scale and outset the updateRect by that amount
            CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
            updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
            // Ask the overlay view to update just the changed area.
            [trailView setNeedsDisplayInMapRect:updateRect];
        }
    }

    // Zoom the region to this location

    if ([self.myProperties ptUserTrackingMode] == MKUserTrackingModeNone)
    {
        //
        // MKMapRect myMapRect = [theTrail updateMapRect];
        if (MKMapRectIsEmpty(updateRect)) {
            // NSLog(@"%s Still Empty",__PRETTY_FUNCTION__);
            region = MKCoordinateRegionMakeWithDistance(coord, 1000, 1000);
        }
        else  {
            // NSLog(@"Now We're talking");
            region = [theTrail ptMakeRegion];
            // [worldView setRegion:region animated:YES];
        }
    }
    else {
        region = MKCoordinateRegionMakeWithDistance(coord, 1000, 1000);
    }
    
    // MKCoordinateRegion region = [theTrail ptMakeRegion];
    [worldView setRegion:region animated:YES];

    
    // NSLog(@"Straight Line Distance %.2f" ,[pebbleTrack distanceStraightLine]);
    // NSLog(@"Total Distance %.2f", [pebbleTrack distanceTotalMeters]);
#ifdef __NUA__
    if ([myProperties showSpeedBar]) {
        NSString *speedDistance = [[NSString alloc] initWithFormat:@"SP: %.1f%@  T:%@",
                                    [TOMSpeed    displaySpeed:[newLocation speed]],[TOMSpeed displaySpeedUnits],
                                    [theTrail elapseTimeString]];

        [speedTimeBar setText:speedDistance];
    }
    
    if ([myProperties showInfoBar]) {
        // NSString *infoBarText = [[NSString alloc] initWithFormat:@"X:%.4f Y:%.4f T:%@ C:%lu", coord.latitude, coord.longitude,[theTrail elapseTimeString],(unsigned long)[theTrail.ptTrack count]];
        NSString *infoBarText = [[NSString alloc] initWithFormat:@"C:%lu Tot:%.1f%@ StrLine:%.1f%@",
                                  (unsigned long)[theTrail.ptTrack count],
                                  [TOMDistance displayDistance:[theTrail distanceTotalMeters]],[TOMDistance displayDistanceUnits],
                                  [TOMDistance displayDistance:[theTrail distanceStraightLine]],[TOMDistance displayDistanceUnits]];
        [distanceInfoBar setText:infoBarText];
    }
#endif
    
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// Did we get a heading update?
//
-(void) locationManager:(CLLocationManager *) manager
       didUpdateHeading:(CLHeading *)newHeading
{
    [self setCurrentHeading:newHeading];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *loc = [locations lastObject ];
    CLLocationDistance myDistance = 0.00f;
    
    [worldView setShowsUserLocation:YES];
  
    if (loc.speed < 0.00) {
        // NSLog(@"%s : Speed[%.2f] less than 0",__PRETTY_FUNCTION__,loc.speed);
        return;
    }

    TOMPointOnAMap *lastPoint = [theTrail lastPom];
    
    if (lastPoint) {
        //
        // Let's to an acceleration test to verify that
        // there wasn't a 'bump' or something else
        // that sent a number that is off.  It early version
        // I had a couple of values come in that went from a speed of
        // 70mph to 0mph to 100mph and then back to 70mph.  This is an attempt
        // skip these types of values.
        
        double deltaVel = [loc speed] - [lastPoint speed];
    
        NSTimeInterval t = [loc.timestamp timeIntervalSinceDate:[lastPoint timestamp]];
    
        double accelration = deltaVel / t;
#ifdef __DEBUG__
        NSLog(@"Acceleration %.2f - %.2f / %.2f = %.2f",[loc speed],[lastPoint speed],t,accelration);
#endif
        accelration = ABS(accelration);
        //
        // I'm using 10.0 because it's just a bit higher than some performance drag racers.
        //
        if (accelration > 10.0)
        {
            NSLog(@"Acceleration too high, returning");
            return;
        }
        myDistance = [lastPoint distanceFromLocation:loc];
    }
    
    if ( myDistance >= [TOMDistance distanceFilter] || !lastPoint) {
        
        [ self processMyLocation: loc type:ptLocation];
        
        [ myOdoMeter setTrailDistance:[theTrail distanceTotalMeters]];
        [ myOdoMeter setNeedsDisplay];
        
        [ myTripTimer setDuration:[theTrail elapseTime]];
        [ myTripTimer setNeedsDisplay];
        
        [ mySlider addSpeed:[loc speed] Altitude:[loc altitude] ];
        [ mySlider setNeedsDisplay];
        

    }
}

-(void) updateAnnotations
{
    // [worldView removeAnnotations:pebbleTrack.ptTrack];
    
    for (NSUInteger i = 0 ; i < [theTrail.ptTrack count]; i++)
    {
        TOMPointOnAMap *mp = [theTrail.ptTrack objectAtIndex:i];
        
        switch ([mp type]) {
            case ptLocation:
                if ([self.myProperties showLocations])
                    [worldView addAnnotation:(id)mp];
                else
                    [worldView removeAnnotation:(id)mp];
                break;
                
            case ptPicture:
                if ([self.myProperties showPictures])
                    [worldView addAnnotation:(id)mp];
                else
                    [worldView removeAnnotation:(id)mp];
                break;
                
            case ptStop:
                if ([self.myProperties showStops])
                    [worldView addAnnotation:(id)mp];
                else
                    [worldView removeAnnotation:(id)mp];
                break;
                
            case ptNote:
                if ([self.myProperties showNotes])
                    [worldView addAnnotation:(id)mp];
                else
                    [worldView removeAnnotation:(id)mp];
                break;
                
            case ptSound:
                if ([self.myProperties showSounds])
                    [worldView addAnnotation:(id)mp];
                else
                    [worldView removeAnnotation:(id)mp];
                break;
                
            default:
                NSLog(@"%s Error Unknown Pebble Type",__PRETTY_FUNCTION__);
                break;
        }
    }
}

//
//  This function is required for the overlay line.
//
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if (!trailView)
    {
        trailView = [[TOMTrackView alloc] initWithOverlay:overlay];
    }
    return trailView;
}

//
// * * * * * * * * * * * * * * * * * * * * * * * *
//
//  Timer Code
//
-(void)checkIfStopped:(NSTimer *)timer
{
    if  (amiUpdatingLocation == NO)
        return;
    
    CLLocation *stopLoc = [locationManager location];

    [mySpeedOMeter updateSpeed:[stopLoc speed]];
    [mySpeedOMeter setNeedsDisplay];

     // Still Moving...
    if  ([stopLoc speed] != 0.0) {
        // NSLog(@"Moving %.2f",[stopLoc speed]);
        return;
    }

    //
    // Figure out how far since the last location
    //
    TOMPointOnAMap *lastOne = [theTrail lastPom];
    if (!lastOne) { // or the first location:
        [self processMyLocation:stopLoc type:ptStop];
    }
    else if ([lastOne type] != ptStop )
    {
        CLLocationDistance myDist = [lastOne distanceFromLocation:stopLoc];
        // NSLog(@"Distance: %.2f",myDist);
        if  (myDist > 0.0) {
            [self processMyLocation:stopLoc type:ptStop];
            [mySlider addSpeed:[stopLoc speed] Altitude:[stopLoc altitude]];
            [mySlider setNeedsDisplay];
            [myOdoMeter setTrailDistance:[theTrail distanceTotalMeters]];
            [myOdoMeter setNeedsDisplay];
            [myTripTimer setDuration:[theTrail elapseTime]];
            [myTripTimer setNeedsDisplay];
        }
    }
    return;
}

#pragma actions_pragma

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Bring up the Property View Controller
//
-(IBAction)propertiesView:(id)sender
{
    
    UIViewController *ptController = [[TOMPropertyViewController alloc] initWithNibName:@"TOMPropertyViewController" bundle:nil];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    [[self navigationController] pushViewController:ptController animated:YES];

}

//
//
// * * * * * * * * * * * * * * * * * * * * * * * *
//
- (IBAction)startStop:(id)sender
{
    // NSLog(@"In startStop");
    UIBarButtonItem *startStopBarButton = (UIBarButtonItem *)sender;
    static NSDateFormatter *dateFormatter = nil;
    
    if (amiUpdatingLocation == NO)
    {
        // Start updating the location:
        // NSLog(@TOM_ON_TEXT);
        amiUpdatingLocation = YES;
        startStopBarButton.title = @TOM_OFF_TEXT;
        // [activityIndicator startAnimating];
        
        if ([self.title isEqual: @TRAILS_DEFAULT_NAME]) {
            //
            // At this point the user has left the default name and
            // turned on the collection of points.  The new name
            // will be the default name with the time appended on to it.
            //
            NSDate* now = [NSDate date];
            
            if (!dateFormatter) {
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            }
            
            NSString *dateStr = [dateFormatter stringFromDate:now];
            NSString *nameStr = [NSString stringWithFormat:@"Trail %@",dateStr];
            self.title = nameStr ;
            [[NSUserDefaults standardUserDefaults] setValue:nameStr forKey:@KEY_NAME];
            
            NSURL *fileURL = [TOMUrl urlForFile:nameStr key:nameStr];

            theTrail = [[TOMPomSet alloc] initWithFileURL:fileURL];
            myProperties = [[TOMProperties alloc]initWithTitle:nameStr];
            [self checkProperties];
        }
        
        [worldView setDelegate:self];
        [locationManager startUpdatingLocation];
        [locationManager startUpdatingHeading];
        
        // Start The Timer...
        if (![ptTimer isValid])
            ptTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(checkIfStopped:) userInfo:nil repeats:YES];
    }
    else
    {
        // Stop updating the location
        NSString *alertTitle = @"Are you sure you want to turn off?";
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:alertTitle
                                                                 delegate:self
                                                        cancelButtonTitle:@"NO"
                                                   destructiveButtonTitle:@"YES"
                                                        otherButtonTitles:nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        
        [actionSheet setTag:3];
        
        // [actionSheet setDelegate:self];
        [actionSheet showInView:self.view];
    }

    return;
}

-(void) stopTrail
{
    // add this last location:
    //
    CLLocation     *stopLoc = [locationManager location];
    TOMPointOnAMap *lastOne = [theTrail lastPom];
    if (!lastOne) { // or the first location:
        [self processMyLocation:stopLoc type:ptStop];
    }
    else if ([lastOne type] != ptStop ) {
        [self processMyLocation:stopLoc type:ptStop];
    }
    
    // NSLog(@TOM_OFF_TEXT);
    amiUpdatingLocation = NO;;
    startStopItem.title = @TOM_ON_TEXT;
    
    // Stop the timer
    [ptTimer invalidate];
    
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    
    if ([self updatedTrail] == YES)
        [self saveTrails:NO];
}

//
// Camera code.........................................................................
//
-(IBAction)takePicture:(id)sender
{
    // NSLog(@"In takePicture");
#ifdef __FFU__
    if (!imagePicker)
        imagePicker = [[UIImagePickerController alloc] init];


    // NOTE:  I need more time with picking photos out
    // of the photo library.   It's going to have to be a future
    // release becuase I want to get this out.  The following code will be used later
    // to allow the user to pick from the photo libraries.  Until then, only allow the user to
    // take pictures with the camera
    //
    //
    // If our device has a camera, we want to take a picture, otherwise, we
    // just pick from the photo library
    //
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] )
    {
        // Let the user decide which they want
        UIActionSheet *cameraActions  = [[UIActionSheet alloc]
                                      initWithTitle:@"Pick Source"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Camera", @"Photo Library", nil];
        [cameraActions showFromToolbar:toolbar];
        [cameraActions showInView:self.view];
        [cameraActions setTag:2];


    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self launchCamera];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        [self launchPhotoLibrary]; // [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary  ];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        [self launchPhotoLibrary]; // [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
    else {
        NSLog(@"ERROR: No Image Source Available");
        return;
    }
#else 
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
        imagePicker = [[UIImagePickerController alloc] init];
        [self launchCamera];
    }
#endif
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // NSLog(@"Button Index:%ld",(long)buttonIndex);
    NSInteger myTag = [actionSheet tag];
    
    if (myTag == 3) {
        // This is the actions for the iCloud check
        
        if (buttonIndex == 0 ) {
            // NSLog(@"User Selected to go to setting to STOP");
            [self stopTrail];
        }
        return;
    }
#ifdef DEBUG
    else {
        switch (buttonIndex)
        {
            case 0: // Launch Camera
                [self launchCamera];
            break;
            case 1: // Launch Photo Library
                // FFU: case 2: // Saved Photos Album
                [self launchPhotoLibrary];
            break;
        }
    }
#endif
}

- (void) launchCamera
{
    if  (!imagePicker)
        imagePicker = [[UIImagePickerController alloc] init];
    
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePicker setShowsCameraControls:YES];
    [imagePicker setAllowsEditing:YES];
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

- (void) launchPhotoLibrary
{
    UIViewController *ptController = [[TOMPhotoAlbumViewController alloc] initWithNibName:@"TOMPhotoAlbumViewController" bundle:nil ];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    [[self navigationController] pushViewController:ptController animated:YES];
}

// * * * * * *
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CLLocation *imageloc = [locationManager location];
    CLHeading *imagehdng = [locationManager heading];
    
    TOMPointOnAMap *imagePebble = [[TOMPointOnAMap alloc] initWithImage: image location:imageloc heading: imagehdng];
    [theTrail addPointOnMap:imagePebble];
    [TOMImageStore saveImage:image title:self.title key:[imagePebble key]];

    if (![self.title isEqual: @TRAILS_DEFAULT_NAME] &&
         [theTrail numPics] == 1) {
        // This is the first image, save off an icon
        CGSize destinationSize = CGSizeMake(120.0f, 120.0f);
        UIGraphicsBeginImageContext(destinationSize);
        [image drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        NSString *filename = [NSString stringWithFormat:@"%@.icon",self.title];
        [TOMImageStore saveImage:newImage title:self.title key:filename];
        imagePebble.isTrailIcon=YES;
    }
    else {
        imagePebble.isTrailIcon=NO;
    }
    
    // add a parameter to save to album or
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        UIImageWriteToSavedPhotosAlbum( image, nil, nil, nil );
    
    // Zoom the region to this location
    [worldView addAnnotation:(id)imagePebble];
    
    // Good place to mark the file to save it.
    // NSURL *fileURL = [TOMUrl fileUrlForTitle:self.title];
    if ([self updatedTrail] == YES)
        [self saveTrails:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


//
// * * * * * * * * * * * * * * * * * * * * * * * *
//
-(IBAction)organizeTrails:(id)sender
{
    if (![self.title isEqual: @TRAILS_DEFAULT_NAME]   ) {
        // NSURL *fileURL = [TOMUrl fileUrlForTitle:self.title];
        if ([self updatedTrail] == YES)
            [self saveTrails:NO];
    }
    
    UIViewController *ptController = [[TOMOrganizerViewController alloc] initWithNibName:@"TOMOrganizerViewController" bundle:nil ];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    [[self navigationController] pushViewController:ptController animated:YES];
    
    return;
}

#pragma file_section
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//  Wrapper functions to load and save the data.
//
- (BOOL) loadTrails:(NSURL *) fileURL
{
    BOOL result = NO;
    
    [activityIndicator startAnimating];
    //
    //
    if ([theTrail loadFromContents:fileURL ofType:nil error:nil]== YES)
    {
        //
        // Check to see if the other objects like pictures are there
        // I removed this since it is possible to load the trail stored
        // in the icloud where the picture doesn't exists yet.


        if (!mapPoms) {
            mapPoms = [[TOMMapSet alloc] init];
        }

        [mapPoms loadFromPoms:theTrail];
        [self updateAnnotations];
    
        if  ([mapPoms pointCount] > 0 )
             [worldView addOverlay:(id <MKOverlay>)mapPoms];

        [worldView setDelegate:self];
        
        [mySlider resetView];
        [mySlider clearSpeedsAndAltitudes];
        [mySpeedOMeter resetSpeedOMeter];
        for (int i = 0 ; i < [theTrail.ptTrack count]; i++)
        {
            TOMPointOnAMap *mp = [theTrail.ptTrack objectAtIndex:i];
            
            if ([mp type] == ptLocation) {
                [mySpeedOMeter  updateSpeed:[mp speed]];
                [mySlider addSpeed:[mp speed] Altitude:[mp altitude]];
            }
        }
        
        [mySlider setNeedsDisplay];
        [mySpeedOMeter setNeedsDisplay];
        
        [myTripTimer setDuration:[theTrail elapseTime]];
        [myTripTimer setNeedsDisplay];
        
        [myOdoMeter setTrailDistance:[theTrail distanceTotalMeters]];
        [myOdoMeter setNeedsDisplay];
        
        
        result = YES;
    }
    
    [activityIndicator stopAnimating];
    
    return result;
}

//
//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
- (BOOL) saveTrailAs: (NSString *) newTitle warn:(BOOL)yn{

    BOOL result = NO;
    NSURL *fileURL = [TOMUrl urlForFile:newTitle key:newTitle];

    [activityIndicator startAnimating];
    
    if (yn == YES) {
        // This is just an update - the user has gone off
        // to do something else and it's a good time to push
        // any updates to the file
        [theTrail updateChangeCount:UIDocumentChangeDone];
        result = YES;
    }
    else {
        [theTrail saveToURL:fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:nil];
        result = YES;
    }
    
    [activityIndicator stopAnimating];
    
    return result;
}

-(BOOL) saveTrails: (BOOL) yn
{
    BOOL result = NO;
    NSURL *fileURL = [TOMUrl urlForFile:self.title key:self.title];
    // NSLog(@"savePebbleTracks:[%@]",title);
    [activityIndicator startAnimating];
    
    if (yn == YES) {
        // This is just an update - the user has gone off
        // to do something else and it's a good time to push
        // any updates to the file
        [theTrail updateChangeCount:UIDocumentChangeDone];
        result = YES;
    }
    else {
        [theTrail saveToURL:fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:nil];
        result = YES;
    }

    [activityIndicator stopAnimating];
    
    return result;
}


//
// * * * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * * * * * * * * * * * * * * * *
//
- (void)orientationChanged:(NSNotification *)notification {
    // Respond to changes in device orientation
    //  NSLog(@"Orientation Changed!");
    static UIDeviceOrientation currentOrientation = UIDeviceOrientationUnknown;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationFaceUp ||
        orientation == UIDeviceOrientationFaceDown ||
        orientation == UIDeviceOrientationUnknown ||
        orientation == UIDeviceOrientationPortraitUpsideDown ||
        currentOrientation == orientation) {
        return;
    }
    
    if ((UIDeviceOrientationIsPortrait(currentOrientation) && UIDeviceOrientationIsPortrait(orientation)) ||
        (UIDeviceOrientationIsLandscape(currentOrientation) && UIDeviceOrientationIsLandscape(orientation))) {
        //still saving the current orientation
        currentOrientation = orientation;
        return;
    }

    currentOrientation = orientation;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    // CGFloat sliderMaxY = TOM_SLIDER_MAX_Y_VERT;
    if (UIDeviceOrientationIsLandscape(currentOrientation)  ||
        currentOrientation == UIDeviceOrientationPortraitUpsideDown ) {
        screenHeight = screenRect.size.width;
        screenWidth = screenRect.size.height;
        // sliderMaxY = TOM_SLIDER_MAX_Y_HORZ;
    }


    [self.view setFrame:screenRect];
    CGRect mapRect = CGRectMake( 0.0, 0.0, screenWidth, (screenHeight - TOM_TOOL_BAR_HEIGHT ));
    [worldView setFrame:mapRect];

    // Note:  When I did this inside the TOMSubView class, it seemed to have unpredictable resultes.
    CGRect sliderRect = [mySlider getFrame];
    [mySlider setFrame:sliderRect];
    [mySlider setNeedsDisplay];

    // See note with mySlider
    CGRect speedOMeterRect = [mySpeedOMeter getFrame];
    [mySpeedOMeter setFrame:speedOMeterRect];
    [mySpeedOMeter setNeedsDisplay];
    
    CGRect odoMeterRect = [myOdoMeter getFrame];
    [myOdoMeter setFrame:odoMeterRect];
    [myOdoMeter setNeedsDisplay];

    CGRect tripMeterRect = [myTripTimer getFrame];
    [myTripTimer setFrame:tripMeterRect];
    [myTripTimer setNeedsDisplay];
    
    CGRect toolbarRect;
    toolbarRect.origin.x = 0;
    toolbarRect.origin.y = screenHeight - TOM_TOOL_BAR_HEIGHT;
    toolbarRect.size.height = TOM_TOOL_BAR_HEIGHT;
    toolbarRect.size.width = screenWidth;
    [toolbar setFrame:toolbarRect];
}

#pragma properties

- (void) checkProperties
{
    //
    //  Check the properties
    //
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_MAP_TYPE] != nil)
    {
        [self.myProperties setPtMapType:[[NSUserDefaults standardUserDefaults] integerForKey:@KEY_MAP_TYPE]];
    }
    else
    {
        // we don't have a color preference stored on this device,
        // use the default value in this case (white)
        //
        [self.myProperties setPtMapType:MKMapTypeStandard];  // default
    }
    [worldView setMapType:[self.myProperties ptMapType]];
    
    //
    // User Tracking Mode
    //
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_USER_TRACKING_MODE] != nil)
    {
        [self.myProperties setPtUserTrackingMode:[[NSUserDefaults standardUserDefaults] integerForKey:@KEY_USER_TRACKING_MODE]];
    }
    else
    {
        // we don't have a color preference stored on this device,
        // use the default value in this case (white)
        //
        [self.myProperties setPtUserTrackingMode:MKUserTrackingModeNone];  // default
    }
    [worldView setUserTrackingMode:[self.myProperties ptUserTrackingMode] animated:YES];
    
    //
    // Location Accuracy
    //
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_LOCATION_ACCURACY] != nil)
    {
        [self.myProperties setPtLocationAccuracy:[[NSUserDefaults standardUserDefaults] floatForKey:@KEY_LOCATION_ACCURACY]];
    }
    else
    {
        // we don't have a preference stored on this device,
        // use the default value in this case (kCLLocationAccuracyBest)
        //
        [self.myProperties setPtLocationAccuracy:kCLLocationAccuracyBest];  // default
    }
    [locationManager setDesiredAccuracy:[self.myProperties ptLocationAccuracy]];
    
    //
    // Distance Filter
    //
    [locationManager setDistanceFilter:1.0];
    
    // Hoping to improve performance here ...
    if ((myProperties.ptLocationAccuracy == kCLLocationAccuracyBest) ||
        (myProperties.ptLocationAccuracy == kCLLocationAccuracyBestForNavigation)) {
        NSTimeInterval myTimeout = 5.0;
        [locationManager allowDeferredLocationUpdatesUntilTraveled:[myProperties ptDistanceFilter] timeout:myTimeout];
    }
    else
        [locationManager disallowDeferredLocationUpdates];
    
    //
    // Toggle buttons
    //
    // LOCATIONS
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SHOW_LOCATIONS] != nil)
    {
        [self.myProperties setShowLocations:[[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SHOW_LOCATIONS]];
    }
    else
    {
        // we don't have a preference stored on this device,
        // use the default value in this case (YES)
        //
        [self.myProperties setShowLocations:YES];  // default
    }
    
    // Pictures
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SHOW_PICTURES] != nil)
    {
        [self.myProperties setShowPictures:[[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SHOW_PICTURES]];
    }
    else
    {
        // we don't have a preference stored on this device,
        // use the default value in this case (YES)
        //
        [self.myProperties setShowPictures:YES];  // default
    }
    
    // STOPS
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SHOW_STOPS] != nil)
    {
        [self.myProperties setShowStops:[[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SHOW_STOPS]];
    }
    else
    {
        // we don't have a preference stored on this device,
        // use the default value in this case (YES)
        //
        [self.myProperties setShowStops:YES];  // default
    }
    
    // NOTES
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SHOW_NOTES] != nil)
    {
        [self.myProperties setShowNotes:[[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SHOW_NOTES]];
    }
    else
    {
        // we don't have a preference stored on this device,
        // use the default value in this case (YES)
        //
        [self.myProperties setShowNotes:YES];  // default
    }
    
    // Sounds (or Movies)
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SHOW_SOUNDS] != nil)
    {
        [self.myProperties setShowSounds:[[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SHOW_SOUNDS]];
    }
    else
    {
        // we don't have a preference stored on this device,
        // use the default value in this case (YES)
        //
        [self.myProperties setShowSounds:YES];  // default
    }

    // @KEY_ODOMETER
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_ODOMETER] != nil)
    {
        [self.myProperties setShowOdoMeter:[[NSUserDefaults standardUserDefaults] boolForKey:@KEY_ODOMETER]];
    }
    else
    {   // we don't have a preference stored on this device,
        // use the default value in this case (YES)
        //
        [self.myProperties setShowOdoMeter:YES];  // default
    }

    // Trigger the display
    if ([self.myProperties showOdoMeter]) {
        [myOdoMeter setHidden:NO];
    }
    else
        [myOdoMeter setHidden:YES];
    
    
    // @KEY_TRIPMETER
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_TRIPMETER] != nil)
    {
        [self.myProperties setShowTripMeter:[[NSUserDefaults standardUserDefaults] boolForKey:@KEY_TRIPMETER]];
    }
    else
    {
        // we don't have a preference stored on this device,
        // use the default value in this case (YES)
        //
        [self.myProperties setShowTripMeter:YES];  // default
    }
    
    // Trigger the display
    if ([self.myProperties showTripMeter]) {
        [myTripTimer setHidden:NO];

    }
    else {
        [myTripTimer setHidden:YES];
    }

    // @KEY_SLIDER
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SLIDER] != nil)
    {
        [self.myProperties setShowSlider:[[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SLIDER]];
    }
    else
    {
        // we don't have a preference stored on this device,
        // use the default value in this case (YES)
        //
        [self.myProperties setShowSlider:YES];  // default
    }
    
    // Trigger the display
    if ([self.myProperties showSlider]) {
        [mySlider setHidden:NO];
        
    }
    else {
        [mySlider setHidden:YES];
    }
    
    // @KEY_SPEEDOMETER
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SPEEDOMETER] != nil)
    {
        [self.myProperties setShowSpeedOMeter:[[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SPEEDOMETER]];
    }
    else
    {
        // we don't have a preference stored on this device,
        // use the default value in this case (YES)
        //
        [self.myProperties setShowSpeedOMeter:YES];  // default
    }
    
    // Trigger the display
    if ([self.myProperties showSpeedOMeter]) {
        [mySpeedOMeter setHidden:NO];
        
    }
    else {
        [mySpeedOMeter setHidden:YES];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_DISTANCE_FILTER] != nil)
    {
        [self.myProperties setPtDistanceFilter:[[NSUserDefaults standardUserDefaults] floatForKey:@KEY_DISTANCE_FILTER]];
    }
    else
    {   //
        // we don't have a preference stored on this device,use the kCLLocationAccuracyBest as default.
        //
        [self.myProperties setPtDistanceFilter:100.0];  // default
    }
    
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
//  This method is called when the key-value store in the cloud has changed externally.
//  The old color value is replaced with the new one
//  Additionally, NSUserDefaults is updated and the table is reloaded.
//
- (void)updateCloudItems:(NSNotification *)notification
{
    // We get more information from the notification, by using:
    //  NSUbiquitousKeyValueStoreChangeReasonKey or NSUbiquitousKeyValueStoreChangedKeysKey constants
    // against the notification's useInfo.
	//
    NSString *tmp = nil;
    
    NSDictionary *userInfo = [notification userInfo];
    // get the reason (initial download, external change or quota violation change)
    
    NSNumber* reasonForChange = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    if (reasonForChange)
    {
        // reason was deduced, go ahead and check for the change
        //
        NSInteger reason = [[userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey] integerValue];
        //---> NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
        // the value changed from the remote server
        // initial syncs happen the first time the device is synced
        if (reason == NSUbiquitousKeyValueStoreServerChange ||
            reason == NSUbiquitousKeyValueStoreInitialSyncChange)
            
        {
            NSArray *changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
            
            // in case you have more than one key,
            // loop through and check for the one we want (kBackgroundColorKey)
            //
            for (NSString *changedKey in changedKeys)
            {
                //
                tmp = [[NSUbiquitousKeyValueStore defaultStore] objectForKey:changedKey];
                // NSLog(@"%s: %@:%@",__func__,changedKey,tmp);
                // These are all stored as numbers
                if ([changedKey isEqualToString:@KEY_MAP_TYPE]              ||
                    [changedKey isEqualToString:@KEY_USER_TRACKING_MODE]    ||
                    [changedKey isEqualToString:@KEY_LOCATION_ACCURACY]     ||
                    [changedKey isEqualToString:@KEY_DISTANCE_FILTER]       ||
                    [changedKey isEqualToString:@KEY_DISTANCE_UNITS]        ||
                    [changedKey isEqualToString:@KEY_SPEED_UNITS]          )
                {
                    NSInteger i = [tmp integerValue];
                    [[NSUserDefaults standardUserDefaults] setInteger:i forKey:changedKey];
                }
                //
                // The remaining are YES/NO
                else {
                    if ([tmp isEqualToString:@"YES"])
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:changedKey];
                    else
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:changedKey];
                }
            }
        }
    }
    return;
}


@end
