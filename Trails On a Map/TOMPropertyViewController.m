//
//  TOMPropertyViewController.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/19/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMPropertyViewController.h"
#import "TOMDistance.h"
#import "TOMSpeed.h"

@interface TOMPropertyViewController ()

@end

@implementation TOMPropertyViewController

@synthesize scrollView,titleLabel, titleField, mapTypeLabel, mapTypeSegmentedControl, userTrackingLabel, userTrackingSegmentedControl,
            displaySpeedLabel, displaySpeedSegmentedControl,displayDistanceLabel, displayDistanceSegmentedControl, distanceFilterLabel,
            distanceFilterSliderCtl, accuracyFilterLabel, accuracyFilterSegmentedControl,
            toggleLabel, locationLabel, locationSwitch, pictureLabel, pictureSwitch,
            stopLabel, stopSwitch, odoMeterLabel, odoMeterSwitch, tripMeterLabel,tripMeterSwitch, sliderLabel,sliderSwitch, speedOMeterLabel, speedOMeterSwitch,
            syncLabel, syncSwitch, resetButton, versionLabel, googleDriveEnabledLabel, googleDriveEnabledSwitch,googleDrivePathLabel, googleDrivePathField, photoCountLabel, photoCountField;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = [titleField text];
        //
#ifdef __USE_GDRIVE__
        if ([TOMGDrive isGDriveEnabled]) {
            gDrive = [[TOMGDrive alloc] initGDrive];
            if  ([gDrive isAuthorized]) {
                [gDrive trailsFolderExists];
            }
        }
#endif
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // Request to turn on accelerometer and begin receiving accelerometer events
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationPropertiesChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    // currentDeviceOrientation = UIDeviceOrientationUnknown;
    // currentInterfaceOrientation = UIDeviceOrientationUnknown;
#ifdef __USE_GDRIVE__
    if ([TOMGDrive isGDriveEnabled] && ![gDrive isAuthorized])
    {
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
#ifdef DEBUG
        NSLog(@"Not Yet Authorized");
#endif
        [self.navigationController pushViewController:[gDrive createAuthController] animated:YES];
    }
#endif
    
    // Set up the crontrols first, then set them by the orientation.
    [self createControls];
    [self orientationPropertiesChanged:Nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//
//
-(void) viewDidDisappear:(BOOL)animated {
    // Request to stop receiving accelerometer events and turn off accelerometer
    BOOL yn = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    // Syncronize all the changes here.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_PROPERTIES_SYNC] != nil)
    {
        yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_PROPERTIES_SYNC];
    }
    else {
        yn = YES;
    }
    
    if (yn == YES) {
        NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
        if(![kvStore synchronize]) {
            NSLog(@"ERROR:  %s syncronize Failed",__func__);
        }
    }
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
//
+ (UILabel *)labelWithFrame:(CGRect)frame title:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    
	// label.textAlignment = UITextAlignmentLeft;
    label.text = title;
    label.font = [UIFont fontWithName:@TOM_FONT  size:17.0];
    label.textColor = TOM_LABEL_TEXT_COLOR;
    label.backgroundColor = [UIColor clearColor];
    return label;
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    // NSLog(@"New Name: [%@]",textField);
    NSInteger tag = textField.tag;
    NSString *mytext = [textField text];
    mytext = [mytext stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    switch (tag) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setValue:mytext forKey:@KEY_NAME];
            [self setTitle:mytext];
            [titleField resignFirstResponder]; // and hides the keyboard
            break;
            
        // case 1:
        //   [[NSUserDefaults standardUserDefaults] setValue:mytext forKey:@KEY_GOOGLE_DRIVE_PATH];
        //   [googleDrivePathField resignFirstResponder]; // and hides the keyboard
        //   break;
            
        case 2:
        {   // Sometime in the future I'll find a numpad with a return until then, this will have to do :(
            int myInt = [mytext intValue];
            NSString *myvalue = [NSString stringWithFormat:@"%d",myInt];
            [[NSUserDefaults standardUserDefaults] setValue:myvalue forKey:@KEY_PHOTO_COUNT];
            [photoCountField setText:myvalue];
            [photoCountField resignFirstResponder]; // and hides the keyboard
        }
            break;
        default:
            break;
    }

    return YES;
}



