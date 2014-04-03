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

@synthesize amiUpdatingLocation,locationManager, worldView, theTrail, currentHeading, myProperties, imagePicker;

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
        
        CGRect mySpeedOMeterRect = CGRectMake(0.0f, (screenHeight - TOM_TOOL_BAR_HEIGHT - TOM_SLIDER_MAX_Y - 200 ), TOM_SLIDER_MIN_X, 200);
        mySpeedOMeter = [[TOMSpeedOMeter alloc] initWithFrame:mySpeedOMeterRect];
        [self.view addSubview:mySpeedOMeter];
        
        CGRect mySliderRect = CGRectMake( 0.0f , (screenHeight - TOM_TOOL_BAR_HEIGHT - TOM_SLIDER_MAX_Y), TOM_SLIDER_MIN_X, TOM_SLIDER_MAX_Y );
        mySlider = [[TOMViewSlider alloc] initWithFrame:mySliderRect];
        [self.view addSubview:mySlider];

       
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

        //  Create the speedBar
        CGRect speedBarFrame = CGRectMake( ((screenWidth / 2) - (TOM_LABEL_WIDTH/2)), ptTopMargin + 50 , TOM_LABEL_WIDTH, ptLabelHeight );
        speedTimeBar = [[UILabel alloc] initWithFrame:speedBarFrame ];
        speedTimeBar.layer.borderColor = TOM_LABEL_BORDER_COLOR;
        speedTimeBar.layer.borderWidth = TOM_LABEL_BORDER_WIDTH;
        speedTimeBar.layer.cornerRadius  = TOM_LABEL_BORDER_CORNER_RADIUS;
        speedTimeBar.backgroundColor = TOM_LABEL_BACKGROUND_COLOR;
        speedTimeBar.textColor = TOM_LABEL_TEXT_COLOR;
        speedTimeBar.textAlignment = NSTextAlignmentCenter;
        [speedTimeBar setFont:[UIFont fontWithName:@TOM_FONT size:11.0]];
        speedTimeBar.text = @TRAILS_ON_A_MAP;
        [self.view addSubview:speedTimeBar];
        
        //  Create the infoBar
        CGRect infoBarFrame = CGRectMake(((screenWidth / 2) - (TOM_LABEL_WIDTH/2)), ptTopMargin +50  + ptLabelHeight + 10, TOM_LABEL_WIDTH, ptLabelHeight );
        distanceInfoBar = [[UILabel alloc] initWithFrame:infoBarFrame];
        distanceInfoBar.layer.borderColor = TOM_LABEL_BORDER_COLOR;
        distanceInfoBar.layer.borderWidth = TOM_LABEL_BORDER_WIDTH;
        distanceInfoBar.layer.cornerRadius  = TOM_LABEL_BORDER_CORNER_RADIUS;
        distanceInfoBar.backgroundColor = TOM_LABEL_BACKGROUND_COLOR;
        distanceInfoBar.textColor = TOM_LABEL_TEXT_COLOR;
        distanceInfoBar.textAlignment = NSTextAlignmentCenter;
        [distanceInfoBar setFont:[UIFont fontWithName:@TOM_FONT size:11.0]];
        [self.view addSubview:distanceInfoBar];
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
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSURL *icloudURL = [TOMUrl urlForICloudDocuments];
            
            // Look for local files on the device's documents directory and copy them
            // to the iCloud.
            NSURL *defaultURL = [TOMUrl urlForDefaultDocuments];
            
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
                
                NSError *err = nil;
                NSLog(@"%s URL:%@",__func__,[url path]);
                NSString *path = [url path];
                NSArray *parts = [path componentsSeparatedByString:@"/"];
                NSString *fileName = [parts objectAtIndex:[parts count]-1];
                if ([fileName hasSuffix:@TOM_FILE_EXT]) {
                    NSURL *destinationURL = [icloudURL URLByAppendingPathComponent:fileName isDirectory:NO];
                
                    if (![fileManager fileExistsAtPath:[destinationURL path] isDirectory:NO]) {
                        [fileManager copyItemAtURL:url toURL:destinationURL error:&err];
                        if (err) {
                            NSLog(@"%s : Error copy to icloud: %@",__func__,err);
                        }
                    }
                }
            }
            });
        }
    }
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
        NSLog(@"%s Saving trails", __func__ );
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
            NSLog(@"%s Did not change title[%@]",__func__,newTitle);
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
                [mySlider clearSpeedsAndAltitudes];
            }
            else {
                //    the points of the trail will be kept as the new name
                //    no action required.
                theTrail = [[TOMPomSet alloc] initWithFileURL:fileURL];
                myProperties = [[TOMProperties alloc]initWithTitle:newTitle];
                
                [self setTitle:newTitle];
                [myProperties setPtName:newTitle];
            }
            //
        } // end if old title is default
        else { // old title was not the default name
            //
            //  Save off the old track             //
            if (amiUpdatingLocation == YES) {
                NSLog(@"Saving[%@]",self.title);
                // NSURL *fileURL = [TOMUrl fileUrlForTitle:self.title];
                [self saveTrails: NO]; //
                amiUpdatingLocation = NO;
                startStopItem.title = @TOM_ON_TEXT;
                [locationManager stopUpdatingLocation];
                [locationManager stopUpdatingHeading];
                [ptTimer invalidate]; // Stop the timer
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
            
            NSFileManager *fm = [NSFileManager new];
            if ([fm fileExistsAtPath:[fileURL path]]) {
                    [self loadTrails:fileURL];
            }
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
            NSLog(@"Still Empty");
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
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// Did we get a heading update?
//
-(void) locationManager:(CLLocationManager *) manager
       didUpdateHeading:(CLHeading *)newHeading
{
    // NSLog(@"New Heading");
    // NSLog(@"%@", [newHeading description]);
    [self setCurrentHeading:newHeading];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *loc = [locations lastObject ];
    
    // NSLog(@"Did recieve %d locations",[locations count]);
    // NSLog(@"Location %@", [loc description]);
    [worldView setShowsUserLocation:YES];
    
    // NSTimeInterval t = [[ loc timestamp ] timeIntervalSinceNow];
    
    // NSLog(@"Speed: %.2f",[loc speed]);
    // NSLog(@"Time: %f", t);
    if (loc.speed < 0.00) {
        NSLog(@"%s : Speed[%.2f] less than 0",__PRETTY_FUNCTION__,loc.speed);
        return;
    }
    /*
    else if ( t < -0.05 ) {
        // This is cached data, dont want it, keep looking
        NSLog(@"Cached Loc %@@",loc);
        return;
    } */
    else {
        // NSLog(@"Using Loc %@@",loc);
        TOMPointOnAMap *lastPoint = [theTrail lastPom];
        CLLocationDistance myDistance = [lastPoint distanceFromLocation:loc];
        if (myDistance >= [TOMDistance distanceFilter] ||
            myDistance == 0.00) {
            [self processMyLocation: loc type:ptLocation];
        }
#ifdef __DEBUG__
        else {
            NSLog(@"Distance %.2f",myDistance);
        }
#endif
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
                NSLog(@"Error Unknown Pebble Type in update annotations");
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
    [ mySlider addSpeed:[stopLoc speed] Altitude:[stopLoc altitude] ];
    [ mySlider setNeedsDisplay];
    [ mySpeedOMeter updateSpeed:[stopLoc speed]];
    [ mySpeedOMeter setNeedsDisplay];
     
     // Still Moving...
    if  ([stopLoc speed] > 0.0) {
        // NSLog(@"Moving %.2f",[stopLoc speed]);
        return;
    }
    
    CLLocationCoordinate2D coord = [stopLoc coordinate];
    if ([myProperties showInfoBar]) {
        NSString *infoBarText = [[NSString alloc] initWithFormat:@"X:%.4f Y:%.4f S:%@ C:%lu", coord.latitude, coord.longitude, [theTrail elapseTimeString],(unsigned long)[theTrail.ptTrack count]];
        [distanceInfoBar setText:infoBarText];
    }

    // NSLog(@"Stopped?");
    
    //
    // Figure out how far since the last location
    //
    TOMPointOnAMap *lastOne = [theTrail lastPom];
    if (!lastOne) { // or the first location:
        [self processMyLocation:stopLoc type:ptStop];
    }
    if ([lastOne type] != ptStop )
    {
        CLLocationDistance myDist = [lastOne distanceFromLocation:stopLoc];
        // NSLog(@"Distance: %.2f",myDist);
        if (myDist > 0.0) {
            [self processMyLocation:stopLoc type:ptStop];
        }
    }
    
    return;
}


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

#ifdef __FFU__
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
        startStopBarButton.title = @TOM_ON_TEXT;
        
        // Stop the timer
        [ptTimer invalidate];
        
        [locationManager stopUpdatingLocation];
        [locationManager stopUpdatingHeading];
        
        //  This will need to be changed to handing the UIDocument Class:
        // NSURL *fileURL = [TOMUrl fileUrlForTitle:self.title];
        [self saveTrails:NO];
#endif
        
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
    
    //  This will need to be changed to handing the UIDocument Class:
    // NSURL *fileURL = [TOMUrl fileUrlForTitle:self.title];
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
    NSLog(@"Button Index:%ld",(long)buttonIndex);
    NSInteger myTag = [actionSheet tag];
    
    if (myTag == 3) {
        // This is the actions for the iCloud check
        
        if (buttonIndex == 0 ) {
            NSLog(@"User Selected to go to setting to STOP");
            [self stopTrail];
        }
        return;
    }
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
        //
        for (int i = 0 ; i < [theTrail.ptTrack count]; i++)
        {
            TOMPointOnAMap *mp = [theTrail.ptTrack objectAtIndex:i];
            if ([mp type] == ptPicture) {
                NSString *key = [mp key];
                if  (![TOMImageStore imageExists:self.title key:key warn:YES]) {
                    [theTrail.ptTrack removeObjectAtIndex:i];
                }
            }
        }

        
        if (!mapPoms) {
            mapPoms = [[TOMMapSet alloc] init];
        }

        [mapPoms loadFromPoms:theTrail];
        [self updateAnnotations];
    
        if  ([mapPoms pointCount] > 0 )
             [worldView addOverlay:(id <MKOverlay>)mapPoms];

        [worldView setDelegate:self];
        
        result = YES;
    }
    
    [activityIndicator stopAnimating];
    
    return result;
}

//  * * * * * * * *

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
    CGFloat sliderMaxY = TOM_SLIDER_MAX_Y_VERT;
    if (UIDeviceOrientationIsLandscape(currentOrientation)  ||
        currentOrientation == UIDeviceOrientationPortraitUpsideDown ) {
        screenHeight = screenRect.size.width;
        screenWidth = screenRect.size.height;
        sliderMaxY = TOM_SLIDER_MAX_Y_HORZ;
    }
    // else {
    //     NSLog(@"Not Landscape");
    // }
    //
    // NSLog(@"Screen Rect: x:%f y:%f w:%f h:%f",screenRect.origin.x,screenRect.origin.y,screenWidth,screenHeight);

    [self.view setFrame:screenRect];
    CGRect mapRect = CGRectMake( 0.0, 0.0, screenWidth, (screenHeight - TOM_TOOL_BAR_HEIGHT ));
    [worldView setFrame:mapRect];
    
    CGFloat myWidth = 0.0;
    if ([mySlider displayup]) {
        if (UIDeviceOrientationIsLandscape(currentOrientation))
            myWidth = screenWidth-200;
        else
            myWidth = screenWidth;
    }
    else
        myWidth = TOM_SLIDER_MIN_X;
    
    CGRect sliderRect = CGRectMake(0.0f, (screenHeight - sliderMaxY - TOM_TOOL_BAR_HEIGHT), myWidth, sliderMaxY );
    [mySlider setFrame:sliderRect];
    [mySlider setNeedsDisplay];
    
    if ([mySpeedOMeter displayup]) {
        if (UIDeviceOrientationIsLandscape(currentOrientation))
            myWidth = 200.0f;
        else
            myWidth = screenWidth;
    }
    else
        myWidth = TOM_SLIDER_MIN_X;
        
    CGRect speedOMeterRect;
    
    if (UIDeviceOrientationIsLandscape(currentOrientation))
        speedOMeterRect = CGRectMake(screenWidth-myWidth, (screenHeight - sliderMaxY - TOM_TOOL_BAR_HEIGHT), myWidth, sliderMaxY);
    else // Portrait.
        speedOMeterRect = CGRectMake(0.0f,(sliderRect.origin.y - 200 ) ,myWidth, 200.0f);
    
    [mySpeedOMeter setFrame:speedOMeterRect];
    [mySpeedOMeter setNeedsDisplay];
    
    
    CGRect toolbarRect;
    toolbarRect.origin.x = 0;
    toolbarRect.origin.y = screenHeight - TOM_TOOL_BAR_HEIGHT;
    toolbarRect.size.height = TOM_TOOL_BAR_HEIGHT;
    toolbarRect.size.width = screenWidth;
    [toolbar setFrame:toolbarRect];

    CGRect speedBarRect;
    speedBarRect.origin.x = ((screenWidth / 2) - (TOM_LABEL_WIDTH/2));
    speedBarRect.origin.y = ptTopMargin + 50;
    speedBarRect.size.height = ptLabelHeight;
    speedBarRect.size.width = TOM_LABEL_WIDTH;
    [speedTimeBar setFrame:speedBarRect];
    
    CGRect infoBarRect;
    infoBarRect.origin.x = ((screenWidth / 2) - (TOM_LABEL_WIDTH/2));
    infoBarRect.origin.y = ptTopMargin +50  + ptLabelHeight + 10;
    infoBarRect.size.height = ptLabelHeight;
    infoBarRect.size.width = TOM_LABEL_WIDTH;
    [distanceInfoBar setFrame:infoBarRect];
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
    
    // KEY_PT_SHOW_SPEED_LABEL
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SHOW_SPEED_LABEL] != nil)
    {
        [self.myProperties setShowSpeedBar:[[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SHOW_SPEED_LABEL]];
    }
    else
    {   // we don't have a preference stored on this device,
        // use the default value in this case (YES)
        //
        [self.myProperties setShowSpeedBar:YES];  // default
    }
    // Trigger the display
    if ([self.myProperties showSpeedBar]) {
        [speedTimeBar setHidden:NO];
    }
    else
        [speedTimeBar setHidden:YES];
    
    
    // KEY_PT_SHOW_SPEED_LABEL
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SHOW_INFO_LABEL] != nil)
    {
        [self.myProperties setShowInfoBar:[[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SHOW_INFO_LABEL]];
    }
    else
    {
        // we don't have a preference stored on this device,
        // use the default value in this case (YES)
        //
        [self.myProperties setShowInfoBar:YES];  // default
    }
    
    // Trigger the display
    if ([self.myProperties showInfoBar]) {
        [distanceInfoBar setHidden:NO];

    }
    else {
        [distanceInfoBar setHidden:YES];
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
                NSLog(@"%s: %@:%@",__func__,changedKey,tmp);
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
