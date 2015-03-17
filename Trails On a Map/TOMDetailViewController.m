//
//  TOMDetailViewController.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/1/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMDetailViewController.h"
#import "TOMImageViewController.h"
#import "pssGPX/pssGPX.h"
#import "pssKML/pssKML.h"
#import "pssZipKit/pssZipKit.h"

@interface TOMDetailViewController ()

@end

@implementation TOMDetailViewController

@synthesize theTrail, titleField, gpxSwitch, kmlSwitch, query, activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//
// * * * * * * * * * * * * * * * * * * *
//

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *) t
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = t;

        headerLabelFont = [UIFont fontWithName: @TOM_FONT size: 14.0 ];
        footerLabelFont = [UIFont fontWithName: @TOM_FONT size: 10.0 ];
        
       
    }
    return self;
}

//
// * * * * * * * * * * * * * * * * * * *
//

- (void)viewDidLoad
{
    [super viewDidLoad];

    BOOL usingIcloud = NO;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_ICLOUD] != nil)
    {
        usingIcloud = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_ICLOUD];
    }
    else // If we don't know, we're not.
        usingIcloud = NO;
    
    if (usingIcloud) {
        [self prepareImageFiles];
    }
    
    if (![self isActiveTrail]) {
        editAndDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editClicked:)];
        self.navigationItem.rightBarButtonItem = editAndDoneButton;
    }
    
    amIediting = NO;
    
    //
    // load the selected map
    //
    NSFileManager *fm = [[NSFileManager alloc] init];
    // NSFileManager *fm = [NSFileManager new];
    
    NSURL *fileURL = [TOMUrl urlForFile:self.title key:self.title  ];
    
    theTrail = [[TOMPomSet alloc] initWithFileURL:fileURL];
    if ([fm fileExistsAtPath:[fileURL path]]) {
        [theTrail loadFromContents:fileURL ofType:nil error:nil];
    }
    
    imagesSet = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [theTrail.ptTrack count]; i++ ) {
        TOMPointOnAMap *p = [theTrail.ptTrack objectAtIndex:i];
        if ([p type] == ptPicture) {
            
            UIImage *myImage = [TOMImageStore loadImage:self.title key:[p key] warn:NO];

            TOMOrganizerViewCell *myCell = [[TOMOrganizerViewCell alloc] init];
            [myCell setTitle:[p key]];
            [myCell setUrl:[TOMUrl urlForImageFile:self.title key:[p key]]];

            if (myImage == NULL) {
                if (usingIcloud)
                    myImage = [UIImage imageNamed:@"Icon-ios7-cloud-download-outline-128.png"];
                else
                    myImage = [UIImage imageNamed:@"TomIcon-60@2x.png"];
                // [myCell setImage:myImage];
            }
            else {
                myImage = [TOMImageStore loadIcon:theTrail.title key:[p key] size:CGSizeMake(120.0f, 120.0f)];
            } // else
            
        [p setImage:myImage];
        [imagesSet addObject:p];
        } // for
    }

    // Do any additional setup after loading the view from its nib.
    // CGRect screenRect = [[UIScreen mainScreen] bounds];
    detailTable = [[ UITableView alloc] initWithFrame: self.view.bounds style:UITableViewStyleGrouped];
 
    // basics
    detailTable.delegate = self;
   
    // register the class
    [detailTable registerClass:[UITableViewCell class] forCellReuseIdentifier:detailViewCellIdentifier];
    [detailTable setDataSource:self];
    
    // Make sure the table resizes correctly
    // detailTable.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    // finally attach it to the view
    
    [self.view addSubview: detailTable ];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    // CGFloat screenWidth = screenRect.size.width;
    self.activityIndicator.center = self.view.center;
    [activityIndicator hidesWhenStopped];
    [activityIndicator setFrame:CGRectMake(140, 240, 40, 40)];
    [self.view addSubview:activityIndicator];
    [self.view bringSubviewToFront:activityIndicator];
    
    // Push an orientation change call now
    orientation = UIDeviceOrientationUnknown;


}

-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self orientationChanged:NULL];
    //
    // Set up notifications
    //
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
-(void) viewWillDisappear:(BOOL)animated {
    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        if ([theTrail hasUnsavedChanges]) {
            [activityIndicator startAnimating];  // this is a non op since activtyIndicator is on the screen that's about to disappear.
            [theTrail closeWithCompletionHandler:^(BOOL success) {
                // NSLog(@"Success: %d",success);
                [activityIndicator stopAnimating];
            } ];
        //    NSLog(@"%s Yes There were unsaved Changes",__PRETTY_FUNCTION__);
        }
        // else {
        //    NSLog(@"%s No There are no unsaved changes",__PRETTY_FUNCTION__);
        // }
    }
   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    if (query) {
        if ([query isStarted] || [query isGathering]) {
            [query stopQuery];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSMetadataQueryDidFinishGatheringNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSMetadataQueryDidUpdateNotification
                                                      object:nil];
    }

    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// * * * * * * * * * * * * * * * * * * *

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([tableView isEqual:detailTable]) {
        return 3;
    }
    else {
        NSLog(@"ERROR: %s:%d Invalid table view passed:%@", __PRETTY_FUNCTION__, __LINE__ , tableView);
        return 0;
    }
}

// * * * * * * * * * * * * * * * * * * *

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if ([tableView isEqual:detailTable]) {
        switch (section) {
            case 0: // Trail Properties (currently Name, GPX, KML)
                return 3;
                break;
            case 1: // Trail Pictures;

                picCount = [theTrail numPics];
                // NSLog(@"%s Num Pics: %d",__PRETTY_FUNCTION__,(int)picCount);
                if (picCount == 0 )
                    return 1;
                else
                    return picCount;
                break;
                
            case 2: // Trail Details
                return 5;
            default:
                break;
        }
    }

    NSLog(@"ERROR: %s:%d Invalid table view passed:%@", __PRETTY_FUNCTION__, __LINE__ , tableView);
    return 0;
    
}

