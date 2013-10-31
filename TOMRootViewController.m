//
//  TOMRootViewController.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/15/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMRootViewController.h"
#import "TOMPropertyViewController.h"
#import "TOMOrganizerViewController.h"

@interface TOMRootViewController ()

@end

@implementation TOMRootViewController

@synthesize amiUpdatingLocation,locationManager, worldView, theTrail, currentHeading, myProperties;

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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateCloudItems:)
                                                     name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                   object:defaultStore];
        [defaultStore synchronize];
        
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
        
        CGRect toolbarRect;
        toolbarRect.origin.y = screenHeight - TOM_TOOL_BAR_HEIGHT;
        toolbarRect.origin.x = 0;
        toolbarRect.size.height = TOM_TOOL_BAR_HEIGHT;
        toolbarRect.size.width = screenRect.size.width;
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:toolbarRect ];
        toolbar.barStyle = UIBarStyleDefault;

        [toolbar setBackgroundImage:nil forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
        
        UIBarButtonItem *flexItem = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                     target:nil
                                     action:nil];

        UIBarButtonItem *cameraItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                       target:self
                                       action:@selector(takePicture:)];

        UIBarButtonItem *startStopItem = [[UIBarButtonItem alloc]
                                          initWithTitle:@TOM_OFF_TEXT
                                          style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(startStop:)];

        UIBarButtonItem *organizerItem = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                          target:self
                                          action:@selector(organizeTrails:)];

        NSArray *items = [NSArray arrayWithObjects: cameraItem, flexItem, startStopItem, flexItem, organizerItem, nil];
        [toolbar setItems:items];
        [self.view addSubview:toolbar];

        //
        // Create location manager object
        //
        locationManager = [[ CLLocationManager alloc] init ];
        [locationManager setDelegate:self];
        
        //
        // Don't start updating the location just yet...
        // [locationManager startUpdatingLocation];
        // [locationManager startUpdatingHeading];

        // Build up the MKMapView
        CGRect mapRect = CGRectMake( 0.0, 0.0, screenWidth, (screenHeight - TOM_TOOL_BAR_HEIGHT));
        worldView = [[MKMapView alloc] initWithFrame:mapRect];
        [self.view addSubview:worldView];

        //  Create the speedBar
        CGRect speedBarFrame = CGRectMake( ((screenWidth / 2) - (TOM_LABEL_WIDTH/2)), ptTopMargin + 50 , TOM_LABEL_WIDTH, ptLabelHeight );
        speedBar = [[UILabel alloc] initWithFrame:speedBarFrame ];
        speedBar.layer.borderColor = TOM_LABEL_BORDER_COLOR;
        speedBar.layer.borderWidth = TOM_LABEL_BORDER_WIDTH;
        speedBar.layer.cornerRadius  = TOM_LABEL_BORDER_CORNER_RADIUS;
        speedBar.backgroundColor = TOM_LABEL_BACKGROUND_COLOR;
        speedBar.textColor = TOM_LABEL_TEXT_COLOR;
        speedBar.textAlignment = NSTextAlignmentNatural;
        [speedBar setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0]];
        speedBar.text = @TRAILS_ON_A_MAP;
        [self.view addSubview:speedBar];
        
        //  Create the infoBar
        CGRect infoBarFrame = CGRectMake(((screenWidth / 2) - (TOM_LABEL_WIDTH/2)), ptTopMargin +50  + ptLabelHeight + 10, TOM_LABEL_WIDTH, ptLabelHeight );
        infoBar = [[UILabel alloc] initWithFrame:infoBarFrame];
        infoBar.layer.borderColor = TOM_LABEL_BORDER_COLOR;
        infoBar.layer.borderWidth = TOM_LABEL_BORDER_WIDTH;
        infoBar.layer.cornerRadius  = TOM_LABEL_BORDER_CORNER_RADIUS;
        infoBar.backgroundColor = TOM_LABEL_BACKGROUND_COLOR;
        infoBar.textColor = TOM_LABEL_TEXT_COLOR;
        infoBar.textAlignment = NSTextAlignmentNatural;
        [infoBar setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0]];
        [self.view addSubview:infoBar];
        //
        // Initialize the variables
        //
        // Title
        self.title = @TRAILS_ON_A_MAP;
        theTrail = [[TOMPomSet alloc] initWithTitle:@TRAILS_ON_A_MAP];
        myProperties = [[TOMProperties alloc]initWithTitle:@TRAILS_ON_A_MAP];
        [[NSUserDefaults standardUserDefaults] setValue:@TRAILS_ON_A_MAP forKey:@KEY_NAME];

        //  Wait for the user to start updating location
        amiUpdatingLocation = NO;
    }
    return self;
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [worldView setShowsUserLocation:YES];
    
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//

