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
            toggleLabel, locationLabel, locationSwitch, pictureLabel, pictureSwitch, stopLabel, stopSwitch, infoBarLabel, infoBarSwitch, speedBarSwitch, speedBarLabel,
            resetButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = [titleField text];
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
-(void) viewDidDisappear {
    // Request to stop receiving accelerometer events and turn off accelerometer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
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
    NSLog(@"New Name: [%@]",textField);
    
    NSString *mytext = [textField text];
    mytext = [mytext stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"my title: [%@]",mytext);
    [[NSUserDefaults standardUserDefaults] setValue:mytext forKey:@KEY_NAME];
    
    // set the new value to the cloud and synchronize
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setString:mytext forKey:@KEY_NAME];
    
    [self setTitle:mytext];
    
    [titleField resignFirstResponder]; // and hides the keyboard
    return YES;
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
//
// User Tracking Mode
- (void)segmentUserTypeAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:[sender selectedSegmentIndex] forKey:@KEY_USER_TRACKING_MODE];
    
    // set the new value to the cloud and synchronize
    NSString *tmp = [[NSString alloc] initWithFormat:@"%ld", (long)[sender selectedSegmentIndex]];
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setString:tmp forKey:@KEY_USER_TRACKING_MODE];
}

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
    
    // set the new value to the cloud and synchronize
    int i = (int) myMapType;
    NSString *tmp = [[NSString alloc] initWithFormat:@"%d", i];
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setString:tmp forKey:@KEY_MAP_TYPE];
    // NSLog(@"%@:%@",@KEY_PT_MAP_TYPE,tmp);
    
}

- (void)sliderAction:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    // NSLog(@"sliderAction: value = %f", [slider value]);
    
    CLLocationDistance myDist = [slider value]; // - ([slider value] / 5.0);
    if (myDist < 10.0)
        myDist = 5.0;
    else {
        CLLocationDistance trim = fmodf(myDist,10.0);
        myDist -= trim;
    }
    
    NSString *title = [[NSString alloc] initWithFormat:@"Distance Filter: %.1f m",myDist] ;
    
    [distanceFilterLabel setText:title];
    
    [[NSUserDefaults standardUserDefaults] setFloat:myDist forKey:@KEY_DISTANCE_FILTER];
    
    // set the new value to the cloud and synchronize
    NSString *tmp = [[NSString alloc] initWithFormat:@"%f", myDist];
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setString:tmp forKey:@KEY_DISTANCE_FILTER];
}

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
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger: myDisplaySpeedUnit forKey:@KEY_SPEED_UNITS];
    
    // set the new value to the cloud and synchronize
    NSString *tmp = [[NSString alloc] initWithFormat:@"%d", myDisplaySpeedUnit];
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setString:tmp forKey:@KEY_SPEED_UNITS];
}

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
    
    // set the new value to the cloud and synchronize
    NSString *tmp = [[NSString alloc] initWithFormat:@"%d", myDisplaySpeedUnit];
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setString:tmp forKey:@KEY_DISTANCE_UNITS];
}
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
    
    // set the new value to the cloud and synchronize
    NSString *tmp = [[NSString alloc] initWithFormat:@"%f", myLocationAccuracy];
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setString:tmp forKey:@KEY_LOCATION_ACCURACY];
    // NSLog(@"%@:%@",@KEY_PT_LOCATION_ACCURACY,tmp);
}