// * * * * * * * * * * * * * * * * * * *

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TOMOrganizerViewCell *cell = nil;
    
    if ([tableView isEqual:detailTable]) {
        
        NSURL *docsdirURL = [TOMUrl urlForDocumentsDirectory];
        NSString *fileName = nil; // [NSString stringWithFormat:@"%@.gpx",self.title];
        NSURL *fileFullURL = nil;
        
        cell = [tableView dequeueReusableCellWithIdentifier:detailViewCellIdentifier forIndexPath:indexPath];
        // Since the cells can get reused and
        // their variables are not cleaned.  We need to do it ourselves:
        cell.imageView.image = nil;
        cell.accessoryView = nil;
        cell.textLabel.font = headerLabelFont;
        
        CGRect screenRect;
        [TOMUIUtilities screenRect:&screenRect];
        CGFloat screenWidth = screenRect.size.width;
        
        switch (indexPath.section)  {
            case 0:
            {
                if (indexPath.row == 0 ) {
                    // Text edit box to rename the trail
                    cell.textLabel.text = @"Title:";
                    cell.accessoryView = titleField;
                    
                    titleField = [[ UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, (screenWidth - 80.0), 35.0f)];
                    [titleField addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventValueChanged];
                    [titleField setDelegate:self];  // set up the delegate
                    [titleField setFont:headerLabelFont];
                    [titleField setBackgroundColor:[UIColor whiteColor]];
                    [titleField setText:[self title]];
                    [titleField setTag:detailViewTagTitle];

                    if ([self isActiveTrail]) {
                        titleField.textColor = [UIColor redColor];
                    }
                    else {
                        if (amIediting) {
                            titleField.borderStyle = UITextBorderStyleRoundedRect;
                        }
                        else {
                            titleField.borderStyle = UITextBorderStyleNone;
                        }
                        titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
                        titleField.autocorrectionType = UITextAutocorrectionTypeNo;
                        titleField.textColor = [UIColor blackColor];
                    }
                    cell.accessoryView = titleField;
                }
                else if (indexPath.row == 1) {
                    CGRect switchFrame = CGRectMake( 0.0f, 0.0f, 150.0f, 25.0f );
                    UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:switchFrame];
                    [aSwitch setOn:NO];
                    [aSwitch addTarget:self action:@selector(dvcSwitchSelector:) forControlEvents:UIControlEventValueChanged];
                    cell.textLabel.text = @"Save Trail as GPX";
                    gpxSwitch = aSwitch;
                    [gpxSwitch setTag: GPX_SWITCH_TAG];
                    cell.accessoryView = gpxSwitch;
                    
                    // docsdirURL = [TOMUrl urlForDocumentsDirectory];
                    fileName = [NSString stringWithFormat:@"%@.gpx",self.title];
                    fileFullURL = [docsdirURL URLByAppendingPathComponent:fileName isDirectory:NO];
                    
                    if ([TOMUrl checkDirectory:fileFullURL create:NO]) {
                        [gpxSwitch setOn:YES];
                    }
                }
                else if (indexPath.row == 2) {
                    CGRect switchFrame = CGRectMake( 0.0f, 0.0f, 150.0f, 25.0f );
                    UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:switchFrame];
                    [aSwitch setOn:NO];
                    [aSwitch addTarget:self action:@selector(dvcSwitchSelector:) forControlEvents:UIControlEventValueChanged];
                    cell.textLabel.text = @"Save Trail as KMZ";
                    kmlSwitch = aSwitch;
                    cell.accessoryView = kmlSwitch;
                    [kmlSwitch setTag:KML_SWITCH_TAG];
                    // docsdirURL = [TOMUrl urlForDocumentsDirectory];
                    fileName = [NSString stringWithFormat:@"%@.kmz",self.title];
                    fileFullURL = [docsdirURL URLByAppendingPathComponent:fileName isDirectory:NO];
                    
                    if ([TOMUrl checkDirectory:fileFullURL create:NO]) {
                        [kmlSwitch setOn:YES];
                    }
                }
                else {
                    NSLog(@"%s ERROR FFU Cell Reached",__PRETTY_FUNCTION__);
                    cell.textLabel.text = [ NSString stringWithFormat:@"FFU Section %ld, Cell %ld",(long)indexPath.section,(long)indexPath.row];
                }
                break;
            }
            case 1:
                if (picCount == 0)
                {
                    cell.textLabel.text = @"No Pictures in Trail";
                }
                else {
                    TOMPointOnAMap *p = [imagesSet objectAtIndex:(long)indexPath.row];
                    
                    cell.imageView.image = [p image];
                    cell.imageView.layer.cornerRadius = TOM_LABEL_BORDER_CORNER_RADIUS;
                    
                    if (amIediting) {
                        UITextField *ptextField = [[UITextField alloc]initWithFrame:CGRectMake(0.0, 0.0, (screenWidth - 80.0), 35.0f)];
                        [ptextField addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventValueChanged];
                        [ptextField setDelegate:self];  // set up the delegate
                        [ptextField setFont:headerLabelFont];
                        [ptextField setBackgroundColor:[UIColor whiteColor]];
                        [ptextField setText:[p title]];
                        [ptextField setTag:indexPath.row];
                        [ptextField setBorderStyle:UITextBorderStyleRoundedRect];

                        ptextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                        ptextField.autocorrectionType = UITextAutocorrectionTypeNo;
                        ptextField.textColor = [UIColor blackColor];
                      
                        cell.textLabel.text =  @"Photo:";
                        cell.accessoryView = ptextField;
                    }
                    else {
                        cell.textLabel.text =  [p title];
                        cell.accessoryType = UITableViewCellAccessoryDetailButton;
                        if (![p image]) {
                            p.image = [TOMImageStore loadIcon:theTrail.title key:[p key] size:CGSizeMake(120.0f, 120.0f)];
                        }
                        cell.imageView.image = [p image];
                    }
                }
                break;

            case 2:
                if (indexPath.row == 0) {
                    double totalDistance = [TOMDistance displayDistance:[theTrail distanceTotalMeters]];
                    cell.textLabel.text = [ NSString stringWithFormat:@"Total Distance: %.02f %@",totalDistance,[TOMDistance displayDistanceUnits]];
                }
                else if (indexPath.row == 1) {
                    double straightLineDistance = [TOMDistance displayDistance:[theTrail distanceStraightLine]];
                    cell.textLabel.text = [ NSString stringWithFormat:@"Straight Line Distance: %.02f %@",straightLineDistance,[TOMDistance displayDistanceUnits]];
                }
                else if (indexPath.row == 2) {
                    cell.textLabel.text = [ NSString stringWithFormat:@"Elapse Time: %@",[theTrail elapseTimeString]];
                }
                else if (indexPath.row == 3) {
                    cell.textLabel.text = [ NSString stringWithFormat:@"Avg Speed Total Dist: %.02f %@",[TOMSpeed displaySpeed:[theTrail averageSpeed]],[TOMSpeed displaySpeedUnits]];
                }
                else if (indexPath.row == 4) {
                    cell.textLabel.text = [ NSString stringWithFormat:@"Avg Speed SL Dist: %.02f %@",[TOMSpeed displaySpeed:[theTrail averageSpeedStraightLine]],[TOMSpeed displaySpeedUnits]];
                }
                else {
                    cell.textLabel.text = [ NSString stringWithFormat:@"Detail Cell %ld",(long)indexPath.row];
                }
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            
            default:
                cell.textLabel.text = [ NSString stringWithFormat:@"Section %ld, Cell %ld",(long)indexPath.section,(long)indexPath.row];
                break;
        }
    }

    return cell;
}
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// Section for Headers and Footers
//
- (UILabel *) newLabelWithTitle:(NSString *)paramTitle {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = paramTitle;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    return label;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *text = nil;
    
    switch (section)
    {
        case 0:
            text = [[NSString alloc] initWithFormat:@"Trail Properties"];
            break;
        case 1:
            text = [[NSString alloc] initWithFormat:@"Trail Photos"];
            break;
        case 2:
            text = [[NSString alloc] initWithFormat:@"Trail Details"];
            break;
        default:
            text = [[NSString alloc] initWithFormat:@"Section %ld Header",(long)section ];
            break;
    }

    UILabel *label = [self newLabelWithTitle: text];

    label.frame = CGRectMake(label.frame.origin.x+10.0f, 5.0f, label.frame.size.width, label.frame.size.height);
    label.font = headerLabelFont;
    [label setTextAlignment:NSTextAlignmentCenter];
    // Give the container view 10 poionts more in width than our label
    // becuause the lable needs a 10 extra points left-margin
    CGRect resultFrame = CGRectMake(0.0f, 0.0f, label.frame.size.width+10.0f, label.frame.size.height+20);
    UIView *header = [[UIView alloc] initWithFrame:resultFrame];
    [header addSubview:label];
    return header;
    
}


- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
 
    if (section == 0 ) {
        if ([self isActiveTrail]) {
            
            NSString *text = @"Note: You have selected the current trail and cannot rename it";
            UILabel *label = [self newLabelWithTitle: text];
    
            label.frame = CGRectMake(label.frame.origin.x+10.0f, 5.0f, label.frame.size.width, label.frame.size.height);
            label.font = footerLabelFont;
            label.textColor = [UIColor redColor];
    
            // Give the container view 10 poionts more in width than our label
            // becuause the lable needs a 10 extra points left-margin
            CGRect resultFrame = CGRectMake(0.0f, 0.0f, label.frame.size.width+10.0f, label.frame.size.height);
            UIView *footer = [[UIView alloc] initWithFrame:resultFrame];
            [footer addSubview:label];
            return footer;
        }
    }
    return nil;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 0 ) {
        if  ([self isActiveTrail]) {
            return 30.0f;
        }
    }
    // else
        return 0.0f;
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [detailTable beginUpdates];
    [detailTable endUpdates];
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
- (void)orientationChanged:(NSNotification *)notification {
    // Respond to changes in device orientation
    //  NSLog(@"Orientation Changed!");
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    
    if (currentOrientation == orientation) {
        return;
    }
    
    if ((UIDeviceOrientationIsPortrait(currentOrientation) && UIDeviceOrientationIsPortrait(orientation)) ||
        (UIDeviceOrientationIsLandscape(currentOrientation) && UIDeviceOrientationIsLandscape(orientation)) ||
        currentOrientation == UIDeviceOrientationPortraitUpsideDown) {
        //still saving the current orientation
        orientation = currentOrientation;
        return;
    }
    
    orientation = currentOrientation;
    
    CGRect screenRect;
    [TOMUIUtilities screenRect:&screenRect];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    screenRect = CGRectMake(0.0, 0.0, screenWidth, screenHeight);
    [self.view setFrame:screenRect];
    
    CGRect tableRect = CGRectMake( 0.0, 0.0, screenWidth, screenHeight );
    [detailTable setFrame:tableRect];

    // [detailTable beginUpdates];
    // [detailTable endUpdates];
    [detailTable reloadData];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"Picked %@",indexPath);
    
    TOMPointOnAMap *mp = [imagesSet objectAtIndex:indexPath.row];
    // NSLog(@"%s Title:%@ URL:%@",__func__,thisCell.title,thisCell.url);
    NSURL *myURL = [TOMUrl urlForImageFile:self.title key:[mp key]];
    // UIViewController *ptController = [[TOMImageViewController alloc] initWithNibNameWithKeyAndImage:@"TOMImageViewController" bundle:nil title:[mp title] key:[mp key] url:myURL];
    UIViewController *ptController = [[TOMImageViewController alloc] initWithNibNameAndPom:@"TOMImageViewController" bundle:nil Trail: theTrail.title POM:mp url:myURL];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    [[self navigationController] pushViewController:ptController animated:YES];
    
    
}