- (void) viewDidAppear:(BOOL)animated
{
    // [worldView setShowsUserLocation:YES];
    //
    // Name
    //
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_NAME] != nil)
    {
        NSString *newPath = NULL;
        NSString *newTitle = [[NSUserDefaults standardUserDefaults] stringForKey:@KEY_NAME];
        //
        // It's not the default name and it's not the same as the old name,
        // Let's load up the new name and start up.
        //
        if ([newTitle isEqualToString:@TRAILS_DEFAULT_NAME]) {
            //
            // What to do if the name is the Deafult.
            // NSLog(@"Still Default[%@], let's go on",newTitle);
            
            if (![newTitle isEqualToString:self.title]) {
                //
                // User deleted / cleared a track and reset it back to the
                // default name.  Clear everything:
                amiUpdatingLocation = NO;
                
                [locationManager stopUpdatingLocation];
                [locationManager stopUpdatingHeading];
                
                [worldView removeAnnotations:theTrail.ptTrack];
                theTrail = [[TOMPomSet alloc] initWithTitle:@TRAILS_DEFAULT_NAME];
                
                [worldView removeAnnotations:theTrail.ptTrack];
                [worldView removeOverlay:(id <MKOverlay>)mapPoms];
                
                for (id<MKAnnotation> currentAnnotation in worldView.annotations) {
                    [worldView removeAnnotation:currentAnnotation];
                }
                
                [self setTitle:newTitle];
            }
        }
        else if ([newTitle isEqualToString:self.title]) {
            NSLog(@"Did not change title[%@]",newTitle);
        }
        //
        //  Let's check to see if a pt exists and load it.
        //
        else {
            //
            //  Save off the old track if it's not the initial name or the
            //  Default name.
            //
            if  (![self.title isEqualToString:@TRAILS_DEFAULT_NAME])
            {
                NSLog(@"Saving[%@]",self.title);
                amiUpdatingLocation = NO;

                [locationManager stopUpdatingLocation];
                [locationManager stopUpdatingHeading];
                [ptTimer invalidate]; // Stop the timer
                [self savePoms:self.title];
                [worldView removeAnnotations:theTrail.ptTrack];
                for (id<MKAnnotation> currentAnnotation in worldView.annotations) {
                    [worldView removeAnnotation:currentAnnotation];
                }
                [worldView removeOverlay:(id <MKOverlay>)mapPoms];
            }

            [self setTitle:newTitle];
            [self.myProperties setPtName:newTitle];
            
            if ((newPath = [theTrail tomArchivePathWithTitle:newTitle]) &&
                [[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
                NSLog(@"%@ Exists",newPath);
                amiUpdatingLocation = NO;
                
                [locationManager stopUpdatingLocation];
                [locationManager stopUpdatingHeading];
                
                [worldView removeAnnotations:theTrail.ptTrack];
                theTrail = [[TOMPomSet alloc] initWithTitle:newTitle];
                
                [worldView removeOverlay:(id <MKOverlay>)mapPoms];
                
                if (!mapPoms) {
                    mapPoms = [[TOMMapSet alloc] init];
                }
                else
                    [mapPoms clearPoms];
                [self loadPoms:newTitle];
                
                // These two are in loadPoms:
                // [mapPoms loadFromPoms:theTrail];
                // [self->worldView addOverlay:(id <MKOverlay>)mapPoms];
            }
        }
    }
    else
    {
        // we don't have a pebble track stored,
        // set up up the default.
        //
        [self.myProperties setPtName:@TRAILS_DEFAULT_NAME];  // default
        [self setTitle:@TRAILS_DEFAULT_NAME];
    }
    
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
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_DISTANCE_FILTER] != nil)
    {
        [self.myProperties setPtDistanceFilter:[[NSUserDefaults standardUserDefaults] floatForKey:@KEY_DISTANCE_FILTER]];
    }
    else
    {
        // we don't have a preference stored on this device,
        // use the default value in this case (kCLLocationAccuracyBest)
        //
        [self.myProperties setPtDistanceFilter:50.0];  // default
    }
    [locationManager setDistanceFilter:[self.myProperties ptDistanceFilter]];