//
-(void) ptSwitchSelector:(id)sender
{
    // NSLog(@"%@",sender);
    // NSLog(@"Tag: %d",[sender tag]);
    UISwitch *toggleOnOffSwitch = (UISwitch *)sender;
    BOOL yn = toggleOnOffSwitch.isOn;
    NSString *keyvalue = NULL;
    
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
            keyvalue = @KEY_SHOW_SPEED_LABEL;
            break;
            
        case ptSound:
            keyvalue = @KEY_SHOW_INFO_LABEL;
            break;
            
        default:
            NSLog(@"ERROR: Unknown Sender Tag for pt types");
            break;
    }
    
    if (keyvalue) {
        [[NSUserDefaults standardUserDefaults] setBool:yn forKey:keyvalue];
        
        // set the new value to the cloud and synchronize
        
        NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
        if (yn)
            [kvStore setString:@"YES" forKey:keyvalue];
        else
            [kvStore setString:@"NO" forKey:keyvalue];
        
        // NSLog(@"%@:%c",keyvalue,yn);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
        NSLog(@"Yes");
        NSString *mytext = @TRAILS_ON_A_MAP;
        NSLog(@"my title: [%@]",mytext);
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
    NSLog(@"Button  clicked.");
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
    NSArray *pebbleTypeText = [NSArray arrayWithObjects: @"Locations:",@"Pictures:", @"Stops:",@"Speed Time:",@"Distance Info:", nil];
    NSArray *displaySpeedText = [NSArray arrayWithObjects:@"M P H",@"K P H",@"M P M",@"M P S", nil]; // Miles per Hour, KM per Hour, Min / Mile, Meters / Sec
    NSArray *displayDistanceText = [NSArray arrayWithObjects:@"Miles",@"Kilometers", @"Meters", @"Feet", nil];
    
    UIFont *myLabelFont = [UIFont fontWithName: @TOM_FONT size: 12.0 ];
    UIFont *myTitleFont = [UIFont fontWithName: @TOM_FONT size: 12.0 ];

    //  A better way to do this...
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect myrect = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    
    // UIScrollView *scrollView
    scrollView = [[UIScrollView alloc] initWithFrame:myrect];
    [scrollView setScrollEnabled:YES];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    //
    // The key to making the scrollable window now bounce is these next two lines of code.
    // The size (mysize.y in this case) has to be bigger than the CGRect created for scrollView.
    //
    CGSize mysize = CGSizeMake(screenRect.size.width, screenRect.size.height+TOM_PVC_EXTRA);
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
    titleField.borderStyle = UITextBorderStyleRoundedRect;
    titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [titleField setDelegate:self];  // set up the delegate
    [titleField setFont:myTitleFont];
    titleField.backgroundColor = [UIColor whiteColor];

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
    
    CLLocationDistance myLocationDistace;
    // Had to get the value now so it can be displayed in the distance filter title.
    CLLocationDistance myDistanceFilter = [TOMDistance distanceFilter];
    
	// label.textAlignment = UITextAlignmentLeft;
    NSString *title = [[NSString alloc] initWithFormat:@"Distance Filter: %.1f",myDistanceFilter] ;
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
    
    distanceFilterSliderCtl.value = myLocationDistace;
    
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
        myLocationAccuracy = [[NSUserDefaults standardUserDefaults] floatForKey:@KEY_LOCATION_ACCURACY];
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
    
    for (POMType pt = ptLocation; pt <= ptSound; pt++ )
    {
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
                speedBarSwitch = ptSwitch;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SHOW_SPEED_LABEL] != nil)
                {
                    yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SHOW_SPEED_LABEL];
                }
                else
                {   //
                    // we don't have a preference stored on this device,use the YES as default.
                    //
                    yn = YES;  // default
                }
                frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
                speedBarLabel = [TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]];
                [speedBarLabel setFont:myLabelFont];
                [speedBarLabel setTextAlignment:NSTextAlignmentRight];
                [scrollView addSubview:speedBarLabel];
                break;
                
            case ptSound:
                infoBarSwitch = ptSwitch;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SHOW_INFO_LABEL] != nil)
                {
                    yn = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_SHOW_INFO_LABEL];
                }
                else
                {   //
                    // we don't have a preference stored on this device,use the YES as default.
                    //
                    yn =YES;  // default
                }
                frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
                infoBarLabel = [TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]];
                [infoBarLabel setFont:myLabelFont];
                [infoBarLabel setTextAlignment:NSTextAlignmentRight];
                [scrollView addSubview:infoBarLabel];
                break;
                
            default:
                yn = NO;  // default
                break;
        }
        
        [ptSwitch setOn:yn];
        
        [scrollView addSubview:ptSwitch];
        
        // frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
        // [scrollView addSubview:[TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]]];
    }
    
    frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
    
    resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [resetButton setFrame:frame];
    [resetButton setTitle:@"RESET" forState:UIControlStateNormal];
    [resetButton addTarget:self
               action:@selector(resetTOM:)
     forControlEvents:UIControlEventTouchDown];
    [resetButton.layer setBorderColor:TOM_LABEL_BORDER_COLOR];
    [resetButton.layer setBorderWidth:1.0];
    [resetButton.layer setShadowOffset:CGSizeMake(5, 5)];
    [resetButton.layer setShadowColor:TOM_LABEL_BORDER_COLOR];
    [resetButton.layer setShadowOpacity:0.5];
    resetButton.layer.borderWidth  = TOM_LABEL_BORDER_WIDTH;
    resetButton.layer.cornerRadius = TOM_LABEL_BORDER_CORNER_RADIUS;
    
    [scrollView addSubview:resetButton];

    NSLog( @"Height So Far: %.2f", yPlacement);
    //
}