//
// Switch delegates:
- (void)dvcSwitchSelector:(id)sender{

    // NSLog(@"In %s",__PRETTY_FUNCTION__);
    
    UISwitch *toggleOnOffSwitch = (UISwitch *)sender;
    BOOL yn = toggleOnOffSwitch.isOn;
    
    if ([sender tag] == GPX_SWITCH_TAG) {
        if (yn) {
            [self createGPX];
        }
        else {
            NSURL *gpxdocdirURL = [TOMUrl urlForDocumentsDirectory];
            NSString *gpxName = [NSString stringWithFormat:@"%@.gpx",self.title];
            NSURL *gpxFullURL = [gpxdocdirURL URLByAppendingPathComponent:gpxName isDirectory:NO];
            [TOMUrl removeURL:gpxFullURL];
        }
    }
    else if ([sender tag] == KML_SWITCH_TAG ) {
        if (yn) {
            [self createKML];
        }
        else {
            NSURL *kmzdocdirURL = [TOMUrl urlForDocumentsDirectory];
            NSString *kmzName = [NSString stringWithFormat:@"%@.kmz",self.title];
            NSURL *kmzFullURL = [kmzdocdirURL URLByAppendingPathComponent:kmzName isDirectory:NO];
            [TOMUrl removeURL:kmzFullURL];
        }
    }
    else {
            NSLog(@"%s Error: Invalid Tag %ld",__PRETTY_FUNCTION__,(long)[sender tag]);
    }
}


#pragma __GPX_Functions__

- (void) createGPX
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // gpx
    pssGPXRoot *gpx = [pssGPXRoot rootWithCreator:@TRAILS_ON_A_MAP];
    // gpx > trk
    pssGPXTrack *gpxTrack = [gpx newTrack];
    gpxTrack.name = [theTrail title];
    
    for ( int i = 0 ; i < [theTrail.ptTrack count] ; i++ )
    {
        TOMPointOnAMap *mp = [theTrail.ptTrack objectAtIndex: i];
        
        if  ([mp type] == ptLocation) {
            
            CLLocationCoordinate2D coord = mp.coordinate;
            pssGPXTrackPoint *gpxTrackPoint = [gpxTrack newTrackpointWithLatitude:coord.latitude  longitude:coord.longitude];
            gpxTrackPoint.elevation = mp.altitude;
            gpxTrackPoint.time = mp.timestamp;
            
        }
    }
    
    NSString *gpxString = gpx.gpx;
    // Store locally generated files locally, not on iCloud
    NSURL *docsdirURL = [TOMUrl urlForLocalDocuments];
    NSString *fileName = [NSString stringWithFormat:@"%@.gpx",self.title];
    NSURL *documentURL = [docsdirURL URLByAppendingPathComponent:fileName isDirectory:NO];
    NSError *err;
    
    [gpxString writeToURL:documentURL atomically:YES encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        NSLog(@"%s ERROR WRITING GPX FILE: %@",__func__,err);
    }
    
#ifdef DEBUG
    NSString *csvFileName = [NSString stringWithFormat:@"%@.csv",self.title];
    NSURL *csvDocURL = [docsdirURL URLByAppendingPathComponent:csvFileName isDirectory:NO];
    [theTrail trailCSVtoURL:csvDocURL];
#endif
        
    }); // end dispatch
    return;
}

#pragma __KML_Functions__

- (KMLPlacemark *)placemarkWithName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate altitude:(CLLocationDistance) altitude
{
    KMLPlacemark *placemarkElement = [KMLPlacemark new];
    placemarkElement.name = name;
    
    KMLPoint *pointElement = [KMLPoint new];
    placemarkElement.geometry = pointElement;
    
    KMLCoordinate *coordinateElement = [KMLCoordinate new];
    coordinateElement.latitude = coordinate.latitude;
    coordinateElement.longitude = coordinate.longitude;
    coordinateElement.altitude = altitude;
    pointElement.coordinate = coordinateElement;
    
    return placemarkElement;
}

- (KMLPlacemark *)lineWithTrakPoints
{
    KMLPlacemark *placemark = [KMLPlacemark new];
    placemark.name = @"Line";
    
    __block KMLLineString *lineString = [KMLLineString new];
    placemark.geometry = lineString;
    
    for ( int i = 0 ; i < [theTrail.ptTrack count] ; i++ )
    {
         TOMPointOnAMap *mp = [theTrail.ptTrack objectAtIndex: i];
        if ([mp type] == ptLocation) {
            KMLCoordinate *coordinate = [KMLCoordinate new];
            coordinate.latitude = mp.coordinate.latitude;
            coordinate.longitude = mp.coordinate.longitude;
            coordinate.altitude = mp.altitude;
            [lineString addCoordinate:coordinate];
        }
    }
    
    KMLStyle *style = [KMLStyle new];
    [placemark addStyleSelector:style];
    
    KMLLineStyle *lineStyle = [KMLLineStyle new];
    style.lineStyle = lineStyle;
    lineStyle.width = 5;
    lineStyle.UIColor = [UIColor blueColor];
    
    return placemark;
}