//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// User Tracking Mode
//
- (void)segmentUserTypeAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:[sender selectedSegmentIndex] forKey:@KEY_USER_TRACKING_MODE];
    
    // set the new value for the cloud.  Note, I dont syncronize until I leave this controller
    NSString *tmp = [[NSString alloc] initWithFormat:@"%ld", (long)[sender selectedSegmentIndex]];
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setString:tmp forKey:@KEY_USER_TRACKING_MODE];
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// Map Type
//
- (void)segmentAction:(id)sender
{
    MKMapType myMapType = MKMapTypeStandard;
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            myMapType = MKMapTypeStandard;
            break;
        case 1:
            myMapType = MKMapTypeSatellite;
            break;
        case 2:
            myMapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }

    [[NSUserDefaults standardUserDefaults] setInteger:myMapType forKey:@KEY_MAP_TYPE];
    
    // set the new value for the cloud.  Note, I dont syncronize until I leave this controller
    int i = (int) myMapType;
    NSString *tmp = [[NSString alloc] initWithFormat:@"%d", i];
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setString:tmp forKey:@KEY_MAP_TYPE];
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
//  Distance Filter
//
- (void)sliderAction:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    // NSLog(@"sliderAction: value = %f", [slider value]);
    
    CLLocationDistance myDist = [slider value]; // - ([slider value] / 5.0);
    if (myDist < 10.0)
        myDist = 5.0;
    else {
        CLLocationDistance trim = fmod(myDist, 25.0);
        myDist -= trim;
    }
    
    NSString *title = [[NSString alloc] initWithFormat:@"Distance Filter: %.0f m",myDist] ;
    
    [distanceFilterLabel setText:title];
    
    [[NSUserDefaults standardUserDefaults] setFloat:myDist forKey:@KEY_DISTANCE_FILTER];
    
    // set the new value for the cloud.  Note, I dont syncronize until I leave this controller
    NSString *tmp = [[NSString alloc] initWithFormat:@"%f", myDist];
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setString:tmp forKey:@KEY_DISTANCE_FILTER];
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// Speed Units (Miles Per Hour, Kilometers per Hour, Minutes per Mile,  Meters Per Second
//
- (void)segmentDisplaySpeedAction:(id)sender
{
    // typedef enum  { tomDSError = -1, tomDSUnknown, tomDSMPH, tomDSMPH, tomDSMPM, tomDSFPS } TOMDisplaySpeedType;
    TOMDisplaySpeedType myDisplaySpeedUnit = tomDSMilesPerHour;
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            myDisplaySpeedUnit = tomDSMilesPerHour;
            break;
        case 1:
            myDisplaySpeedUnit = tomDSKmPerHour;
            break;
        case 2:
            myDisplaySpeedUnit = tomDSMinutesPerMile;
            break;
        case 3:
            myDisplaySpeedUnit = tomDSMetersPerSecond;
            break;
        default:
            myDisplaySpeedUnit = tomDSUnknown;
            break;
    }

    [TOMSpeed setSpeedType:myDisplaySpeedUnit];
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// Display Distance Units (Miles, Kilometers, Meters, Feet)
//
- (void)segmentDisplayDistanceAction:(id)sender
{
    // tomDDUnknown, tomDDMiles, tomDDKilometers, tomDDMeters, tomDDFeet
    TOMDisplayDistanceType myDisplaySpeedUnit = tomDDMiles;
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            myDisplaySpeedUnit = tomDDMiles;
            break;
        case 1:
            myDisplaySpeedUnit = tomDDKilometers;
            break;
        case 2:
            myDisplaySpeedUnit = tomDDMeters;
            break;
        case 3:
            myDisplaySpeedUnit = tomDDFeet;
            break;
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger: myDisplaySpeedUnit forKey:@KEY_DISTANCE_UNITS];
    
    // set the new value for the cloud.  Note, I dont syncronize until I leave this controller
    NSString *tmp = [[NSString alloc] initWithFormat:@"%d", myDisplaySpeedUnit];
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setString:tmp forKey:@KEY_DISTANCE_UNITS];
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
//  Location Accuracy
//
- (void)segmentAccuracyAction:(id)sender
{
	// NSLog(@"segmentAction: selected segment = %d", [sender selectedSegmentIndex]);
    CLLocationAccuracy myLocationAccuracy = kCLLocationAccuracyThreeKilometers;
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            myLocationAccuracy = kCLLocationAccuracyBestForNavigation;
            break;
        case 1:
            myLocationAccuracy = kCLLocationAccuracyBest;
            break;
        case 2:
            myLocationAccuracy = kCLLocationAccuracyNearestTenMeters;
            break;
        case 3:
            myLocationAccuracy = kCLLocationAccuracyHundredMeters;
            break;
        case 4:
            myLocationAccuracy = kCLLocationAccuracyKilometer;
            break;
        case 5:
            myLocationAccuracy = kCLLocationAccuracyThreeKilometers;
            break;
        default:
            break;
    }
    
    
    [[NSUserDefaults standardUserDefaults] setFloat:myLocationAccuracy forKey:@KEY_LOCATION_ACCURACY];
    
    // set the new value for the cloud.  Note, I dont syncronize until I leave this controller
    NSString *tmp = [[NSString alloc] initWithFormat:@"%f", myLocationAccuracy];
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setString:tmp forKey:@KEY_LOCATION_ACCURACY];
    // NSLog(@"%@:%@",@KEY_PT_LOCATION_ACCURACY,tmp);
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
//  Common selector for switches (Show Locations, Pictures, stops, Speed Label, Info Label)
//
-(void) ptSwitchSelector:(id)sender
{
    // NSLog(@"%@",sender);
    // NSLog(@"Tag: %d",[sender tag]);
    UISwitch *toggleOnOffSwitch = (UISwitch *)sender;
    BOOL yn = toggleOnOffSwitch.isOn;
    NSString *keyvalue = NULL;
    // BOOL isIcloud = NO;

    
    switch ([sender tag]) {
            
        case ptLocation:
            keyvalue = @KEY_SHOW_LOCATIONS;
            break;
            
        case ptPicture:
            keyvalue = @KEY_SHOW_PICTURES;
            break;
            
        case ptStop:
            keyvalue = @KEY_SHOW_STOPS;
            break;
            
        case ptNote:
            keyvalue = @KEY_SHOW_NOTES;
            break;
            
        case ptSound:
            keyvalue = @KEY_SHOW_SOUNDS;
            break;
        
        case 6:
            keyvalue = @KEY_ODOMETER;
            break;
            
        case 7:
            keyvalue = @KEY_TRIPMETER;
            break;
    
        case 8:
            keyvalue = @KEY_SLIDER;
            break;
            
        case 9:
            keyvalue = @KEY_SPEEDOMETER;
            break;
            
        case 10:
            keyvalue = @KEY_PROPERTIES_SYNC;
            break;
#ifdef __USE_GDRIVE__
        case 11:
            keyvalue = @KEY_GOOGLE_DRIVE_ENABLED;
            //
            // Set the Path Field to match the enabled field.
            //
            [googleDrivePathField setEnabled:yn];
            
            if (yn == YES) {
                //
                //

                [googleDrivePathField setBackgroundColor:[UIColor whiteColor]];
                //
                // If the drive hasn't been allocated.
                if (!gDrive)
                    // allocate
                    gDrive = [[TOMGDrive alloc] init];
                
                // if authroized
                if  ([gDrive isAuthorized])
                    // make sure the folder exists
                    [gDrive trailsFolderExists];
                else
                    // otherwise try to get authorization.
                    [self.navigationController pushViewController:[gDrive createAuthController] animated:YES];
                
            }
            else {
                // gray out the field
                [googleDrivePathField setBackgroundColor:[UIColor lightGrayColor]];
            }
            
            break;
#endif
        
        default:
            NSLog(@"ERROR: %s Unknown Sender Tag for pt types",__func__);
            break;
    }
    
    if (keyvalue) {
        
        [[NSUserDefaults standardUserDefaults] setBool:yn forKey:keyvalue];
        
        // set the new value for the cloud.  Note, I dont syncronize until I leave this controller
        NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
        if  (yn)
            [kvStore setString:@"YES" forKey:keyvalue];
        else
            [kvStore setString:@"NO" forKey:keyvalue];

    }
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
//
//  Reset Button Actions...
//
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
        // NSLog(@"Yes");
        NSString *mytext = @TRAILS_ON_A_MAP;
        // NSLog(@"my title: [%@]",mytext);
        [[NSUserDefaults standardUserDefaults] setValue:mytext forKey:@KEY_NAME];

        // set the new value to the cloud and synchronize
        NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
        [kvStore setString:mytext forKey:@KEY_NAME];
        [self setTitle:mytext];
	}
	else
	{
		NSLog(@"No");
	}
}

