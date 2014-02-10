//
//  TOMOrganizerViewController.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/29/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//
#import "TOM.h"
#import "TOMOrganizerViewController.h"
#import "TOMDetailViewController.h"


@interface TOMOrganizerViewController ()

@end

@implementation TOMOrganizerViewController

@synthesize fileList,dateList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_NAME] != nil)
    {
        [self setTitle:[[NSUserDefaults standardUserDefaults] stringForKey:@KEY_NAME]];
    }
    else
    {   //
        // we don't have a preference stored on this device, use the map type standard as default.
        //
        [self setTitle:@TRAILS_DEFAULT_NAME]; // default
    }
    
    self.fileList = [NSMutableArray array];
    self.dateList = [NSMutableArray array];
    imageStore = [[TOMImageStore alloc] init];

    organizerTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];

    [organizerTable setDataSource:self];
    [organizerTable setDelegate:self];
    [self.view addSubview:organizerTable];

    [self orientationChanged:NULL]; // orientationChanged
    
    //

    // [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editClicked:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    amIediting = NO;
}


-(void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    // Set up notification for
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

//3</pre>
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [documentDirectories objectAtIndex:0];
    NSError * error;
    NSArray * directoryContents = [[NSArray alloc] init];
    
    // NSLog(@"Removing all objects") ;
    [fileList removeAllObjects];
    [dateList removeAllObjects];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    directoryContents =  [fm contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    for (int i = 0; i < [directoryContents count]; i++) {
        NSString *aFile = [directoryContents objectAtIndex:i];
        // NSLog(@"File:%@", aFile);
        if ([aFile hasSuffix:@TOM_FILE_EXT]) {
            // NSLog(@"is an archive");

            NSString *fullDirPath = [documentsDirectory stringByAppendingString:@"/"];
            NSString *fullFilePath = [fullDirPath stringByAppendingString:aFile];
            
            // NSLog(@"FULL PATH:%@",fullFilePath);
            
            NSDictionary* attrs = [fm attributesOfItemAtPath:fullFilePath error:&error];
            if (!error) {
                NSDate *fileDate = [attrs objectForKey: NSFileModificationDate] ;
                [dateList addObject:fileDate];
                [fileList addObject:aFile];
            }
            else {
                NSLog(@"ERROR: %@ : %@",aFile, error);
            }
        }
    }
    // NSLog(@"directory archive Contents ====== %@",archiveList);
    return [self.fileList count];
}

//4
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //5
    static NSString *cellIdentifier = @"tomCell";
    NSDate *fileDate = [self.dateList objectAtIndex:indexPath.row];
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/YYYY hh:mm:ss"];
    }
    
    NSString *dateStr = [dateFormatter stringFromDate:fileDate];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    NSString *myLabel = [[self.fileList objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@TOM_FILE_EXT withString:@""];
    //6
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    [cell.textLabel setText:myLabel];
    [cell.detailTextLabel setText:dateStr];


    NSString *iconName = [[NSString alloc] initWithFormat:@"%@.icon",myLabel];
    
    UIImage *theImage = [imageStore loadImage:iconName warn:NO];
    if (!theImage) {
        theImage = [UIImage imageNamed:@"pt114x114.png"];
    }
    
    cell.imageView.image = theImage;
    cell.imageView.backgroundColor    = TOM_LABEL_BACKGROUND_COLOR;
    cell.imageView.layer.borderColor  = TOM_LABEL_BORDER_COLOR;
    cell.imageView.layer.borderWidth  = TOM_LABEL_BORDER_WIDTH;
    // cell.imageView.layer.cornerRadius = TOM_LABEL_BORDER_CORNER_RADIUS;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // NSLog(@"Index Path:%@",indexPath);
    // NSLog(@"Selected: %@",[self.fileList objectAtIndex:indexPath.row]);
    NSString *myTitle = [[self.fileList objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@TOM_FILE_EXT withString:@""];
    self.title = myTitle;
    // set the new value to the cloud and synchronize
    [[NSUserDefaults standardUserDefaults] setValue:myTitle forKey:@KEY_NAME];
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setString:myTitle forKey:@KEY_NAME];
    
    return;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"Picked %@",indexPath);
    // NSLog(@"Selected: %@",[self.fileList objectAtIndex:indexPath.row]);
    NSString *myTitle = [[self.fileList objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@TOM_FILE_EXT withString:@""];
    
    UIViewController *ptController = [[TOMDetailViewController alloc] initWithNibName:@"TOMDetailViewController" bundle:nil title:myTitle];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    [[self navigationController] pushViewController:ptController animated:YES];
    
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [organizerTable beginUpdates];
    [organizerTable endUpdates];
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
    [organizerTable setFrame:tableRect];

    [organizerTable beginUpdates];
    [organizerTable endUpdates];
    
    return;
}

- (IBAction)editClicked:(id)sender {
    
    // NSLog(@"In %s",__func__);
    
    if (amIediting == YES) {
        amIediting = NO;
        [self setEditing:NO animated:YES];
    }
    else {
        amIediting = YES;
        [self setEditing:YES animated:YES];
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSLog(@"In %s",__func__);
    return UITableViewCellEditingStyleDelete;

}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    [organizerTable setEditing:editing animated:animated];
    // NSLog(@"In %s",__func__);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // NSLog(@"In %s (%@)",__func__,indexPath);
   
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *filename = [[self.fileList objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@TOM_FILE_EXT withString:@""];
        NSLog(@"Filename: %@",filename);
        
        TOMPomSet *theTrail = [[TOMPomSet alloc] initWithTitle:filename];
        [theTrail loadPoms:filename];
        
        TOMImageStore *imagesSet = [[TOMImageStore alloc] init];
        
        for (int i = 0 ; i < [theTrail.ptTrack count]; i++ ) {
            TOMPointOnAMap *p = [theTrail.ptTrack objectAtIndex:i];
            if ([p type] == ptPicture) {
                [imagesSet deleteImageForKey:[p key] remove:YES];
                
            }
        }

        [theTrail deletePoms:filename];
        [organizerTable reloadData];
    }
}

@end