- (void) createKML
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // [pssKML pssKMLMessage];
    NSMutableArray *imageURLs = [[NSMutableArray alloc] init] ;
    
    // kml
    KMLRoot *kml = [KMLRoot new];
    NSURL *tempURL = nil;

    // kml > document
    KMLDocument *document = [KMLDocument new];
    kml.feature = document;
    
    [document setName:[theTrail title]];
        
    if (theTrail.ptTrack && ([theTrail.ptTrack count] > 0)) {
        TOMPointOnAMap *mp = [theTrail.ptTrack objectAtIndex: 0];
    
        KMLPlacemark *startPlacemark = [self placemarkWithName:@"Start" coordinate:[mp coordinate] altitude:[mp altitude]];
        [document addFeature:startPlacemark];

        // kml > document > placemark#line
        KMLPlacemark *line = [self lineWithTrakPoints];
        [document addFeature:line];
    
        mp = [theTrail lastPom];
        KMLPlacemark *endPlacemark = [self placemarkWithName:@"End" coordinate:[mp coordinate] altitude:[mp altitude]];
        [document addFeature:endPlacemark];
    }
    int photoCount = 1;
    for ( int i = 0 ; i < [theTrail.ptTrack count] ; i++ )
    {
        TOMPointOnAMap *mp = [theTrail.ptTrack objectAtIndex: i];
        if ([mp type] == ptPicture) {

            KMLPhotoOverlay *photoOverlay = [KMLPhotoOverlay new];
            [document addFeature:photoOverlay];
            
            // NSString *photoTitle = [[NSString alloc] initWithFormat:@"Photo %d",photoCount ];
            // [photoOverlay setName:photoTitle];
            
            [photoOverlay setName:[mp title]];
            [photoOverlay setDescriptionValue:[mp subtitle]];

            // Set Up The Camera
            KMLCamera *photoCamera = [KMLCamera new];
            [photoOverlay setAbstractView:photoCamera];
            photoCamera.longitude = mp.coordinate.longitude;
            photoCamera.latitude = mp.coordinate.latitude;
            photoCamera.altitude = 2.0f;
            photoCamera.heading = [mp.heading trueHeading];
            photoCamera.tilt = 90.0f;
            photoCamera.roll = 0.0f;
            photoCamera.altitudeMode = KMLAltitudeModeRelativeToGround;
            
            KMLStyle *photoStyle = [KMLStyle new];
            [photoOverlay addStyleSelector:photoStyle];
            
            KMLIconStyle *photoIconStyle = [KMLIconStyle new];
            [photoStyle setIconStyle:photoIconStyle];
            
            KMLIcon *styleIcon = [KMLIcon new];
            [photoIconStyle setIcon:styleIcon];
            [styleIcon setHref:@"http://maps.google.com/mapfiles/kml/shapes/camera.png"];
            
            // points to the image
            KMLIcon *photoIcon = [KMLIcon new];
            [photoOverlay setIcon:photoIcon];
            NSString *imageName = [NSString stringWithFormat:@"Photo %d.jpg",photoCount++];
            NSString *imagePath = [NSString stringWithFormat:@"files/%@",imageName];
            [photoIcon setHref:imagePath];

            KMLViewVolume *photoViewVolume = [KMLViewVolume new];
            [photoOverlay setViewVolume:photoViewVolume];
            photoViewVolume.near = 1.0f;
            photoViewVolume.leftFov = -26.667f;
            photoViewVolume.rightFov = 26.667f;
            photoViewVolume.bottomFov = -25.0f;
            photoViewVolume.topFov = 25.0f;
            
            KMLPoint *photoPoint = [KMLPoint new];
            [photoOverlay setPoint:photoPoint];
            
            KMLCoordinate *photoCoordinate = [KMLCoordinate new];
            [photoPoint setCoordinate:photoCoordinate];
            
            [photoCoordinate setLatitude:mp.coordinate.latitude];
            [photoCoordinate setLongitude:mp.coordinate.longitude];
            [photoCoordinate setAltitude:2.0f];
            photoPoint.altitudeMode = KMLAltitudeModeRelativeToGround;
            
            KMLShape photoShape = KMLShapeRectangle;
            [photoOverlay setShape:photoShape];
            
            //
            // Make the image to be included with the KMZ file.
            // Images have a limit of 8196x8196 is Google Earth.  Scale ours down if neccessary
            //
            UIImage *myImage = [TOMImageStore loadImage:self.title key:[mp key] warn:NO];
            CGSize imageSize = [myImage size];
            CGSize newImageSize = CGSizeMake(KML_JPG_SIZE, KML_JPG_SIZE);
            UIImage *newImage = myImage;

            if (imageSize.width > KML_JPG_SIZE || imageSize.height > KML_JPG_SIZE )
            {
                if (imageSize.width > imageSize.height) {
                    newImageSize.height = (imageSize.height * KML_JPG_SIZE) /imageSize.width;
                }
                else {
                    newImageSize.width = (imageSize.width * KML_JPG_SIZE) / imageSize.height;
                }
                UIGraphicsBeginImageContextWithOptions(newImageSize, NO, 0.0);
                [myImage drawInRect:CGRectMake(0, 0, newImageSize.width, newImageSize.height)];
                newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            else {
                NSLog(@"%s myImage small enough to be used as existing image",__PRETTY_FUNCTION__);
            }
            
            // Image was small enough to be used in the KMZ file.

            
            if (!tempURL) {
                tempURL = [TOMUrl temporaryDir:@"files"];
                [TOMUrl checkDirectory:tempURL create:YES];
            }
            
            NSURL *imageURL = [tempURL URLByAppendingPathComponent:imageName isDirectory:NO];
            [TOMImageStore saveImageToURL:newImage url:imageURL];
            [imageURLs addObject:[imageURL path]];
        }
    }
    
    NSString *kmlString = kml.kml;
    NSURL *docsdirURL = [TOMUrl urlForLocalDocuments];
    NSString *fileName = [NSString stringWithFormat:@"%@.kml",self.title];
    NSURL *documentURL = [docsdirURL URLByAppendingPathComponent:fileName isDirectory:NO];
    NSError *err;
    
    [kmlString writeToURL:documentURL atomically:YES encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        NSLog(@"%s ERROR WRITE KML FILE: %@",__func__,err);
    }

    NSURL *zipdirURL = [TOMUrl urlForLocalDocuments];
    NSString *zipName = [NSString stringWithFormat:@"%@.kmz",self.title];
    NSURL *zipFullURL = [zipdirURL URLByAppendingPathComponent:zipName isDirectory:NO];

    // Delete any existing KMZ file.
    [TOMUrl removeURL:zipFullURL];

    // Add the KML file to the KMZ archive.
    ZKFileArchive *archive = [ZKFileArchive archiveWithArchivePath:[zipFullURL path]];
    NSInteger result = [archive deflateFile:[documentURL path] relativeToPath:[docsdirURL path] usingResourceFork:NO];
    // NSLog(@"Result For KML File: %ld",(long)result);
    if  (result == 1) {
        // Don't leave the KML file laying around since it's in the KMZ file
        [TOMUrl removeURL:documentURL];
    }
    else {
        NSLog(@"%s Error in archiving:%ld",__PRETTY_FUNCTION__,(long)result);
    }
    
    //
    // Clean out the tmp/files directory
    if ([imageURLs count] > 0) {
        tempURL = [TOMUrl temporaryDir:nil];
    
        result = [archive deflateFiles:imageURLs relativeToPath:[tempURL path] usingResourceFork:NO];
        if  (result == 1) {
            tempURL = [TOMUrl temporaryDir:@"files"];
            [TOMUrl removeURL:tempURL];
        }
        else {
            NSLog(@"%s Error archiving photos.  Result: %ld",__PRETTY_FUNCTION__,(long)result);
        }
    }
    }); // end dispatch
}

