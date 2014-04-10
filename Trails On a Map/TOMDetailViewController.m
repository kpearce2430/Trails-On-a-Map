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

@synthesize theTrail,detailTable, footerLabelFont, headerLabelFont, picCount, imagesSet, /* imageStore,*/ gpxSwitch, kmlSwitch; // trailCollectionList, trailCollectionView;


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
        
#ifdef __NUA__
        //  Left over from when I tried to implement this as a UICollectionView - That will be after the initial release.
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];


        trailCollectionView=[[UICollectionView alloc] initWithFrame:screenRect collectionViewLayout:layout];
        [trailCollectionView setDataSource:self];
        [trailCollectionView setDelegate:self];
        
        [trailCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
        [trailCollectionView setBackgroundColor:[UIColor blackColor]];
        [trailCollectionView setAllowsSelection:YES];
        [trailCollectionView setAllowsMultipleSelection:NO];
        [self.view addSubview:trailCollectionView];

        
        UITapGestureRecognizer *doubleTapFolderGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
        [doubleTapFolderGesture setNumberOfTapsRequired:2];
        [doubleTapFolderGesture setNumberOfTouchesRequired:1];
        [self.view addGestureRecognizer:doubleTapFolderGesture];
#endif
        
    }
    return self;
}

//
// * * * * * * * * * * * * * * * * * * *
//

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    // imageStore = [[TOMImageStore alloc] init];
    
    imagesSet = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [theTrail.ptTrack count]; i++ ) {
        TOMPointOnAMap *p = [theTrail.ptTrack objectAtIndex:i];
        if ([p type] == ptPicture) {
            
            UIImage *myImage = [TOMImageStore loadImage:self.title key:[p key] warn:NO];
            
            TOMOrganizerViewCell *myCell = [[TOMOrganizerViewCell alloc] init];
            [myCell setTitle:[p key]];
            [myCell setUrl:[TOMUrl urlForImageFile:self.title key:[p key]]];
             
            if (myImage == NULL) {
                myImage = [UIImage imageNamed:@"pt114x114.png"];
                [myCell setImage:myImage];
                
            }
            else {
                CGSize destinationSize = CGSizeMake(120.0f, 120.0f);
                UIGraphicsBeginImageContext(destinationSize);
                [myImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
                UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [myCell setImage:newImage];
            }
        [imagesSet addObject:myCell];
        }
    }

    // NSLog(@"%s Image Count:%ld  I:%ld",__PRETTY_FUNCTION__,(long)[theTrail numPics],(unsigned long)[imagesSet count]);
    
    // Do any additional setup after loading the view from its nib.
    // CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.detailTable = [[ UITableView alloc] initWithFrame: self.view.bounds style:UITableViewStyleGrouped];
 
    // basics
    self.detailTable.delegate = self;
   
    // register the class
    [detailTable registerClass:[UITableViewCell class] forCellReuseIdentifier:detailViewCellIdentifier];
    [detailTable setDataSource:self];
    
    // Make sure the table resizes correctly
    // detailTable.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // finally attach it to the view
    
    [self.view addSubview: detailTable ];
    
    // Push an orientation change call now
    [self orientationChanged:NULL];

}

-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
  
    //
    // Set up notifications
    //
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
        NSLog(@"ERROR: %s:%d Invalid table view passed:%@", __func__, __LINE__ , tableView);
        return 0;
    }
}

