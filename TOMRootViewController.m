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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateCloudItems:)
                                                     name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                   object:defaultStore];
        
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        // [defaultStore synchronize];
        
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
        
        // Build up the MKMapView
        CGRect mapRect = CGRectMake( 0.0, 0.0, screenWidth, (screenHeight - TOM_TOOL_BAR_HEIGHT ));
        worldView = [[MKMapView alloc] initWithFrame:mapRect];
        [self.view addSubview:worldView];
        
        CGRect mySliderRect = CGRectMake( 0.0f , (screenHeight - TOM_TOOL_BAR_HEIGHT - TOM_SLIDER_MIN_Y), screenWidth, TOM_SLIDER_MIN_Y );
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
                                          initWithTitle:@TOM_OFF_TEXT
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
        theTrail = [[TOMPomSet alloc] initWithTitle:@TRAILS_ON_A_MAP];
        myProperties = [[TOMProperties alloc]initWithTitle:@TRAILS_ON_A_MAP];
        [[NSUserDefaults standardUserDefaults] setValue:@TRAILS_ON_A_MAP forKey:@KEY_NAME];

        //  Wait for the user to start updating location
        amiUpdatingLocation = NO;
        
        // Create the image store
        imageStore = [[TOMImageStore alloc] init];
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
    // [worldView setShowsUserLocation:YES];
    // Request to turn on accelerometer and begin receiving accelerometer events
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
-(void) viewDidDisappear {
    // Request to stop receiving accelerometer events and turn off accelerometer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//

- (void) viewDidAppear:(BOOL)animated
{
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
        NSString *newPath = NULL;
        NSString *newTitle = [[NSUserDefaults standardUserDefaults] stringForKey:@KEY_NAME];
        //
        // It's not the default name and it's not the same as the old name,
        // Let's load up the new name and start up.
        //
        if ([newTitle isEqualToString:self.title]) {
            // Do nothing
            NSLog(@"Did not change title[%@]",newTitle);
        }
        else if ([self.title isEqualToString:@TRAILS_DEFAULT_NAME]) {
            //
            // What to do if the name is the Deafult.
            // NSLog(@"Still Default[%@], let's go on",newTitle);
            //
            if ((newPath = [theTrail tomArchivePathWithTitle:newTitle]) &&
                 [[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
                //
                // User picked to load an existing trail from the default name
                // Clear everything:
                //
                amiUpdatingLocation = NO;
                startStopItem.title = @TOM_OFF_TEXT;
                [locationManager stopUpdatingLocation];
                [locationManager stopUpdatingHeading];
                [ptTimer invalidate]; // Stop the timer
                
                [worldView removeAnnotations:theTrail.ptTrack];
                for (id<MKAnnotation> currentAnnotation in worldView.annotations) {
                    [worldView removeAnnotation:currentAnnotation];
                }
                [worldView removeOverlay:(id <MKOverlay>)mapPoms];

                theTrail = [[TOMPomSet alloc] initWithTitle:@TRAILS_DEFAULT_NAME];
                if (!mapPoms) {
                    mapPoms = [[TOMMapSet alloc] init];
                }
                else
                    [mapPoms clearPoms];
                [self setTitle:newTitle];
                [myProperties setPtName:newTitle];
                [self->worldView addOverlay:(id <MKOverlay>)mapPoms];
                // and load the new trail
                [self loadTrails:newTitle];
                [self processMyLocation:userCoordinate type:ptUnknown];
            }
            else {
                //    the points of the trail will be kept as the new name
                //    no action required.
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
                [self saveTrails:self.title];
                amiUpdatingLocation = NO;
                startStopItem.title = @TOM_OFF_TEXT;
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
            
            //  Load in the new one.
            [self setTitle:newTitle];
            [myProperties setPtName:newTitle];
            theTrail = [[TOMPomSet alloc] initWithTitle:newTitle];
            
            if ((newPath = [theTrail tomArchivePathWithTitle:newTitle]) &&
                [[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
                // NSLog(@"%@ Exists",newPath);
                [self loadTrails:newTitle];
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
#ifdef __NUA__
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
#else
    [locationManager setDistanceFilter:1.0];
#endif

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
    {
        // we don't have a preference stored on this device,
        // use the default value in this case (YES)
        //
        [self.myProperties setShowSpeedBar:YES];  // default
    }
    // Trigger the display
    if ([self.myProperties showSpeedBar]) {
        [speedTimeBar setHidden:NO];
        // speedBar.layer.borderColor = TOM_LABEL_BORDER_COLOR;
        // speedBar.layer.borderWidth = TOM_LABEL_BORDER_WIDTH;
        // speedBar.layer.cornerRadius = TOM_LABEL_BORDER_CORNER_RADIUS;
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
        // infoBar.layer.borderColor  = TOM_LABEL_BORDER_COLOR;
        // infoBar.layer.borderWidth  = TOM_LABEL_BORDER_WIDTH;
        // infoBar.layer.cornerRadius = TOM_LABEL_BORDER_CORNER_RADIUS;
    }
    else {
        [distanceInfoBar setHidden:YES];
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
    MKMapRect updateRect;
    MKCoordinateRegion region;
    
    
    if (pt != ptUnknown &&
        pt != ptError ) {
        TOMPointOnAMap *mp = [[TOMPointOnAMap alloc] initWithLocationHeadingType:newLocation heading:currentHeading type:pt];
        [ theTrail addPointOnMap:mp ];
        // [ mySlider addSpeed:[newLocation speed] ];
        [ mySlider setNeedsDisplay ];
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
    
    NSTimeInterval t = [[ loc timestamp ] timeIntervalSinceNow];
    
    // NSLog(@"Speed: %.2f",[loc speed]);
    // NSLog(@"Time: %f", t);
    if (loc.speed < 0.00) {
        NSLog(@"Speed[%.2f] less than 0",loc.speed);
        return;
    }
    else if ( t < -0.05 ) {
        // This is cached data, dont want it, keep looking
        NSLog(@"Cached Loc %@@",loc);
        return;
    }
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
    [ mySlider addSpeed:[stopLoc speed] ];
    [ mySlider setNeedsDisplay];

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
            // If there was some POMs, loadPOMs returns YES
            //
            if ( [theTrail loadPoms:NULL] == YES)
            {
                [self loadTrails:NULL];
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
        [ptTimer invalidate]; // Stop the timer
        
        [locationManager stopUpdatingLocation];
        [locationManager stopUpdatingHeading];
        
        [self saveTrails:NULL];
    }
    return;
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
    
    NSString *myKey = [imagePebble key];
    
    [imageStore setImage:image forKey:myKey save:YES];


    
    // UIImage *originalImage = ...
    // Save off an icon - the last pic taken will the trails icon
    // Future:  Let the user pic the picture for the icon.
    CGSize destinationSize = CGSizeMake(90.0f, 90.0f);
    UIGraphicsBeginImageContext(destinationSize);
    [image drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (![self.title isEqual: @TRAILS_DEFAULT_NAME]   ) {
        NSString *tomIcon = [[NSString alloc] initWithFormat:@"%@.icon",self.title];
        // NSString *tomIcon = [NSString initWithFormat:@"%s.icon",[self.title]];
        [imageStore saveImage:newImage forKey:tomIcon];
    }
    
#ifdef __FFU__
    imagePebble.image = newImage;
#endif

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
    
    [self saveTrails:NULL];

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
- (BOOL) loadTrails:(NSString *) title
{
    //
    // There was some pebbles if loadPoms returns YES
    //
    // NSLog(@"loading[%@]",title);
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
                    if ((img = [imageStore loadImage:key warn:YES]) != NULL)
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

-(BOOL) saveTrails:(NSString *)title
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

    if (UIDeviceOrientationIsLandscape(currentOrientation) ||
        currentOrientation == UIDeviceOrientationPortraitUpsideDown) {
        screenHeight = screenRect.size.width;
        screenWidth = screenRect.size.height;
    }
    // else {
    //     NSLog(@"Not Landscape");
    // }
    //
    // NSLog(@"Screen Rect: x:%f y:%f w:%f h:%f",screenRect.origin.x,screenRect.origin.y,screenWidth,screenHeight);

    [self.view setFrame:screenRect];
    
    CGRect mapRect = CGRectMake( 0.0, 0.0, screenWidth, (screenHeight - TOM_TOOL_BAR_HEIGHT ));
    [worldView setFrame:mapRect];
    
    CGFloat myHieght = 0.0;
    if ([mySlider displayup]) {
        myHieght = 100.0;
    }
    else
        myHieght = TOM_SLIDER_MIN_Y;
        
    CGRect sliderRect = CGRectMake(0.0f, (screenHeight - TOM_TOOL_BAR_HEIGHT - myHieght), screenWidth, myHieght);
    [mySlider setFrame:sliderRect];
    [mySlider setNeedsDisplay];
    
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

@end