//
// Check to see if we need to download from the iCloud to this device
//
-(void) prepareImageFiles
{
    self.query = [[NSMetadataQuery alloc] init];
    
    if (query) {
        //
        // Trying to limit what is downloaded here but it kept running into problems
        //
        // NSURL *icloudURL = [TOMUrl urlForICloudDocuments];
        // NSURL *trailDirURL = [icloudURL URLByAppendingPathComponent:self.title isDirectory:YES];
        // NSString *trailDir = [NSString stringWithFormat:@"Documents/%@/", self.title]; // Directory name
        // NSURL *documentPath = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:trailDir];
        // NSLog(@"Document Path: %@", trailDirURL);
        //
        // [query setSearchScopes:[NSArray arrayWithObject:trailDirURL]];
        //
        [query setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
        [query setPredicate:[NSPredicate predicateWithFormat:@"%K ENDSWITH %@ || %K ENDSWITH %@", NSMetadataItemFSNameKey, @TOM_JPG_EXT, NSMetadataItemFSNameKey, @TOM_FILE_EXT]];
        
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processImageFiles:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processImageFiles:)
                                                 name:NSMetadataQueryDidUpdateNotification
                                               object:nil];
    BOOL startedQuery = [query startQuery]; // off we go:
    
    if (!startedQuery) {
        NSLog(@"%s ERROR Query Not Started",__PRETTY_FUNCTION__);
    }
}

-(void) processImageFiles:(NSNotification *)notification
{

    [query disableUpdates]; // Disable Updates while processing
    
    NSArray *queryResults = [query results];
    
    for (NSMetadataItem *result in queryResults) {
        
        NSURL *fileURL = [result valueForAttribute:NSMetadataItemURLKey];
        // NSLog(@"File URL:%@",fileURL);
        
        NSString *path = [fileURL path];
        NSArray *parts = [path componentsSeparatedByString:@"/"];
        NSString *trailName = [parts objectAtIndex:[parts count]-2];
        
        //
        // to speed up downloadning I only want this trails pictures
        if (![trailName isEqualToString:self.title]) {
            continue;
        }
        else {
            NSString *filename = [parts objectAtIndex:[parts count]-1];
            if ([filename hasSuffix:@TOM_FILE_EXT]) {
                // Only interested in JPGs here
                continue;
            }
        }
        
        NSString *isDownloaded = [result valueForAttribute:NSMetadataUbiquitousItemDownloadingStatusKey];
        
        if (![isDownloaded isEqualToString:@"NSMetadataUbiquitousItemDownloadingStatusCurrent"] &&
            ![isDownloaded isEqualToString:@"NSMetadataUbiquitousItemDownloadingStatusDownloaded"]) {

            //NSLog(@"ItemIsDownloadingKey:%s",downLoadingStatus);
#ifdef DEBUG
            NSNumber *percentDownloaded = [result valueForKey:NSMetadataUbiquitousItemPercentDownloadedKey];
            if (percentDownloaded)
                NSLog(@"ItemPercentDownloaded:%@",percentDownloaded); // FFU
#endif
            NSError *err = [result valueForKey:NSMetadataUbiquitousItemDownloadingErrorKey];
            NSNumber *isDownLoading;
            if (err) {
                NSLog(@"%s Error In Downloading: %@",__PRETTY_FUNCTION__,err);
                isDownloaded = nil;
            }
            else
                isDownLoading = [result valueForKey:NSMetadataUbiquitousItemIsDownloadingKey];

            if (![isDownLoading boolValue]) {
                //
                // Send a request to download the file locally
                //
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSFileManager *fm = [[NSFileManager alloc] init];
                    NSError *err=nil;
                    NSLog(@"Starting to download %@",fileURL);
                    [fm startDownloadingUbiquitousItemAtURL:fileURL error:&err];
                    if (err)
                        NSLog(@"%s Error %@",__PRETTY_FUNCTION__,err);
                });
            }
        }
    }
    [query enableUpdates];

    [detailTable beginUpdates];
    [detailTable endUpdates];
    [detailTable reloadData];
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#pragma textFieldAndRenamingFuncs


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (!amIediting) {
        return NO;
    }
    

    //
    // This alerts the view that the field is uneditable when the trail in the detail viewer is the same one
    // running on the rootviewcontroller (or the main view).
    //
    if  ([self isActiveTrail]) {
        return NO;
    }
    
    //
    // This alerts the view that the trail is still being downloaded and should not
    // be editiable.
    if (query) {
        if ([query isStarted] || [query isGathering]) {
            [query disableUpdates ];
            NSArray *queryResults = [query results];
            
            for (NSMetadataItem *result in queryResults) {
                
                NSURL *fileURL = [result valueForAttribute:NSMetadataItemURLKey];
                // NSLog(@"File URL:%@",fileURL);
                
                NSString *path = [fileURL path];
                NSArray *parts = [path componentsSeparatedByString:@"/"];
                NSString *trailName = [parts objectAtIndex:[parts count]-2];
                
                //
                // to speed up downloadning I only want this trails pictures
                if (![trailName isEqualToString:self.title]) {
                    continue;
                }
                else {
                    NSString *isDownloaded = [result valueForAttribute:NSMetadataUbiquitousItemDownloadingStatusKey];
                        
                    if (![isDownloaded isEqualToString:@"NSMetadataUbiquitousItemDownloadingStatusCurrent"] &&
                        ![isDownloaded isEqualToString:@"NSMetadataUbiquitousItemDownloadingStatusDownloaded"]) {
                        NSLog(@"%s File %@ not downloaded or current",__PRETTY_FUNCTION__,[parts objectAtIndex:[parts count]-1]);
                        [query enableUpdates];
                        UIActionSheet *actionSheet = nil;
                        NSString *alertTitle = @"Trail not completely downloaded from iCloud, Please try again later";
                        actionSheet = [[UIActionSheet alloc] initWithTitle:alertTitle
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:nil];
                        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
                        actionSheet.tag = 0;
                        [actionSheet showInView:self.view];
                        return NO;
                    }
                }
            }
        }
    }
    return YES;
}



- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if ([textField tag] != detailViewTagTitle) {
        NSLog(@"In %s with tag %d",__PRETTY_FUNCTION__,(int) textField.tag);
        NSString *myNewTitle = [textField text];
        myNewTitle = [myNewTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [textField resignFirstResponder];
        
        TOMPointOnAMap *p = [imagesSet objectAtIndex:(long)textField.tag];
        [p setTitle:myNewTitle];
        [theTrail updateChangeCount:UIDocumentChangeDone];
        return YES;
    }
    
    // NSLog(@"%s New Name: [%@]",__PRETTY_FUNCTION__,textField);
    NSString *myNewTitle = [textField text];
    myNewTitle = [myNewTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [titleField resignFirstResponder]; // and hides the keyboard
    
    if ([myNewTitle isEqualToString:self.title]) {
        // Nothing changed, just return
        return YES;
    }

    UIActionSheet *actionSheet = nil;
    
    if ([myNewTitle isEqualToString:@""]) {
        NSString *alertTitle = @"Cannot have a Trail with a blank name, Please enter a name";
        actionSheet = [[UIActionSheet alloc] initWithTitle:alertTitle
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        actionSheet.tag = 0;
        titleField.text = theTrail.title;
    }
    else {
        NSURL *fileURL = [TOMUrl urlForFile:titleField.text key:titleField.text];
        NSFileManager *fileManager = [[NSFileManager alloc]init];
    

    
        if ([fileManager fileExistsAtPath:[fileURL path]]) {
            NSString *alertTitle = @"A Trail exists with the this name, Please try another name";
            actionSheet = [[UIActionSheet alloc] initWithTitle:alertTitle
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            actionSheet.tag = 0;
        }
        else {
            // Verify the user really wants to rename the Trail.
            //
            // I had to move this to here to give time for the device to save.
            // before I actually moved the trail.  If I just closed it, sometimes
            // I lost any updates the user made to the photos.  If there are
            // no unsaved changes or the user doesn't rename the trail, there is
            // no harm done.
            //
            if ([theTrail hasUnsavedChanges]) {
                NSURL *fileURL = [TOMUrl urlForFile:theTrail.title key:theTrail.title];
#ifdef __DEBUG
                [theTrail saveToURL:fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                    if (success) {
                        NSLog(@"%s Completed Save To URL",__PRETTY_FUNCTION__);
                    }
                    else {
                        UIDocumentState myState = [theTrail documentState];
                        NSLog(@"%s did not completed Save To URL %d",__PRETTY_FUNCTION__,(int)myState);
                    }
                }];
#else
                [theTrail saveToURL:fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:nil];
#endif
            }
            
            NSString *alertTitle = @"Are you sure you want to rename the Trail?";
    
            actionSheet = [[UIActionSheet alloc] initWithTitle:alertTitle
                                                                    delegate:self
                                                          cancelButtonTitle:@"NO"
                                                     destructiveButtonTitle:@"YES"
                                                          otherButtonTitles:nil];

            actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            actionSheet.tag = 1;
        }
    }
    [actionSheet showInView:self.view];
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Actions sheets tagged with 0 will not perform any actions/
    if (actionSheet.tag == 0) {
        return;
    }
    if  (buttonIndex == 0 ) {
        BOOL anyErrors = NO;
        
        [activityIndicator startAnimating];
        
        // Close this trail
#ifdef __DEBUG
        [theTrail closeWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"%s Completed closeWithCompletionHandler",__PRETTY_FUNCTION__);
            }
            else {
                UIDocumentState myState = [theTrail documentState];
                NSLog(@"%s Did mot complete closeWithCompletionHandler %d",__PRETTY_FUNCTION__,(int)myState);
            }
        }];
#else
        [theTrail closeWithCompletionHandler:nil ];
#endif

        // Verify it closed.
        int i = 0;
        UIDocumentState myState = [theTrail documentState];
        while (myState != UIDocumentStateClosed && myState != UIDocumentStateNormal)
        {
            if (i++ >= 10) {
                //
                // I've not been able to test this fully.
                [activityIndicator stopAnimating];
                NSLog(@"%s Document %@ not Closed State: %d",__PRETTY_FUNCTION__,theTrail.title,(int)myState );
                return;
            }
            sleep(1);
            myState = [theTrail documentState];
        }
        
        //
        // Build up the URLs for the move
        NSURL *oldURL = [TOMUrl urlForTrail:theTrail.title];
        NSURL *newURL = [TOMUrl urlForTrail:titleField.text];
        theTrail = nil;

        // Pass it to a helper method.
        anyErrors = [self moveTheTrailFrom:oldURL To:newURL];
        if (anyErrors) {
            NSLog(@"%s ERROR In Renaming Trail %@",__PRETTY_FUNCTION__,theTrail.title);
            return;
        }
        else {
        //
        // Reload the data for the renamed trail.
        //
            NSURL *fileURL = [TOMUrl urlForFile:titleField.text key:titleField.text];
            theTrail = [[TOMPomSet alloc] initWithFileURL:fileURL];
            NSFileManager *fileManager = [[NSFileManager alloc]init];
            if ([fileManager fileExistsAtPath:[fileURL path]]) {
                [theTrail loadFromContents:fileURL ofType:nil error:nil];
            }

            // Last step, reset the name.
            self.title = titleField.text;
            [activityIndicator stopAnimating];
            [detailTable reloadData];
        }
    }
    else {
        // NSLog(@"User Selected NO");
        titleField.text = theTrail.title;
    }
    
    if (query) {
        if ([query isStarted] || [query isGathering]) {
            [query enableUpdates ];
        }
    }
    
}

