//
//  TOMPropertyViewController.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/19/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMPropertyViewController.h"


@interface TOMPropertyViewController ()

@end

@implementation TOMPropertyViewController

@synthesize titleField, distanceFilterLabel,accuracyFilterLabel;

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
    [self createControls];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//

+ (UILabel *)labelWithFrame:(CGRect)frame title:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    
	// label.textAlignment = UITextAlignmentLeft;
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:17.0];
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

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#pragma mark -
#pragma mark UISegmentControlStyleBordered


- (void)createControls
{
    
    NSArray *segmentTextContent  = [NSArray arrayWithObjects: @"Standard", @"Satellite", @"Hybrid", nil];
    NSArray *segmentUserTracking = [NSArray arrayWithObjects: @"None", @"Follow", @"Heading", nil];
    NSArray *accuracyTextContent = [NSArray arrayWithObjects: @"Nav", @"Best", @"10m", @"100m", @"1km", @"3km" , nil];
    NSArray *pebbleTypeText = [NSArray arrayWithObjects: @"Location",@"Pictures", @"Stops",@"Speed Bar",@"Info Bar", nil];
    
    //  A better way to do this...
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect myrect = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height+200);
    
    // UIScrollView *scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:myrect];
    [scrollView setScrollEnabled:YES];
    
    //
    // The key to making the scrollable window now bounce is these next two lines of code.
    // I think the size has to be bigger than the CGRect created for scrollView.
    //
    CGSize mysize = CGSizeMake(screenRect.size.width, screenRect.size.height+500);
    [scrollView setContentSize:mysize];
    // features...
    [scrollView setAlwaysBounceVertical:YES];
    [scrollView setShowsHorizontalScrollIndicator:YES];
    [scrollView setScrollsToTop:NO];
    // [scrollView setDelegate:self];
    [self.view addSubview:scrollView];
    
    int objectWidth = screenRect.size.width;
    objectWidth -= (ptRightMargin)  ;
    
    // Title UITextInput
	CGFloat yPlacement = ptTopMargin; // for starters...
	CGRect frame = CGRectMake(	ptLeftMargin, yPlacement, 100, ptLabelHeight);
    [scrollView addSubview:[TOMPropertyViewController labelWithFrame:frame title:@"Title:"]];
    
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
    
    titleField.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:titleField];
    
    // Map Type Label
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptLabelHeight;
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptLabelHeight);
	[scrollView addSubview:[TOMPropertyViewController labelWithFrame:frame title:@"Map Type:"]];
	// control
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
    
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptLabelHeight;
    
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
	segmentedControl.frame = frame;
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
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
            segmentedControl.selectedSegmentIndex = 0;
            break;
        case MKMapTypeSatellite:
            segmentedControl.selectedSegmentIndex = 1;
            break;
        case MKMapTypeHybrid:
            segmentedControl.selectedSegmentIndex = 2;
            break;
        default:
            NSLog(@"ERROR: Invalid or Unknown ptMapType");
            break;
    }
	
	[scrollView addSubview:segmentedControl];
    
    // User Tracking Mode...
    // label
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptSegmentedControlHeight - 5;
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    
    [scrollView addSubview:[TOMPropertyViewController labelWithFrame:frame title:@"User Tracking Mode:"]];
    
    // mode controller.
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptLabelHeight + 10;
    segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentUserTracking];
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    segmentedControl.frame = frame;
	[segmentedControl addTarget:self action:@selector(segmentUserTypeAction:) forControlEvents:UIControlEventValueChanged];
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
            segmentedControl.selectedSegmentIndex = 0;
            break;
        case MKUserTrackingModeFollow:
            segmentedControl.selectedSegmentIndex = 1;
            break;
        case MKUserTrackingModeFollowWithHeading:
            segmentedControl.selectedSegmentIndex = 2;
            break;
        default:
            NSLog(@"ERROR: Invalid or Unknown ptUserTrackingMode");
            break;
    }
    [scrollView addSubview:segmentedControl];
    
    
    // Distance Filter ...
    // label
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptSegmentedControlHeight;
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    
    CLLocationDistance myLocationDistace;
    // Had to get the value now so it can be displayed in the distance filter title.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_DISTANCE_FILTER] != nil)
    {
        myLocationDistace = [[NSUserDefaults standardUserDefaults] floatForKey:@KEY_DISTANCE_FILTER];
    }
    else
    {   //
        // we don't have a preference stored on this device,use the Tracking Mode None as default.
        //
        myLocationDistace = 50.0;  // default
    }
    
	// label.textAlignment = UITextAlignmentLeft;
    NSString *title = [[NSString alloc] initWithFormat:@"Distance Filter: %.1f",myLocationDistace] ;
    distanceFilterLabel = [TOMPropertyViewController labelWithFrame:frame title:title];
    [scrollView addSubview:distanceFilterLabel];
    
    // slider bar controller
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptLabelHeight + 10;
    frame = CGRectMake( ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    
    UISlider *sliderCtl = [[UISlider alloc] initWithFrame:frame];
    [sliderCtl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    // in case the parent view draws with a custom color or gradient, use a transparent color
    sliderCtl.backgroundColor = [UIColor clearColor];
    
    sliderCtl.minimumValue = 5.0;
    sliderCtl.maximumValue = 1000.0;
    sliderCtl.continuous = YES;
    
    sliderCtl.value = myLocationDistace;
    
    // Add an accessibility label that describes the slider.
    [sliderCtl setAccessibilityLabel:NSLocalizedString(@"Distance Filter", @"")];
    [scrollView addSubview:sliderCtl];
    
    //
    //  Map Accuracy Controller
    //
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptSegmentedControlHeight - 15;
    frame = CGRectMake(	ptLeftMargin,
                       yPlacement, objectWidth,
                       ptSegmentedControlHeight);
    
    accuracyFilterLabel = [TOMPropertyViewController labelWithFrame:frame title:@"Accuracy:"];
    [scrollView addSubview:accuracyFilterLabel];
    
    //
    // Location Accuracy Filter
    //
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptLabelHeight + 10;
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:accuracyTextContent];
    frame = CGRectMake(	ptLeftMargin,yPlacement, objectWidth,ptSegmentedControlHeight);
    segmentedControl.frame = frame;
	[segmentedControl addTarget:self action:@selector(segmentAccuracyAction:) forControlEvents:UIControlEventValueChanged];
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
        segmentedControl.selectedSegmentIndex = 0;
    }
    else if (myLocationAccuracy == kCLLocationAccuracyBest)
    {
        segmentedControl.selectedSegmentIndex = 1;
    }
    else if (myLocationAccuracy == kCLLocationAccuracyNearestTenMeters)
    {
        segmentedControl.selectedSegmentIndex = 2;
    }
    else if (myLocationAccuracy == kCLLocationAccuracyHundredMeters)
    {
        segmentedControl.selectedSegmentIndex = 3;
    }
    else if (myLocationAccuracy == kCLLocationAccuracyKilometer)
    {
        segmentedControl.selectedSegmentIndex = 4;
    }
    else if (myLocationAccuracy == kCLLocationAccuracyThreeKilometers)
    {
        segmentedControl.selectedSegmentIndex = 5;
    }
    else  // Something didn't go quite right, set it to the default of accuracy best:
        segmentedControl.selectedSegmentIndex = 1;
    
    // add the subview...
    [scrollView addSubview:segmentedControl];
    
    
    // Add Point Type Toggles
    yPlacement += (ptTweenMargin * ptTweenMarginMultiplier) + ptSegmentedControlHeight - 10;
    frame = CGRectMake(	ptLeftMargin, yPlacement, objectWidth, ptSegmentedControlHeight);
    
    [scrollView addSubview:[TOMPropertyViewController labelWithFrame:frame title:@"Toggle Annotations:"]];
    
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
                break;
                
            case ptPicture:
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
                break;
                
            case ptStop:
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
                break;
                
            case ptNote:
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
                break;
                
            case ptSound:
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
                
                break;
                
            default:
                yn = NO;  // default
                break;
        }
        
        [ptSwitch setOn:yn];
        
        [scrollView addSubview:ptSwitch];
        
        frame = CGRectMake(	ptLeftMargin + 100, yPlacement - 5 , objectWidth, ptSegmentedControlHeight);
        [scrollView addSubview:[TOMPropertyViewController labelWithFrame:frame title:[pebbleTypeText objectAtIndex:(pt-1)]]];
    }
    
    // NSLog( @"Height So Far: %.2f", yPlacement);
    //
}



@end