#ifndef __NUA__
    // Hoping to improve performance here ...
    if ((myProperties.ptLocationAccuracy == kCLLocationAccuracyBest) ||
        (myProperties.ptLocationAccuracy == kCLLocationAccuracyBestForNavigation)) {
        NSTimeInterval myTimeout = 5.0;
        [locationManager allowDeferredLocationUpdatesUntilTraveled:[myProperties ptDistanceFilter] timeout:myTimeout];
    }
    else
#endif
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
    {
        // we don't have a preference stored on this device,
        // use the default value in this case (YES)
        //
        [self.myProperties setShowSpeedBar:YES];  // default
    }
    // Trigger the display
    if ([self.myProperties showSpeedBar]) {
        [speedBar setHidden:NO];
        speedBar.layer.borderColor = TOM_LABEL_BORDER_COLOR;
        speedBar.layer.borderWidth = TOM_LABEL_BORDER_WIDTH;
        speedBar.layer.cornerRadius = TOM_LABEL_BORDER_CORNER_RADIUS;
    }
    else
        [speedBar setHidden:YES];
    
    
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
        [infoBar setHidden:NO];
        infoBar.layer.borderColor  = TOM_LABEL_BORDER_COLOR;
        infoBar.layer.borderWidth  = TOM_LABEL_BORDER_WIDTH;
        infoBar.layer.cornerRadius = TOM_LABEL_BORDER_CORNER_RADIUS;
    }
    else {
        [infoBar setHidden:YES];
    }
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

    if (!mapPoms) {
        mapPoms = [[TOMMapSet alloc] initWithCenterCoordinate:coord];
        [worldView setDelegate:self]; // ARE YOU FUCKING KIDDING ME ???
        [self->worldView addOverlay:(id <MKOverlay>)mapPoms];
    }
    else {
        // [mapPebbles addCoordinate:[newLocation coordinate]];
        MKMapRect updateRect = [mapPoms addCoordinate:coord];
        
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

    TOMPointOnAMap *mp = [[TOMPointOnAMap alloc] initWithLocationHeadingType:newLocation heading:currentHeading type:pt];
    
    [ theTrail addPointOnMap:mp];
    
    // NSLog(@"Straight Line Distance %.2f" ,[pebbleTrack distanceStraightLine]);
    // NSLog(@"Total Distance %.2f", [pebbleTrack distanceTotalMeters]);
    
    if ([myProperties showSpeedBar]) {
        NSString *speedDistance = [[NSString alloc] initWithFormat:@"SP: %.2f Dist:%.2f m StrLin:%.2f m",[mp speed] *2.23694,
                                   ([theTrail distanceTotalMeters]/1000)*.62137,
                                   ([theTrail distanceStraightLine]/1000)*.62137];
        [speedBar setText:speedDistance];
    }
    
    if ([myProperties showInfoBar]) {
        NSString *infoBarText = [[NSString alloc] initWithFormat:@"X:%.4f Y:%.4f T:%@", coord.latitude, coord.longitude,[theTrail elapseTimeString]];
        [infoBar setText:infoBarText];
    }
    
    // Zoom the region to this location
    if ([self.myProperties showLocations])
        [worldView addAnnotation:(id)mp];

    if ([self.myProperties ptUserTrackingMode] == MKUserTrackingModeNone)
    {
        
        // MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 1000, 1000);
        MKMapRect myMapRect = [theTrail updateMapRect];
        if (MKMapRectIsEmpty(myMapRect)) {
            NSLog(@"Still Empty");
        }
        else  {
            // NSLog(@"Now We're talking");
            MKCoordinateRegion region = [theTrail ptMakeRegion];
            [worldView setRegion:region animated:YES];
            
        }
    }
    
    MKCoordinateRegion region = [theTrail ptMakeRegion];
    [worldView setRegion:region animated:YES];

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
    // NSLog(@"Speed: %.2f",[loc speed]);
    NSTimeInterval t = [[ loc timestamp ] timeIntervalSinceNow];
    if ( t < -1.00 ) {
        // This is cached data, dont want it, keep looking
        // NSLog(@"Cached Loc %@@",loc);
        return;
    }
    else {
        // NSLog(@"Using Loc %@@",loc);
        [self processMyLocation: loc type:ptLocation];
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
    
    // Still Moving...
    if  ([stopLoc speed] > 0.0) {
        // NSLog(@"Moving");
        return;
    }
    
    CLLocationCoordinate2D coord = [stopLoc coordinate];
    if ([myProperties showInfoBar]) {
        NSString *infoBarText = [[NSString alloc] initWithFormat:@"X:%.4f Y:%.4f S:%@", coord.latitude, coord.longitude, [theTrail elapseTimeString]];
        [infoBar setText:infoBarText];
    }
    
    NSLog(@"Stopped?");
    
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
        NSLog(@"Distance: %.2f",myDist);
        if (myDist > 2.0) {
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
    NSLog(@"In startStop");
    UIBarButtonItem *startStopBarButton = (UIBarButtonItem *)sender;
    
    if (amiUpdatingLocation == NO)
    {
        // Start updating the location:
        // NSLog(@TOM_ON_TEXT);
        amiUpdatingLocation = YES;
        startStopBarButton.title = @TOM_OFF_TEXT;
        
        if (![self.title isEqual: @TRAILS_DEFAULT_NAME]   ) {
            //
            // There was some pebbles if loadPebbles returns YES
            //
            if ( [theTrail loadPoms:NULL] == YES)
            {
                [self loadPoms:NULL];
            }
        }
        
        [worldView setDelegate:self];
        [locationManager startUpdatingLocation];
        [locationManager startUpdatingHeading];
        
        // Start The Timer...
        if (![ptTimer isValid])
            ptTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(checkIfStopped:) userInfo:nil repeats:YES];
    }
    else  // isOFF
    {
        // Stop updating the location
        
        // add this last location:
        CLLocation *stopLoc = [locationManager location];
        [self processMyLocation:stopLoc type:ptStop];
        
        NSLog(@TOM_OFF_TEXT);
        amiUpdatingLocation = NO;;
        startStopBarButton.title = @TOM_ON_TEXT;
        [ptTimer invalidate]; // Stop the timer
        
        [locationManager stopUpdatingLocation];
        [locationManager stopUpdatingHeading];
        
        [self savePoms:NULL];
    }
    return;
}

//
// Camera code.........................................................................
//
-(IBAction)takePicture:(id)sender
{
    // NSLog(@"In takePicture");
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    //
    // If our device has a camera, we want to take a picture, otherwise, we
    // just pick from the photo library
    //
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    CLLocation *imageloc = [locationManager location];
    CLHeading *imagehdng = [locationManager heading];
    
    TOMPointOnAMap *imagePebble = [[TOMPointOnAMap alloc] initWithImage: image location:imageloc heading: imagehdng];
    [theTrail addPointOnMap:imagePebble];
    [imageStore setImage:image forKey:[imagePebble key] save:YES];
    
    // add a parameter to save to album or
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        UIImageWriteToSavedPhotosAlbum( image, nil, nil, nil );
    
    // Zoom the region to this location
    [worldView addAnnotation:(id)imagePebble];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


//
// * * * * * * * * * * * * * * * * * * * * * * * *
//
-(IBAction)organizeTrails:(id)sender
{
    
    UIViewController *ptController = [[TOMOrganizerViewController alloc] initWithNibName:@"TOMOrganizerViewController" bundle:nil ];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    [[self navigationController] pushViewController:ptController animated:YES];
    
    return;
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//  Wrapper functions to load and save the data.
//
- (BOOL) loadPoms:(NSString *) title
{
    //
    // There was some pebbles if loadPebbles returns YES
    //
    NSLog(@"loading[%@]",title);
    if ( [theTrail loadPoms:title] == YES)
    {
        //
        // Check to see if the other objects like pictures are there
        //
        UIImage *img;
        for (int i = 0 ; i < [theTrail.ptTrack count]; i++)
        {
            TOMPointOnAMap *mp = [theTrail.ptTrack objectAtIndex:i];
            if ([mp type] == ptPicture) {
                NSString *key = [mp key];
                if  ((img = [imageStore imageForKey:key]) == NULL) {
                    //
                    // If we load an image, great!
                    // otherwise delete the pebble.
                    //
                    if ((img = [imageStore loadImage:key]) != NULL)
                        [imageStore saveImage:img forKey:key];
                    else // delete the point
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
        return YES;
    }
    else
        return NO;
}

//  * * * * * * * *

-(BOOL) savePoms:(NSString *)title
{
    // NSLog(@"savePebbleTracks:[%@]",title);
    
    if  (title) {
        return [theTrail savePoms:title];
    }
    else if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_NAME] != nil)
    {
        NSString *Title = [[NSUserDefaults standardUserDefaults] stringForKey:@KEY_NAME];
        if (![Title isEqualToString:@TRAILS_DEFAULT_NAME])
        {
            return [theTrail savePoms:Title];
        }
    }
    return NO;
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
    NSDictionary *userInfo = [notification userInfo];
    // get the reason (initial download, external change or quota violation change)
    
    NSNumber* reasonForChange = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    if (reasonForChange)
    {
        // reason was deduced, go ahead and check for the change
        //
        NSInteger reason = [[userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey] integerValue];
        
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
#ifdef __FFU__
                // TODO: CHECK ALL THE KEYS
                if ([changedKey isEqualToString:@KEY_MAP_TYPE])
                {
                    
                    // note that the key used in the cloud match the key used locally
                    
                    // replace our "selectedColor" with the value from the cloud
                    NSString *tmp = [[NSUbiquitousKeyValueStore defaultStore] objectForKey:@KEY_MAP_TYPE];
                    NSLog(@"%@:%@",@KEY_PT_MAP_TYPE,tmp);
                    MKMapType tmpMT = [tmp integerValue];
                    // TODO: [self.myProperties setPtMapType: tmpMT];
                    // This updates the maps
                    // TODO: [worldView setMapType:[self.myProperties ptMapType]];
                    
                    // reset the preferred color in NSUserDefaults to keep a local value
                    // TODO: [[NSUserDefaults standardUserDefaults] setInteger:[self.myProperties ptMapType]
                    //                                            forKey:@KEY_PT_MAP_TYPE];
                }
#endif
            }
        }
    }
    
    return;
}



@end
