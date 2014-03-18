//
//  TOMDetailViewController.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/1/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMDetailViewController.h"
#import "TOMImageViewController.h"


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

    NSLog(@"Image Count:%ld  I:%ld",(long)[theTrail numPics],(unsigned long)[imagesSet count]);
    
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
                }
                else if (indexPath.row == 1) {
                    cell.textLabel.text = @"Save Trail as KML";
                    kmlSwitch = aSwitch;
                    cell.accessoryView = kmlSwitch;
                    [kmlSwitch setTag:KML_SWITCH_TAG];

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

    NSLog(@"In %s",__func__);
    
    switch ([sender tag]) {
        case GPX_SWITCH_TAG:
            NSLog(@"GPX Switch Flipped");
            break;
            
        case KML_SWITCH_TAG:
            NSLog(@"KML Switch Flipped");
            break;
            
        default:
            NSLog(@"%s Error: Invalid Tag %ld",__func__,(long)[sender tag]);
    }
    
}

@end