-(BOOL) moveTheTrailFrom:(NSURL *) oldTrailURL To:(NSURL *) newTrailURL
{
    BOOL anyError = NO;
    NSArray *keys = [NSArray arrayWithObjects: NSURLIsDirectoryKey, NSURLIsPackageKey, NSURLLocalizedNameKey, nil];

    NSFileManager *fileManager = [[NSFileManager alloc]init];
    BOOL isDir;
    
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:oldTrailURL
                                          includingPropertiesForKeys:keys
                                                             options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles)
                                                        errorHandler:^(NSURL *url, NSError *error) {
                                                                        // Handle the error.
                                                                        // Return YES if the enumeration should continue after the error.
                                                                        return     YES;}];

    for (NSURL *url in enumerator) {
    
        BOOL isDirectory;
        NSError *err = nil;

        // NSLog(@"%s Source URL:%@",__PRETTY_FUNCTION__,[url path]);

        BOOL fileExistsAtPath = [fileManager fileExistsAtPath:[url path] isDirectory:&isDirectory];
        
        if (isDirectory) {
            // NSLog(@"%s Skipping Dir %@",__PRETTY_FUNCTION__,url);
            continue;
        }
        
        else if (fileExistsAtPath) {
            
            NSString *path = [url path];
            NSArray *parts = [path componentsSeparatedByString:@"/"];
            // NSString *trailName = [parts objectAtIndex:[parts count]-2]; // Trail Name if it's not a Directory
            NSString *fileName = [parts objectAtIndex:[parts count]-1];
            
            if ( [fileName hasSuffix:@TOM_JPG_ICON_EXT]) {
                NSString *iconFileName = [NSString stringWithFormat:@"%@%@",titleField.text,@TOM_JPG_ICON_EXT];
                NSURL *destIconURL = [newTrailURL URLByAppendingPathComponent:iconFileName isDirectory:NO];
                // NSLog(@"Dest URL:%@",[destIconURL path]);
                [fileManager moveItemAtURL:url toURL:destIconURL error:&err];
                if (err) {
                    NSLog(@"%s : Error copy to new URL: %@",__PRETTY_FUNCTION__,err);
                    anyError = YES;
                }
            }
            else if ( [fileName hasSuffix:@TOM_JPG_EXT] ) {
                //
                // JPGs have their key as the file name, they don't need to be renamed.
                //
                NSURL *destinationURL = [newTrailURL URLByAppendingPathComponent:fileName isDirectory:NO];
            
                if (![fileManager fileExistsAtPath:[destinationURL path] isDirectory:&isDir]) {
                    // NSLog(@"Dest URL:%@",[destinationURL path]);
                    [fileManager moveItemAtURL:url toURL:destinationURL error:&err];
                    if (err) {
                        NSLog(@"%s : Error copy to new URL: %@",__PRETTY_FUNCTION__,err);
                        anyError = YES;
                    }
                }
            }
            else if ( [fileName hasSuffix:@TOM_FILE_EXT] ) {
                NSString *trailFileName = [NSString stringWithFormat:@"%@%@",titleField.text,@TOM_FILE_EXT];
                NSURL *destinationURL = [newTrailURL URLByAppendingPathComponent:trailFileName isDirectory:NO];
                [fileManager moveItemAtURL:url toURL:destinationURL error:&err];
                if (err) {
                    NSLog(@"%s : Error copy to new URL: %@",__PRETTY_FUNCTION__,err);
                    anyError = YES;
                }
            }
#ifdef DEBUG
            else {
                 NSLog(@"%s Skipping File: %@",__PRETTY_FUNCTION__,fileName);
            }
#endif
        }  // fileExistsAtPath
    } // for
    
    if (!anyError) {
       
        //
        // Delete the temporary files
        //
        NSURL *docdirURL = [TOMUrl urlForLocalDocuments];
        NSString *kmzName = [NSString stringWithFormat:@"%@%s",self.title,TOM_KMZ_EXT];
        NSURL *zipFullURL = [docdirURL URLByAppendingPathComponent:kmzName isDirectory:NO];
        [TOMUrl removeURL:zipFullURL];
        
        NSString *gpxName = [NSString stringWithFormat:@"%@%s",self.title,TOM_GPX_EXT];
        NSURL *gpxFullURL = [docdirURL URLByAppendingPathComponent:gpxName isDirectory:NO];
        [TOMUrl removeURL:gpxFullURL];
        
#ifdef DEBUG
        NSString *csvName = [NSString stringWithFormat:@"%@%s",self.title,TOM_CSV_EXT];
        NSURL *csvFullURL = [docdirURL URLByAppendingPathComponent:csvName isDirectory:NO];
        [TOMUrl removeURL:csvFullURL];
#endif
        [TOMUrl removeURL:oldTrailURL];
    }
    return anyError;
}

//
//
- (IBAction)editClicked:(id)sender {
    
    // NSLog(@"In %s",__PRETTY_FUNCTION__);
    if (amIediting) {
        titleField.borderStyle = UITextBorderStyleNone;
        amIediting = NO;
        [titleField resignFirstResponder];
        [editAndDoneButton setTitle:@"Edit"];
        if (![self.title isEqualToString:[titleField text]]) {
            titleField.text = self.title;
        }
        
        if ([theTrail hasUnsavedChanges]) {
            [activityIndicator startAnimating];
            NSURL *fileURL = [TOMUrl urlForFile:theTrail.title key:theTrail.title];
            [theTrail saveToURL:fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                NSLog(@"Success: %d",success);
                [activityIndicator stopAnimating];
                [self.navigationItem setHidesBackButton:NO animated:YES];
                if (success) {
                    NSLog(@"Completed");
                    [detailTable reloadData];
                }}];
        }
        else {
            [self.navigationItem setHidesBackButton:NO animated:YES];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
                self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            [detailTable reloadData];
        }
        // [self setEditing:NO animated:YES];
        // return;
    }
    else if ([self isActiveTrail]) {
        //
        // NO EDITING!
        // This should be a redundant check since the
        // EDIT option is not on the toolbar.
        //
        titleField.borderStyle = UITextBorderStyleNone;
        amIediting = NO;
        // return;
    }
    else {
        titleField.borderStyle = UITextBorderStyleRoundedRect;
        amIediting = YES;
        [editAndDoneButton setTitle:@"Done"];
        [self.navigationItem setHidesBackButton:YES animated:YES];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [detailTable reloadData];
    }
    
    // [self setEditing:YES animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case 0:
        case 1:
        case 2:
            break;
            
        default:
            NSLog(@"ERROR: Unhandled Section");
            break;
    }
    return UITableViewCellEditingStyleNone;
}



- (BOOL) isActiveTrail {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_NAME] != nil)
    {
        NSString *currentTitle = [[NSUserDefaults standardUserDefaults] stringForKey:@KEY_NAME];
        if ([self.title isEqualToString:currentTitle]) {
            return YES;
        }
    }
    return NO;
}


@end