- (void)orientationPropertiesChanged:(NSNotification *)notification
{
    // Respond to changes in device orientation
    if (notification)
        NSLog(@"Orientation Changed! %@",notification);
    else
        NSLog(@"Orientation Changed! (nil)");

    UIInterfaceOrientation uiOrientation = [[UIApplication sharedApplication] statusBarOrientation];

#ifdef __NUA__
    //
    // I found device orientation in this case unreliagle where UI Orientation worked like I wanted.
    //
    UIDeviceOrientation devOrientation = [[UIDevice currentDevice] orientation];

    currentDeviceOrientation = devOrientation;
    

    if (devOrientation == UIDeviceOrientationFaceUp ||
        devOrientation == UIDeviceOrientationFaceDown ||
        /* devOrientation == UIDeviceOrientationUnknown || */
        devOrientation == UIDeviceOrientationPortraitUpsideDown ||  // having issues understanding why i cant get upside down to work ?
        currentDeviceOrientation == devOrientation) {
        return;
    }
#endif

    if ((UIInterfaceOrientationIsLandscape(currentInterfaceOrientation) && UIInterfaceOrientationIsLandscape(uiOrientation)) ||
        (UIInterfaceOrientationIsPortrait(currentInterfaceOrientation) && UIInterfaceOrientationIsPortrait(uiOrientation))) {
        //still saving the current orientation ?
        currentInterfaceOrientation = uiOrientation;
        return;
    }
 
    // currentOrientation = orientation;

    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    if (UIInterfaceOrientationIsLandscape(uiOrientation)) {
        screenHeight = screenRect.size.width;
        screenWidth = screenRect.size.height;
    }
    
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
        
        // Speed Bar Switch Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [speedBarLabel setFrame:myrect];
        
        // Speed Bar Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [speedBarSwitch setFrame:myrect];
        
        // Info Bar Switch Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [infoBarLabel setFrame:myrect];
        
        // Info Bar Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [infoBarSwitch setFrame:myrect];
        
        // Reset Button
        CGFloat buttonX = (screenWidth - (myX + ptRightMargin + 100.0)) / 2.0;
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(buttonX, myY+myYSpacer, 100.0, ptSegmentedControlHeight);
        [resetButton setFrame:myrect];
        
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
        
        // Speed Bar Switch Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [speedBarLabel setFrame:myrect];
        
        // Speed Bar Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [speedBarSwitch setFrame:myrect];
        
        // Info Bar Switch Label
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(myX, myY+myYSpacer, labelWidth, ptLabelHeight);
        [infoBarLabel setFrame:myrect];
        
        // Info Bar Switch
        myrect = CGRectMake(myX + labelWidth + SPACING, myY, actorWidth, ptSegmentedControlHeight);
        [infoBarSwitch setFrame:myrect];
        
        // Reset Button
        CGFloat buttonX = (screenWidth - (myX + ptRightMargin + 100.0)) / 2.0;
        myY += ptSegmentedControlHeight + SPACING;
        myrect= CGRectMake(buttonX, myY+myYSpacer, 100.0, ptSegmentedControlHeight);
        [resetButton setFrame:myrect];
    }
    

    return;
}


@end