- (void)resetTOM:(UIButton*)button
{
    // NSLog(@"Button  clicked.");
    NSString *theTitle = [[NSUserDefaults standardUserDefaults] stringForKey:@KEY_NAME];
    if  (![theTitle isEqualToString:@TRAILS_ON_A_MAP])
        {
        // NSLog(@"Delete %@", theTitle);
        // open a dialog with an OK and cancel button
        NSString *alertTitle = @"Are you sure you want to reset?";
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:alertTitle
                                                                 delegate:self
                                                        cancelButtonTitle:@"NO"
                                                   destructiveButtonTitle:@"YES"
                                                        otherButtonTitles:nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        // [actionSheet setDelegate:self];
        [actionSheet showInView:self.view];
        }
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#pragma mark -
#pragma mark UISegmentControlStyleBordered


- (void)createControls
{
    
    NSArray *segmentMapTypeContent  = [NSArray arrayWithObjects: @"Standard", @"Satellite", @"Hybrid", nil];
    NSArray *segmentUserTracking = [NSArray arrayWithObjects: @"None", @"Follow", @"Heading", nil];
    NSArray *accuracyTextContent = [NSArray arrayWithObjects: @"Nav", @"Best", @"10m", @"100m", @"1km", @"3km" , nil];
    NSArray *pebbleTypeText = [NSArray arrayWithObjects: @"Locations:",@"Pictures:", @"Stops:", @"Notes", @"Sounds", @"Odometer:",@"Trip Meter:",
                                                         @"Histograph:",@"SpeedOMeter:", @"Sync Properties:", @"Google Drive Enabled:", nil];
    
    NSArray *displaySpeedText = [NSArray arrayWithObjects:@"M P H",@"K P H",@"M P M",@"M P S", nil]; // Miles per Hour, KM per Hour, Min / Mile, Meters / Sec
    NSArray *displayDistanceText = [NSArray arrayWithObjects:@"Miles",@"Kilometers", @"Meters", @"Feet", nil];
    
    UIFont *myLabelFont = [UIFont fontWithName: @TOM_FONT size: 12.0 ];
    UIFont *myTitleFont = [UIFont fontWithName: @TOM_FONT size: 12.0 ];
    UIFont *myVersionFont = [UIFont fontWithName: @TOM_FONT size: 10.0 ];

#ifdef __USE_GDRIVE__
    BOOL googleDriveEnabledFlag = NO;
#endif
    
    //  Am even better way to do this...
    CGRect screenRect;
    [TOMUIUtilities screenRect:&screenRect];
    
    CGRect myrect = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    
    // UIScrollView *scrollView
    scrollView = [[UIScrollView alloc] initWithFrame:myrect];
    [scrollView setScrollEnabled:YES];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    //
    // The key to making the scrollable window now bounce is these next two lines of code.
    // The size (mysize.y in this case) has to be bigger than the CGRect created for scrollView.
    //
    CGSize mysize = CGSizeMake(screenRect.size.width, 775 ); //  screenRect.size.height+TOM_PVC_EXTRA);
    [scrollView setContentSize:mysize];
    // features...
    [scrollView setAlwaysBounceVertical:YES];
    [scrollView setShowsHorizontalScrollIndicator:YES];
    [scrollView setScrollsToTop:NO];
    [self.view addSubview:scrollView];

    
    int objectWidth = screenRect.size.width;
    objectWidth -= (ptRightMargin)  ;
    
    // Title UITextInput
	CGFloat yPlacement = ptTopMargin; // for starters...
	CGRect frame = CGRectMake(	ptLeftMargin, yPlacement, 100, ptLabelHeight);
    titleLabel = [TOMPropertyViewController labelWithFrame:frame title:@"Title:"];
    [titleLabel setFont:myLabelFont];
    [titleLabel setTextAlignment:NSTextAlignmentRight];
    [scrollView addSubview:titleLabel];
    
    frame = CGRectMake(	ptLeftMargin + 100,yPlacement -5, objectWidth - 120, ptLabelHeight + 5);
    
    titleField = [[ UITextField alloc] initWithFrame: frame];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_NAME] != nil)
    {
        [titleField setText:[[NSUserDefaults standardUserDefaults] stringForKey:@KEY_NAME]];
        [self setTitle:[[NSUserDefaults standardUserDefaults] stringForKey:@KEY_NAME]];
    }
    else
    {   //
        // we don't have a preference stored on this device, use the map type standard as default.
        //
        [titleField setText:@TRAILS_DEFAULT_NAME]; // default
    }
    
    [titleField addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventValueChanged];
    [titleField setBorderStyle:UITextBorderStyleRoundedRect];
    [titleField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [titleField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [titleField setDelegate:self];  // set up the delegate
    [titleField setFont:myTitleFont];
    [titleField setTag:0];
    [titleField setBackgroundColor:[UIColor whiteColor]];
    [scrollView addSubview:titleField];
    
    // Map Type Label
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptLabelHeight;
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptLabelHeight);
    mapTypeLabel = [TOMPropertyViewController labelWithFrame:frame title:@"Map Type:"];
    [mapTypeLabel setFont:myLabelFont];
    [mapTypeLabel setTextAlignment:NSTextAlignmentRight];
	[scrollView addSubview:mapTypeLabel];
    
	// control
    mapTypeSegmentedControl= [[UISegmentedControl alloc] initWithItems:segmentMapTypeContent];
    
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptLabelHeight;
    
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
	mapTypeSegmentedControl.frame = frame;
	[mapTypeSegmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	// Deprecated in iOS7: segmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
    
    MKMapType myMapType;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_MAP_TYPE] != nil)
    {
        myMapType = [[NSUserDefaults standardUserDefaults] integerForKey:@KEY_MAP_TYPE];
    }
    else
    {   //
        // we don't have a preference stored on this device, use the map type standard as default.
        //
        myMapType = MKMapTypeStandard;
    }
    
    switch (myMapType) {
        case MKMapTypeStandard:
            mapTypeSegmentedControl.selectedSegmentIndex = 0;
            break;
        case MKMapTypeSatellite:
            mapTypeSegmentedControl.selectedSegmentIndex = 1;
            break;
        case MKMapTypeHybrid:
            mapTypeSegmentedControl.selectedSegmentIndex = 2;
            break;
        default:
            NSLog(@"ERROR: Invalid or Unknown ptMapType");
            break;
    }
	
	[scrollView addSubview:mapTypeSegmentedControl];
    
    // User Tracking Mode...
    // label
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptSegmentedControlHeight - 5;
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    userTrackingLabel =[TOMPropertyViewController labelWithFrame:frame title:@"User Tracking:"];
    [userTrackingLabel setFont:myLabelFont];
    [userTrackingLabel setTextAlignment:NSTextAlignmentRight];
    [scrollView addSubview: userTrackingLabel];
    
    // mode controller.
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptLabelHeight + 10;
    userTrackingSegmentedControl = [[UISegmentedControl alloc] initWithItems:segmentUserTracking];
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    userTrackingSegmentedControl.frame = frame;
	[userTrackingSegmentedControl addTarget:self action:@selector(segmentUserTypeAction:) forControlEvents:UIControlEventValueChanged];
	// Deprecated in iOS7: segmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
    
    MKUserTrackingMode myUserTrackingMode;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_USER_TRACKING_MODE] != nil)
    {
        myUserTrackingMode = [[NSUserDefaults standardUserDefaults] integerForKey:@KEY_USER_TRACKING_MODE];
    }
    else
    {   //
        // we don't have a preference stored on this device,use the Tracking Mode None as default.
        //
        myUserTrackingMode = MKUserTrackingModeNone;  // default
    }
    
    switch (myUserTrackingMode)
    {
        case MKUserTrackingModeNone:
            userTrackingSegmentedControl.selectedSegmentIndex = 0;
            break;
        case MKUserTrackingModeFollow:
            userTrackingSegmentedControl.selectedSegmentIndex = 1;
            break;
        case MKUserTrackingModeFollowWithHeading:
            userTrackingSegmentedControl.selectedSegmentIndex = 2;
            break;
        default:
            NSLog(@"ERROR: Invalid or Unknown ptUserTrackingMode");
            break;
    }
    [scrollView addSubview:userTrackingSegmentedControl];
    //
    // Display Speed Units
    //
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptSegmentedControlHeight - 5;
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    displaySpeedLabel =[TOMPropertyViewController labelWithFrame:frame title:@"Display Speed:"];
    [displaySpeedLabel setFont:myLabelFont];
    [displaySpeedLabel setTextAlignment:NSTextAlignmentRight];
    [scrollView addSubview: displaySpeedLabel];
    
    // mode controller.
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptLabelHeight + 10;
    displaySpeedSegmentedControl = [[UISegmentedControl alloc] initWithItems:displaySpeedText];
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    displaySpeedSegmentedControl.frame = frame;
	[displaySpeedSegmentedControl addTarget:self action:@selector(segmentDisplaySpeedAction:) forControlEvents:UIControlEventValueChanged];


    TOMDisplaySpeedType mySpeedUnits = [TOMSpeed speedType];
    
    switch (mySpeedUnits)
    {
        case tomDSMilesPerHour:
            displaySpeedSegmentedControl.selectedSegmentIndex = 0;
            break;
        case tomDSKmPerHour:
            displaySpeedSegmentedControl.selectedSegmentIndex = 1;
            break;
        case tomDSMinutesPerMile:
            displaySpeedSegmentedControl.selectedSegmentIndex = 2;
            break;
        case tomDSMetersPerSecond:
            displaySpeedSegmentedControl.selectedSegmentIndex = 3;
            break;
        default:
            // displayUnitsSegmentedControl.selectedSegmentIndex = 0;
            NSLog(@"ERROR: Invalid or Unknown %@",@KEY_SPEED_UNITS);
            break;
    }
    [scrollView addSubview:displaySpeedSegmentedControl];
    
    //
    // Display Distance Units
    //
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptSegmentedControlHeight - 5;
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    displayDistanceLabel =[TOMPropertyViewController labelWithFrame:frame title:@"Display Distance:"];
    [displayDistanceLabel setFont:myLabelFont];
    [displayDistanceLabel setTextAlignment:NSTextAlignmentRight];
    [scrollView addSubview: displayDistanceLabel];
    
    // mode controller.
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptLabelHeight + 10;
    displayDistanceSegmentedControl = [[UISegmentedControl alloc] initWithItems:displayDistanceText];
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    displayDistanceSegmentedControl.frame = frame;
	[displayDistanceSegmentedControl addTarget:self action:@selector(segmentDisplayDistanceAction:) forControlEvents:UIControlEventValueChanged];
    
    TOMDisplayDistanceType myDistanceUnits = [TOMDistance distanceType];
    
    switch (myDistanceUnits)
    { // tomDDUnknown, tomDDMiles, tomDDKilometers, tomDDMeters, tomDDFeet
        case tomDDMiles:
            displayDistanceSegmentedControl.selectedSegmentIndex = 0;
            break;
        case tomDDKilometers:
            displayDistanceSegmentedControl.selectedSegmentIndex = 1;
            break;
        case tomDDMeters:
            displayDistanceSegmentedControl.selectedSegmentIndex = 2;
            break;
        case tomDDFeet:
            displayDistanceSegmentedControl.selectedSegmentIndex = 3;
            break;
        default:
            // displayUnitsSegmentedControl.selectedSegmentIndex = 0;
            NSLog(@"ERROR: Invalid or Unknown %@",@KEY_DISTANCE_UNITS);
            break;
    }
    [scrollView addSubview:displayDistanceSegmentedControl];
    

    //
    // Distance Filter ...
    // label
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptSegmentedControlHeight;
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    
    // Had to get the value now so it can be displayed in the distance filter title.
    CLLocationDistance myDistanceFilter ; // = [TOMDistance distanceFilter];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_DISTANCE_FILTER] != nil)
    {
        myDistanceFilter = [[NSUserDefaults standardUserDefaults] floatForKey:@KEY_DISTANCE_FILTER];
    }
    else
    {   //
        // we don't have a preference stored on this device,use the kCLLocationAccuracyBest as default.
        //
        myDistanceFilter = 100.0;  // default
    }

	// label.textAlignment = UITextAlignmentLeft;
    NSString *title = [[NSString alloc] initWithFormat:@"Distance Filter: %.0f m",myDistanceFilter] ;
    distanceFilterLabel = [TOMPropertyViewController labelWithFrame:frame title:title];
    [distanceFilterLabel setFont:myLabelFont];
    [distanceFilterLabel setTextAlignment:NSTextAlignmentRight];
    [scrollView addSubview:distanceFilterLabel];
    
    // slider bar controller
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptLabelHeight + 10;
    frame = CGRectMake( ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    
    distanceFilterSliderCtl= [[UISlider alloc] initWithFrame:frame];
    [distanceFilterSliderCtl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    // in case the parent view draws with a custom color or gradient, use a transparent color
    distanceFilterSliderCtl.backgroundColor = [UIColor clearColor];
    
    distanceFilterSliderCtl.minimumValue = 5.0;
    distanceFilterSliderCtl.maximumValue = 1000.0;
    distanceFilterSliderCtl.continuous = YES;
    
    distanceFilterSliderCtl.value = myDistanceFilter;
    
    // Add an accessibility label that describes the slider.
    [distanceFilterSliderCtl setAccessibilityLabel:NSLocalizedString(@"Distance Filter", @"")];
    [scrollView addSubview:distanceFilterSliderCtl];
    
    //
    //  Map Accuracy Controller
    //
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptSegmentedControlHeight - 15;
    frame = CGRectMake(	ptLeftMargin,
                       yPlacement, objectWidth,
                       ptSegmentedControlHeight);
    
    accuracyFilterLabel = [TOMPropertyViewController labelWithFrame:frame title:@"Accuracy:"];
    [accuracyFilterLabel setFont:myLabelFont];
    [accuracyFilterLabel setTextAlignment:NSTextAlignmentRight];
    [scrollView addSubview:accuracyFilterLabel];
    
    //
    // Location Accuracy Filter
    //
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptLabelHeight + 10;
    accuracyFilterSegmentedControl = [[UISegmentedControl alloc] initWithItems:accuracyTextContent];
    frame = CGRectMake(	ptLeftMargin,yPlacement, objectWidth,ptSegmentedControlHeight);
    accuracyFilterSegmentedControl.frame = frame;
	[accuracyFilterSegmentedControl addTarget:self action:@selector(segmentAccuracyAction:) forControlEvents:UIControlEventValueChanged];
	// Deprecated in iOS7:  segmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
    
    CLLocationAccuracy myLocationAccuracy;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_LOCATION_ACCURACY] != nil)
    {
        myLocationAccuracy = [[NSUserDefaults standardUserDefaults] integerForKey:@KEY_LOCATION_ACCURACY];
    }
    else
    {   //
        // we don't have a preference stored on this device,use the kCLLocationAccuracyBest as default.
        //
        myLocationAccuracy = kCLLocationAccuracyBest;  // default
    }
    
    // set the controller value here...
    if (myLocationAccuracy == kCLLocationAccuracyBestForNavigation)
    {
        accuracyFilterSegmentedControl.selectedSegmentIndex = 0;
    }
    else if (myLocationAccuracy == kCLLocationAccuracyBest)
    {
        accuracyFilterSegmentedControl.selectedSegmentIndex = 1;
    }
    else if (myLocationAccuracy == kCLLocationAccuracyNearestTenMeters)
    {
        accuracyFilterSegmentedControl.selectedSegmentIndex = 2;
    }
    else if (myLocationAccuracy == kCLLocationAccuracyHundredMeters)
    {
        accuracyFilterSegmentedControl.selectedSegmentIndex = 3;
    }
    else if (myLocationAccuracy == kCLLocationAccuracyKilometer)
    {
        accuracyFilterSegmentedControl.selectedSegmentIndex = 4;
    }
    else if (myLocationAccuracy == kCLLocationAccuracyThreeKilometers)
    {
        accuracyFilterSegmentedControl.selectedSegmentIndex = 5;
    }
    else  // Something didn't go quite right, set it to the default of accuracy best:
        accuracyFilterSegmentedControl.selectedSegmentIndex = 1;
    
    // add the subview...
    [scrollView addSubview:accuracyFilterSegmentedControl];
    
    
    // Add Point Type Toggles
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptSegmentedControlHeight - 10;
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    toggleLabel = [TOMPropertyViewController labelWithFrame:frame title:@"Toggles:"];
    [toggleLabel setFont:myLabelFont];
    [toggleLabel setTextAlignment:NSTextAlignmentRight];
    [scrollView addSubview:toggleLabel];
    
    // for (POMType pt = ptLocation; pt <= ptSound; pt++ )
    for (NSInteger pt = 1; pt < 11  ; pt++)
    {
        if (pt == ptNote || pt == ptSound) {
            continue;
        }
        BOOL yn;
        yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptSegmentedControlHeight - 10;
        frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
        UISwitch *ptSwitch = [[UISwitch alloc] initWithFrame:frame ];
        [ptSwitch setTag:pt];
        [ptSwitch addTarget:self action:@selector(ptSwitchSelector:) forControlEvents:UIControlEventValueChanged];
        
        switch (pt) {
            case ptLocation:
                locationSwitch = ptSwitch;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SHOW_LOCATIONS] != nil)
                {
                    yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SHOW_LOCATIONS];
                }
                else
                {   //
                    // we don't have a preference stored on this device,use the YES as default.
                    //
                    yn =YES;  // default
                }
                frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
                locationLabel = [TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]];
                [locationLabel setFont:myLabelFont];
                [locationLabel setTextAlignment:NSTextAlignmentRight];
                [scrollView addSubview:locationLabel];
                break;
                
            case ptPicture:
                pictureSwitch = ptSwitch;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SHOW_PICTURES] != nil)
                {
                    yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SHOW_PICTURES];
                }
                else
                {   //
                    // we don't have a preference stored on this device,use the YES as default.
                    //
                    yn =YES;  // default
                }
                frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
                pictureLabel = [TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]];
                [pictureLabel setFont:myLabelFont];
                [pictureLabel setTextAlignment:NSTextAlignmentRight];
                [scrollView addSubview:pictureLabel];
                break;
                
            case ptStop:
                stopSwitch = ptSwitch;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SHOW_STOPS] != nil)
                {
                    yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SHOW_STOPS];
                }
                else
                {   //
                    // we don't have a preference stored on this device,use the YES as default.
                    //
                    yn =YES;  // default
                }
                frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
                stopLabel = [TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]];
                [stopLabel setFont:myLabelFont];
                [stopLabel setTextAlignment:NSTextAlignmentRight];
                [scrollView addSubview:stopLabel];

                break;
                
            case ptNote:
            case ptSound:
                continue;
                break;
            
            case 6: // SpeedBar
                odoMeterSwitch = ptSwitch;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_ODOMETER] != nil)
                {
                    yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_ODOMETER];
                }
                else
                {   //
                    // we don't have a preference stored on this device,use the YES as default.
                    //
                    yn = YES;  // default
                }
                frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
                odoMeterLabel = [TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]];
                [odoMeterLabel setFont:myLabelFont];
                [odoMeterLabel setTextAlignment:NSTextAlignmentRight];
                [scrollView addSubview:odoMeterLabel];
                break;
                
            case 7:
                tripMeterSwitch = ptSwitch;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_TRIPMETER] != nil)
                {
                    yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_TRIPMETER];
                }
                else
                {   //
                    // we don't have a preference stored on this device,use the YES as default.
                    //
                    yn =YES;  // default
                }
                frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
                tripMeterLabel = [TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]];
                [tripMeterLabel setFont:myLabelFont];
                [tripMeterLabel setTextAlignment:NSTextAlignmentRight];
                [scrollView addSubview:tripMeterLabel];
                break;
            case 8:
                sliderSwitch = ptSwitch;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SLIDER] != nil)
                {
                    yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SLIDER];
                }
                else
                {   //
                    // we don't have a preference stored on this device,use the YES as default.
                    //
                    yn =YES;  // default
                }
                frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
                sliderLabel = [TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]];
                [sliderLabel setFont:myLabelFont];
                [sliderLabel setTextAlignment:NSTextAlignmentRight];
                [scrollView addSubview:sliderLabel];
                break;
            case 9:
                speedOMeterSwitch = ptSwitch;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SPEEDOMETER] != nil)
                {
                    yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SPEEDOMETER];
                }
                else
                {   //
                    // we don't have a preference stored on this device,use the YES as default.
                    //
                    yn =YES;  // default
                }
                frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
                speedOMeterLabel = [TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]];
                [speedOMeterLabel setFont:myLabelFont];
                [speedOMeterLabel setTextAlignment:NSTextAlignmentRight];
                [scrollView addSubview:speedOMeterLabel];
                break;
            case 10:
                syncSwitch = ptSwitch;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_PROPERTIES_SYNC] != nil)
                {
                    yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_PROPERTIES_SYNC];
                }
                else {
                    yn = YES;
                }
                frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
                syncLabel = [TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]];
                [syncLabel setFont:myLabelFont];
                [syncLabel setTextAlignment:NSTextAlignmentRight];
                [scrollView addSubview:syncLabel];
                break;
                