// * * * * * * * * * * * * * * * * * * *

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if ([tableView isEqual:detailTable]) {
        switch (section) {
            case 0: // Trail Flags
                return 2;
                break;
            case 1: // Trail Pictures;
                picCount = [theTrail numPics];
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

    NSLog(@"ERROR: %s:%d Invalid table view passed:%@", __func__, __LINE__ , tableView);
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
        
        CGRect switchFrame = CGRectMake( 0.0f, 0.0f, 150.0f, 25.0f );
        UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:switchFrame];
        [aSwitch setOn:NO];
        [aSwitch addTarget:self action:@selector(dvcSwitchSelector:) forControlEvents:UIControlEventValueChanged];
        switch (indexPath.section)  {
            case 0:
                if (indexPath.row == 0) {
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
                else if (indexPath.row == 1) {
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
                    NSLog(@"%s ERROR FFU Cell Reached",__func__);
                    cell.textLabel.text = [ NSString stringWithFormat:@"FFU Section %ld, Cell %ld",(long)indexPath.section,(long)indexPath.row];
                }
                break;
            
            case 1:
                if (picCount == 0)
                {
                    cell.textLabel.text = @"No Pictures in Trail";
                }
                else {
                    cell.textLabel.text = [ NSString stringWithFormat:@"Picture %ld",(long)indexPath.row];
                    TOMOrganizerViewCell *thisCell = [imagesSet objectAtIndex:indexPath.row];
                    cell.imageView.image = thisCell.image;
                    cell.imageView.layer.cornerRadius = TOM_LABEL_BORDER_CORNER_RADIUS;
                    cell.accessoryType = UITableViewCellAccessoryDetailButton;
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

#ifdef __FFU__
- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
 
    NSString *text = [[NSString alloc] initWithFormat:@"Section %ld Footer",section ];
    UILabel *label = [self newLabelWithTitle: text];
    
    label.frame = CGRectMake(label.frame.origin.x+10.0f, 5.0f, label.frame.size.width, label.frame.size.height);
    label.font = footerLabelFont;
    
    // Give the container view 10 poionts more in width than our label
    // becuause the lable needs a 10 extra points left-margin
    CGRect resultFrame = CGRectMake(0.0f, 0.0f, label.frame.size.width+10.0f, label.frame.size.height);
    UIView *footer = [[UIView alloc] initWithFrame:resultFrame];
    [footer addSubview:label];
    return footer;
}
#endif

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

#ifdef __FFU__

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0f;
}
#endif
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
    
    screenRect = CGRectMake(0.0, 0.0, screenWidth, screenHeight);
    [self.view setFrame:screenRect];
    
    CGRect tableRect = CGRectMake( 0.0, 0.0, screenWidth, screenHeight );
    [detailTable setFrame:tableRect];

    [detailTable beginUpdates];
    [detailTable endUpdates];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"Picked %@",indexPath);
    NSLog(@"Selected: %@",indexPath);
    
    TOMOrganizerViewCell *thisCell = [imagesSet objectAtIndex:indexPath.row];
    NSLog(@"%s Title:%@ URL:%@",__func__,thisCell.title,thisCell.url);
    
    UIViewController *ptController = [[TOMImageViewController alloc] initWithNibNameWithKeyAndImage:@"TOMImageViewController" bundle:nil key:thisCell.title url:thisCell.url];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
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
    
    NSURL *docsdirURL = [TOMUrl urlForDocumentsDirectory];
    NSString *fileName = [NSString stringWithFormat:@"%@.gpx",self.title];
    NSURL *documentURL = [docsdirURL URLByAppendingPathComponent:fileName isDirectory:NO];
    NSError *err;
    
    [gpxString writeToURL:documentURL atomically:YES encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        NSLog(@"%s ERROR WRITE GPX FILE: %@",__func__,err);
    }
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
    
    TOMPointOnAMap *mp = [theTrail.ptTrack objectAtIndex: 0];
    
    KMLPlacemark *startPlacemark = [self placemarkWithName:@"Start" coordinate:[mp coordinate] altitude:[mp altitude]];
    [document addFeature:startPlacemark];

    // kml > document > placemark#line
    KMLPlacemark *line = [self lineWithTrakPoints];
    [document addFeature:line];
    
    mp = [theTrail lastPom];
    KMLPlacemark *endPlacemark = [self placemarkWithName:@"End" coordinate:[mp coordinate] altitude:[mp altitude]];
    [document addFeature:endPlacemark];
    int photoCount = 1;
    for ( int i = 0 ; i < [theTrail.ptTrack count] ; i++ )
    {
        TOMPointOnAMap *mp = [theTrail.ptTrack objectAtIndex: i];
        if ([mp type] == ptPicture) {

            KMLPhotoOverlay *photoOverlay = [KMLPhotoOverlay new];
            [document addFeature:photoOverlay];
            NSString *photoTitle = [[NSString alloc] initWithFormat:@"Photo %d",photoCount ];
            
            [photoOverlay setName:photoTitle];
            [photoOverlay setDescriptionValue:[mp title]];

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
    NSURL *docsdirURL = [TOMUrl urlForDocumentsDirectory];
    NSString *fileName = [NSString stringWithFormat:@"%@.kml",self.title];
    NSURL *documentURL = [docsdirURL URLByAppendingPathComponent:fileName isDirectory:NO];
    NSError *err;
    
    [kmlString writeToURL:documentURL atomically:YES encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        NSLog(@"%s ERROR WRITE KML FILE: %@",__func__,err);
    }

    NSURL *zipdirURL = [TOMUrl urlForDocumentsDirectory];
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

@end
