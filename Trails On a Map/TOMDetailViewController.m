//
//  TOMDetailViewController.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/1/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMDetailViewController.h"

@interface TOMDetailViewController ()

@end

@implementation TOMDetailViewController

@synthesize theTrail,detailTable, footerLabelFont, headerLabelFont, picCount, imagesSet, imageStore, iCloudSwitch; // trailCollectionList, trailCollectionView;


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
    theTrail = [[TOMPomSet alloc] initWithTitle:self.title];
    [self.theTrail loadPoms:self.title];
    
    imageStore = [[TOMImageStore alloc] init];
    
    imagesSet = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [theTrail.ptTrack count]; i++ ) {
        TOMPointOnAMap *p = [theTrail.ptTrack objectAtIndex:i];
        if ([p type] == ptPicture) {
            UIImage *myImage = [imageStore loadImage:[p key] warn:NO];
            if (myImage == NULL) {
                myImage = [UIImage imageNamed:@"pt114x114.png"];
            }
            [imagesSet addObject:myImage];
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
        return 2;
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
            case 0:
                return 3;
                break;
            case 1:
                picCount = [theTrail numPics];
                if (picCount == 0 )
                    return 1;
                else
                    return picCount;
                break;
                
            case 2:
                return 1;
            default:
                break;
        }
    }

    NSLog(@"ERROR: %s:%d Invalid table view passed:%@", __func__, __LINE__ , tableView);
    return 0;
    
}

// * * * * * * * * * * * * * * * * * * *

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if ([tableView isEqual:detailTable]) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:detailViewCellIdentifier forIndexPath:indexPath];
        
        switch (indexPath.section)  {
            case 0:
                if (indexPath.row == 0) {
                    CGRect switchFrame = CGRectMake( 0.0f, 0.0f, 150.0f, 25.0f );
                    cell.textLabel.text = @"iCloud ON/OFF";
                    iCloudSwitch = [[UISwitch alloc] initWithFrame:switchFrame];
                    [iCloudSwitch setOn:NO];
                    cell.accessoryView = iCloudSwitch;
                }
                else
                    cell.textLabel.text = [ NSString stringWithFormat:@"FFU Section %ld, Cell %ld",(long)indexPath.section,(long)indexPath.row];
                break;
            
            case 1:
                if (picCount == 0)
                {
                    cell.textLabel.text = @"No Pictures in Trail";
                }
                else {
                    cell.textLabel.text = [ NSString stringWithFormat:@"Picture Cell %ld",(long)indexPath.row];
                    UIImage *cellImage = [imagesSet objectAtIndex:indexPath.row];
                    // UIImage *originalImage = ...;
                    CGSize destinationSize = CGSizeMake(90.0f, 90.0f);
                    UIGraphicsBeginImageContext(destinationSize);
                    [cellImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
                    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    cell.imageView.image = newImage;
                    // [cell.imageView.layer setBorderColor:TOM_LABEL_BORDER_COLOR];
                    // [cell.imageView.layer setBorderWidth:1.0];
                    //  cell.imageView.layer.borderWidth  = TOM_LABEL_BORDER_WIDTH;
                    cell.imageView.layer.cornerRadius = TOM_LABEL_BORDER_CORNER_RADIUS;
                }
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
        text = [[NSString alloc] initWithFormat:@"Photos"];
        break;
    default:
        text = [[NSString alloc] initWithFormat:@"Section %ld Header",(long)section ];
    }

    UILabel *label = [self newLabelWithTitle: text];

    label.frame = CGRectMake(label.frame.origin.x+10.0f, 5.0f, label.frame.size.width, label.frame.size.height);
    label.font = headerLabelFont;
    [label setTextAlignment:NSTextAlignmentCenter];
    // Give the container view 10 poionts more in width than our label
    // becuause the lable needs a 10 extra points left-margin
    CGRect resultFrame = CGRectMake(0.0f, 0.0f, label.frame.size.width+10.0f, label.frame.size.height);
    UIView *header = [[UIView alloc] initWithFrame:resultFrame];
    [header addSubview:label];
    return header;
    
}

#ifdef __FFU__
- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
 
    NSString *text = [[NSString alloc] initWithFormat:@"Section %d Footer",section+1 ];
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

@end