#ifdef __USE_GDRIVE__
            case 11:

                googleDriveEnabledSwitch = ptSwitch;
                yn  = [TOMGDrive isGDriveEnabled];
                googleDriveEnabledFlag = yn;

                frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
                googleDriveEnabledLabel = [TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]];
                [googleDriveEnabledLabel setFont:myLabelFont];
                [googleDriveEnabledLabel setTextAlignment:NSTextAlignmentRight];
                [scrollView addSubview:googleDriveEnabledLabel];
  
                break;
#endif
                
            default:
                yn = NO;  // default
                break;
        }
        
        [ptSwitch setOn:yn];
        
        [scrollView addSubview:ptSwitch];
        
        // frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
        // [scrollView addSubview:[TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]]];
    }
 
#ifdef __USE_GDRIVE__
    // Google Path
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptSegmentedControlHeight - 10;
    frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
    googleDrivePathLabel = [TOMPropertyViewController labelWithFrame:frame title:@"Google Path:"];
    [googleDrivePathLabel setFont:myLabelFont];
    [googleDrivePathLabel setTextAlignment:NSTextAlignmentRight];
    [scrollView addSubview:googleDrivePathLabel];
    
    frame = CGRectMake(	ptLeftMargin + 100,yPlacement -5, objectWidth - 120, ptLabelHeight + 5);
    
    googleDrivePathField = [[ UITextField alloc] initWithFrame: frame];
    [googleDrivePathField setText:[TOMGDrive getPathName]];
    
  
    [googleDrivePathField addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventValueChanged];
    [googleDrivePathField setTag:1];
    [googleDrivePathField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [googleDrivePathField setBorderStyle:UITextBorderStyleRoundedRect];
    [googleDrivePathField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [googleDrivePathField setDelegate:self];  // set up the delegate
    [googleDrivePathField setFont:myTitleFont];

    if (googleDriveEnabledFlag == YES) {
        [googleDrivePathField setBackgroundColor:[UIColor whiteColor]];
    }
    else {
        [googleDrivePathField setBackgroundColor:[UIColor lightGrayColor]];
    }
    [googleDrivePathField setEnabled:googleDriveEnabledFlag];
    [scrollView addSubview:googleDrivePathField];
#endif

    // Photo Count
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptSegmentedControlHeight - 10;
    frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
    photoCountLabel = [TOMPropertyViewController labelWithFrame:frame title:@"Photo Count:"];
    [photoCountLabel setFont:myLabelFont];
    [photoCountLabel setTextAlignment:NSTextAlignmentRight];
    [scrollView addSubview:photoCountLabel];
    
    frame = CGRectMake(	ptLeftMargin + 100,yPlacement -5, objectWidth - 120, ptLabelHeight + 5);
    
    photoCountField = [[ UITextField alloc] initWithFrame: frame];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_PHOTO_COUNT] != nil)
    {
        [photoCountField setText:[[NSUserDefaults standardUserDefaults] stringForKey:@KEY_PHOTO_COUNT]];
    }
    else
    {   //
        // we don't have a preference stored on this device, use the map type standard as default.
        //
        [photoCountField setText:@"1"]; // default
    }
    
    [photoCountField addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventValueChanged];
    [photoCountField setTag:2];
    [photoCountField setBorderStyle:UITextBorderStyleRoundedRect];
    [photoCountField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [photoCountField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [photoCountField setDelegate:self];  // set up the delegate
    [photoCountField setFont:myTitleFont];
    [photoCountField setBackgroundColor:[UIColor whiteColor]];
    [photoCountField setReturnKeyType:UIReturnKeyDone];
    [scrollView addSubview:photoCountField];
    
    //
    // Finally - Add a reset button for the user to clear the trail.
    
    frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
    
    resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [resetButton setFrame:frame];
    [resetButton setTitle:@"RESET" forState:UIControlStateNormal];
    [resetButton addTarget:self
               action:@selector(resetTOM:)
     forControlEvents:UIControlEventTouchDown];
    [resetButton.layer setBorderColor:TOM_LABEL_BORDER_COLOR];
    [resetButton.layer setBorderWidth:TOM_LABEL_BORDER_WIDTH];
    [resetButton.layer setCornerRadius:TOM_LABEL_BORDER_CORNER_RADIUS];
    
    [scrollView addSubview:resetButton];

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *shortVersionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *myVersion = [[NSString alloc] initWithFormat:@"Version: %@.%@",shortVersionString,version];
    
    frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
    versionLabel = [TOMPropertyViewController labelWithFrame:frame title:myVersion];
    versionLabel.font = myVersionFont;
    [versionLabel setTextAlignment:NSTextAlignmentLeft];
    [scrollView addSubview:versionLabel];
    
#ifdef __DEBUG__
    NSLog( @"%s Height So Far: %.2f",__PRETTY_FUNCTION__, yPlacement);
    NSLog(@"CFBundleVersion is: %@",version);
    NSLog(@"CFBundleShortVersionString: %@",shortVersionString);
#endif
    
}


- (void)orientationPropertiesChanged:(NSNotification *)notification
{
    // Respond to changes in device orientation
    // if (notification)
    //    NSLog(@"Orientation Changed! %@",notification);
    // else
    //    NSLog(@"Orientation Changed! (nil)");

    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == currentDeviceOrientation) {
        return;
    }
    

    if ((UIDeviceOrientationIsPortrait(currentDeviceOrientation) && UIDeviceOrientationIsPortrait(orientation)) ||
        (UIDeviceOrientationIsLandscape(currentDeviceOrientation) && UIDeviceOrientationIsLandscape(orientation)) ||
        orientation == UIDeviceOrientationPortraitUpsideDown) {
        //still saving the current orientation
        currentDeviceOrientation = orientation;
        return;
    }
    
    currentDeviceOrientation = orientation;

    CGRect screenRect;
    [TOMUIUtilities screenRect:&screenRect];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    CGRect myScreenRect = CGRectMake(0, 0, screenWidth, screenHeight);
    [self.view setFrame:myScreenRect];
    [scrollView setFrame:myScreenRect];

    CGSize mysize = CGSizeMake(myScreenRect.size.width, myScreenRect.size.height + ( TOM_PVC_EXTRA * 2.0) );
    [scrollView setContentSize:mysize];
    
    // Update the individual components here:
#define SPACING 20.0
    CGFloat myX = ptLeftMargin;
    CGFloat myY = ptTopMargin;
    CGFloat myYSpacer = (ptSegmentedControlHeight - ptLabelHeight)/2.0;
    CGFloat labelWidth = 140.0;
    CGFloat actorWidth = screenWidth - (myX + ptRightMargin + SPACING + labelWidth); // 20 is the space between label and actor

    if (screenWidth > 550) {
        // enough room to layout the labels and their objects side by side.

        // Title:
        CGRect myrect= CGRectMake(myX, myY + myYSpacer, labelWidth, ptLabelHeight);
        [titleLabel setFrame:myrect];
        
        // Title Field
        myrect= CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [titleField setFrame:myrect];
        
        // Map Type:
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [mapTypeLabel setFrame:myrect];
        
        // Map Type Control
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [mapTypeSegmentedControl setFrame:myrect];
        
        // User Tracking Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [userTrackingLabel setFrame:myrect];
        
        // User Tracking Control
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [userTrackingSegmentedControl setFrame:myrect];
        
        // Display Speed Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [displaySpeedLabel setFrame:myrect];
        
        // Dispaly Speed Control
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [displaySpeedSegmentedControl setFrame:myrect];
        
        // Display Distance Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [displayDistanceLabel setFrame:myrect];
        
        // Dispaly Distance Control
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [displayDistanceSegmentedControl setFrame:myrect];
        
        // Distance Filter Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [distanceFilterLabel setFrame:myrect];
        
        // Distance Filter Slider Control
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [distanceFilterSliderCtl setFrame:myrect];
        
        // Accuracy Filter Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [accuracyFilterLabel setFrame:myrect];
        
        // Accuracy Filter Segmented Control
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [accuracyFilterSegmentedControl setFrame:myrect];
        
        // Toggle Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [toggleLabel setFrame:myrect];
        
        // Location Switch Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [locationLabel setFrame:myrect];
        
        // Location Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [locationSwitch setFrame:myrect];

        // Picture Switch Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [pictureLabel setFrame:myrect];
        
        // Picture Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [pictureSwitch setFrame:myrect];
        
        // Stop Switch Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [stopLabel setFrame:myrect];
        
        // Stop Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [stopSwitch setFrame:myrect];
        
        // Odometer Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [odoMeterLabel setFrame:myrect];
        
        // Odometer Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [odoMeterSwitch setFrame:myrect];


        // Trip Meter Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [tripMeterLabel setFrame:myrect];
        
        // Trip meter Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [tripMeterSwitch setFrame:myrect];

        // Slider (Histograph) Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [sliderLabel setFrame:myrect];
        
        // Slider Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [sliderSwitch setFrame:myrect];

        // SpeedOMeter Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [speedOMeterLabel setFrame:myrect];
        
        // SpeedOMeter Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [speedOMeterSwitch setFrame:myrect];

        // Sync Properties Switch Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [syncLabel setFrame:myrect];
        
        // Sync Propoerties Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [syncSwitch setFrame:myrect];
        
        // Google Drive Enabled Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [googleDriveEnabledLabel setFrame:myrect];
        
        // Google Drive Enabled Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [googleDriveEnabledSwitch setFrame:myrect];

        // Google Drive Path Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [googleDrivePathLabel setFrame:myrect];
        
        // Google Drive Path Text Box
        myrect= CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [googleDrivePathField setFrame:myrect];
        
       
        // Photo Count Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [photoCountLabel setFrame:myrect];
        
        // Photo Count Text Box
        myrect= CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [photoCountField setFrame:myrect];
        
        // Reset Button
        CGFloat buttonX = (screenWidth - (myX + ptRightMargin + 100.0)) / 2.0;
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(buttonX, myY+myYSpacer, 100.0, ptSegmentedControlHeight);
        [resetButton setFrame:myrect];
        
        // Version Label
        myY += ptSegmentedControlHeight + (SPACING * 2);
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [versionLabel setFrame:myrect];
        
    }
    else {
        // CGFloat labelWidth = 100.0;
        // CGFloat actorWidth = screenWidth - (myX + ptRightMargin + SPACING + labelWidth); // 20 is the space between label and actor
        
        // Title:
        // CGSize textSize = [[titleLabel text] sizeWithAttributes:@{NSFontAttributeName:[titleLabel font]}];
        CGRect myrect= CGRectMake( myX, myY+myYSpacer, 60.0 /* labelWidth */, ptLabelHeight);
        [titleLabel setFrame:myrect];

        // Title Field
        myrect= CGRectMake(myX + 60.0 /* labelWidth */ + SPACING, myY  , actorWidth + 80.0, ptSegmentedControlHeight);
        [titleField setFrame:myrect];

        // Map Type Label:
        myY += (2.0 * ptLabelHeight);
        myrect= CGRectMake(myX, myY + myYSpacer, labelWidth, ptLabelHeight);
        [mapTypeLabel setFrame:myrect];
        
        // Map Type Segmented Control:
        myY += (2.0 * ptLabelHeight);
        myrect = CGRectMake( myX, myY, screenWidth - (myX + ptRightMargin), ptSegmentedControlHeight);
        [mapTypeSegmentedControl setFrame:myrect];
        
        // User Tracking Label:
        myY += (2.0 * ptLabelHeight);
        myrect= CGRectMake(myX, myY + myYSpacer, labelWidth, ptLabelHeight);
        [userTrackingLabel setFrame:myrect];
        
        // User Tracking Segmented Control:
        myY += (2.0 * ptLabelHeight);
        myrect = CGRectMake( myX, myY, screenWidth - (myX + ptRightMargin), ptSegmentedControlHeight);
        [userTrackingSegmentedControl setFrame:myrect];
        
        // Display Speed Label:
        myY += (2.0 * ptLabelHeight);
        myrect= CGRectMake(myX, myY + myYSpacer, labelWidth, ptLabelHeight);
        [displaySpeedLabel setFrame:myrect];
        
        // Display Speed  Segmented Control:
        myY += (2.0 * ptLabelHeight);
        myrect = CGRectMake( myX, myY, screenWidth - (myX + ptRightMargin), ptSegmentedControlHeight);
        [displaySpeedSegmentedControl setFrame:myrect];
        
        // Display Distace Label:
        myY += (2.0 * ptLabelHeight);
        myrect= CGRectMake(myX, myY + myYSpacer, labelWidth, ptLabelHeight);
        [displayDistanceLabel setFrame:myrect];
        
        // Display Distance  Segmented Control:
        myY += (2.0 * ptLabelHeight);
        myrect = CGRectMake( myX, myY, screenWidth - (myX + ptRightMargin), ptSegmentedControlHeight);
        [displayDistanceSegmentedControl setFrame:myrect];
        
        // Distance Filter Label:
        myY += (2.0 * ptLabelHeight);
        myrect= CGRectMake(myX, myY + myYSpacer, labelWidth, ptLabelHeight);
        [distanceFilterLabel setFrame:myrect];
        
        // Distance Filter Slider Control:
        myY += (2.0 * ptLabelHeight);
        myrect = CGRectMake( myX, myY, screenWidth - (myX + ptRightMargin), ptSegmentedControlHeight);
        [distanceFilterSliderCtl setFrame:myrect];
        
        // Accuracy Filter Label:
        myY += (2.0 * ptLabelHeight);
        myrect= CGRectMake(myX, myY + myYSpacer, labelWidth, ptLabelHeight);
        [accuracyFilterLabel setFrame:myrect];
        
        // Accuracy Filter Segmented Control:
        myY += (2.0 * ptLabelHeight);
        myrect = CGRectMake( myX, myY, screenWidth - (myX + ptRightMargin), ptSegmentedControlHeight);
        [accuracyFilterSegmentedControl setFrame:myrect];
        
        // Toggle Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [toggleLabel setFrame:myrect];
        
        // Location Switch Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [locationLabel setFrame:myrect];
        
        // Location Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [locationSwitch setFrame:myrect];
        
        // Picture Switch Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [pictureLabel setFrame:myrect];
        
        // Picture Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [pictureSwitch setFrame:myrect];
        
        // Stop Switch Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [stopLabel setFrame:myrect];
        
        // Stop Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [stopSwitch setFrame:myrect];
        
        // OdoMeter Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [odoMeterLabel setFrame:myrect];
        
        // Odometer Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [odoMeterSwitch setFrame:myrect];

        // Trip Meter Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [tripMeterLabel setFrame:myrect];
        
        // Trip Meter  Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [tripMeterSwitch setFrame:myrect];

        // Slider Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [sliderLabel setFrame:myrect];
        
        // Slider  Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [sliderSwitch setFrame:myrect];

        // SpeedOMeter Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [speedOMeterLabel setFrame:myrect];
        
        // SpeedOMeter  Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [speedOMeterSwitch setFrame:myrect];
        
        // Propeties Sync Switch Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [syncLabel setFrame:myrect];

        // Propeties Sync Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [syncSwitch setFrame:myrect];
        
        // Google Drive Enabled Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [googleDriveEnabledLabel setFrame:myrect];
        
        // Google Drive Enabled Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [googleDriveEnabledSwitch setFrame:myrect];
        
        // Google Drive Path Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [googleDrivePathLabel setFrame:myrect];
        
        // Google Drive Path Text Box
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [googleDrivePathField setFrame:myrect];
        
        // Photo Count Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [photoCountLabel setFrame:myrect];
        
        // Photo Count Text Box
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [photoCountField setFrame:myrect];;

        // Reset Button
        CGFloat buttonX = (screenWidth - (myX + ptRightMargin + 100.0)) / 2.0;
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(buttonX, myY+myYSpacer, 100.0, ptSegmentedControlHeight);
        [resetButton setFrame:myrect];
        
        // Version Label
        myY += ptSegmentedControlHeight + (SPACING * 2);
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [versionLabel setFrame:myrect];

    }


    return;
}


@end
