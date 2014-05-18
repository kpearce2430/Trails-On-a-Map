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

@synthesize cells,query;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        firstPass = TRUE;
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
        NSLog(@"%s Using %@ from standardUserDefaults",__PRETTY_FUNCTION__,self.title);
    }
    else
    {   //
        // we don't have a preference stored on this device, use the map type standard as default.
        //
        [self setTitle:@TRAILS_DEFAULT_NAME]; // default
        NSLog(@"%s Assigning %@ As Default",__PRETTY_FUNCTION__,self.title);
    }
    
    if  ([self.title isEqualToString:@"0"]) {
        NSLog(@"%s : Title %@",__PRETTY_FUNCTION__,self.title);
        [self setTitle:@TRAILS_DEFAULT_NAME]; // default
    }
    
    
    self.cells = [NSMutableArray array];
    
    organizerTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];

    [organizerTable setDataSource:self];
    [organizerTable setDelegate:self];
    [self.view addSubview:organizerTable];

    // Push an orientation change on the the view to set the presentation of the screen correctly.
    orientation = UIDeviceOrientationUnknown;
    [self orientationChanged:NULL]; // orientationChanged
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editClicked:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    amIediting = NO;
     
    [self prepareFiles];
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//3</pre>

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!firstPass && [self.cells count] == 0)
        return 1;
    else
        return [self.cells count];
}

//4
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:orgainizerViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:orgainizerViewCellIdentifier];
    }
    
    if ([self.cells count] == 0) {
        // Set the values for No Trails Available
        [cell.textLabel setText:@"No Trails Available"];
        [cell.detailTextLabel setText:@""];
        [cell.imageView setImage:nil];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (amIediting)
            [self editClicked:nil];
        return cell;
    }
    
    //5
    TOMOrganizerViewCell *thisCell = [self.cells objectAtIndex:indexPath.row];
    NSDate *fileDate = thisCell.date;
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/YYYY hh:mm:ss"];
    }
    
    NSString *dateStr = [dateFormatter stringFromDate:fileDate];


    NSString *myLabel = [thisCell.title stringByReplacingOccurrencesOfString:@TOM_FILE_EXT withString:@""];
    //6
    
    NSURL *myUrl = thisCell.url;
    UIImage *theImage = nil;
    if (myUrl) {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        NSString *iconName = [NSString stringWithFormat:@"%@.icon",myLabel];
        theImage = [TOMImageStore loadImage:myLabel key:iconName warn:NO];
        if (!theImage) {
            theImage = [UIImage imageNamed:@"TomIcon-60@2x.png"];
        }
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        theImage = [UIImage imageNamed:@"Icon-ios7-cloud-download-outline-128.png"];
    }
    
    [cell.textLabel setText:myLabel];
    [cell.detailTextLabel setText:dateStr];
    
    cell.imageView.image = theImage;
    cell.imageView.backgroundColor    = TOM_LABEL_BACKGROUND_COLOR;
    cell.imageView.layer.borderColor  = TOM_LABEL_BORDER_COLOR;
    cell.imageView.layer.borderWidth  = TOM_LABEL_BORDER_WIDTH;
    // cell.imageView.layer.cornerRadius = TOM_LABEL_BORDER_CORNER_RADIUS;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    TOMOrganizerViewCell *thisCell = [self.cells objectAtIndex:indexPath.row];
    NSString *myTitle = [thisCell.title stringByReplacingOccurrencesOfString:@TOM_FILE_EXT withString:@""];
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
    TOMOrganizerViewCell *thisCell = [self.cells objectAtIndex:indexPath.row];
    
    NSString *myTitle = [thisCell.title stringByReplacingOccurrencesOfString:@TOM_FILE_EXT withString:@""];
    
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
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];

    if (currentOrientation == orientation) {
        return;
    }

    
    if ((UIDeviceOrientationIsPortrait(currentOrientation) && UIDeviceOrientationIsPortrait(orientation)) ||
        (UIDeviceOrientationIsLandscape(currentOrientation) && UIDeviceOrientationIsLandscape(orientation))) {
        //
        //still saving the current orientation
        orientation = currentOrientation;
        // return;
    }

    orientation = currentOrientation;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
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

    return UITableViewCellEditingStyleDelete;

}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    [organizerTable setEditing:editing animated:animated];

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if  (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        TOMOrganizerViewCell *thisCell = [self.cells objectAtIndex:indexPath.row];
        NSURL *theURL = thisCell.url;
        
        TOMPomSet *theTrail = [[TOMPomSet alloc] initWithFileURL:theURL];

        if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_NAME] != nil)
        {
            NSString *currentTitle = [[NSUserDefaults standardUserDefaults] stringForKey:@KEY_NAME];
            NSString *myTitle = [thisCell.title stringByReplacingOccurrencesOfString:@TOM_FILE_EXT withString:@""];
            if ([currentTitle isEqualToString:myTitle]) {
                // set the new value to the cloud and synchronize
                [[NSUserDefaults standardUserDefaults] setValue:@TRAILS_ON_A_MAP forKey:@KEY_NAME];
                NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
                [kvStore setString:@TRAILS_ON_A_MAP forKey:@KEY_NAME];
                [self setTitle:@TRAILS_DEFAULT_NAME];
            }
        }

#ifdef __DEBUG
        [self deleteDocument:theTrail withCompletionBlock:^{
            // insert code for next action
            NSLog(@"%s Deleted Document",__PRETTY_FUNCTION__);
        }];
#else
        [self deleteDocument:theTrail withCompletionBlock:nil];
#endif
        //
        // Save the last cell for 'No Trails Available'
        //
        [cells removeObjectAtIndex:indexPath.row];
        if ([cells count] != 0)
            [tableView deleteRowsAtIndexPaths:[[NSArray alloc] initWithObjects:&indexPath count:1] withRowAnimation:UITableViewRowAnimationLeft];
        else
            [organizerTable reloadData];
    }
}

#pragma __trail_managment__

-(void) prepareFiles
{
    // NSLog(@"Removing all objects") ;
    [cells removeAllObjects];
    
    BOOL usingIcloud = NO;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_ICLOUD] != nil)
    {
        usingIcloud = [[NSUserDefaults standardUserDefaults] boolForKey:@KEY_ICLOUD];
    }
    else // If we don't know, we're not.
        usingIcloud = NO;
    
    if (usingIcloud) {
        self.query = [[NSMetadataQuery alloc] init];
        [query setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
        [query setPredicate:[NSPredicate predicateWithFormat:@"%K ENDSWITH %@",NSMetadataItemFSNameKey,@TOM_FILE_EXT]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(processFiles:)
                                                     name:NSMetadataQueryDidFinishGatheringNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(processFiles:)
                                                     name:NSMetadataQueryDidUpdateNotification
                                                   object:nil];
        
        BOOL startedQuery = [query startQuery]; // off we go:
        
        if (!startedQuery) {
            NSLog(@"%s Query Not Started",__PRETTY_FUNCTION__);
        }
    }
    else {
        //
        // This gave unexpected results for me.
        // I got a list of all the files under the directory tree.
        // It works out since I'm only looking for .tom files and the URL
        // that comes along with it.
        //
        NSURL *theURL = [TOMUrl urlForDocumentsDirectory];
        
        // NSLog(@"%s theURL:%@",__func__,theURL);
        
        NSFileManager *fileManager = [[NSFileManager alloc]init];
        
        NSArray *keys = [NSArray arrayWithObjects:
                         NSURLIsDirectoryKey, NSURLIsPackageKey, NSURLLocalizedNameKey, nil];
        
        NSDirectoryEnumerator *enumerator = [fileManager
                                             enumeratorAtURL:theURL
                                             includingPropertiesForKeys:keys
                                             options:(NSDirectoryEnumerationSkipsPackageDescendants |
                                                      NSDirectoryEnumerationSkipsHiddenFiles)
                                             errorHandler:^(NSURL *url, NSError *error) {
                                                 // Handle the error.
                                                 // Return YES if the enumeration should continue after the error.
                                                 return YES;
                                             }];
        
        for (NSURL *url in enumerator) {
            
            NSError *err = nil;
            // NSLog(@"%s URL:%@",__func__,[url path]);
            NSString *path = [url path];
            NSArray *parts = [path componentsSeparatedByString:@"/"];
            NSString *fileName = [parts objectAtIndex:[parts count]-1];
            
            if ([fileName hasSuffix:@TOM_FILE_EXT]) {
                
                NSDictionary* attrs = [fileManager attributesOfItemAtPath:path error:&err];
                
                if (!err) {
                    NSDate *fileDate = [attrs objectForKey: NSFileModificationDate] ;
                    
                    TOMOrganizerViewCell *myCell = [[TOMOrganizerViewCell alloc] init];
                    [myCell setTitle:fileName];
                    [myCell setDate:fileDate];
                    [myCell setUrl:url];
                    [cells addObject:myCell];
                }
                else {
                    NSLog(@"ERROR: %s %@ : %@",__func__,fileName, err);
                }
            }
        } // for enumerator
        [self sortCells];
        firstPass = FALSE;
        
    } // else (!usingIcloud)

}

-(void) processFiles:(NSNotification *) aNotification
{
    // NSMutableArray *files = [NSMutableArray array];
    
    [query disableUpdates]; // Disable Updates while processing
    [cells removeAllObjects];
    
    NSArray *queryResults = [query results];
    
    for (NSMetadataItem *result in queryResults) {

        NSURL *fileURL = [result valueForAttribute:NSMetadataItemURLKey];
        NSString *path = [fileURL path];
        NSArray *parts = [path componentsSeparatedByString:@"/"];
        NSString *fileName = [parts objectAtIndex:[parts count]-1];
        
        NSString *isDownloaded = [result valueForAttribute:NSMetadataUbiquitousItemDownloadingStatusKey];
        // NSLog(@"%s %@ is %@",__func__,fileName,isDownloaded);
        NSDate *fileDate = [result valueForAttribute:NSMetadataItemFSContentChangeDateKey];
        TOMOrganizerViewCell *myCell = [[TOMOrganizerViewCell alloc] init];
        
        if ([isDownloaded isEqualToString:@"NSMetadataUbiquitousItemDownloadingStatusCurrent"] ||
            [isDownloaded isEqualToString:@"NSMetadataUbiquitousItemDownloadingStatusDownloaded"]) {

            [myCell setTitle:fileName];
            [myCell setDate:fileDate];
            [myCell setUrl:fileURL];
            [cells addObject:myCell];
        }
        else {
            NSNumber *isDownLoading = [result valueForKey:NSMetadataUbiquitousItemIsDownloadingKey];
            // NSNumber *percentDownloaded = [result valueForKey:NSMetadataUbiquitousItemPercentDownloadedKey];
            
            //NSLog(@"ItemIsDownloadingKey:%s",downLoadingStatus);
            // if (percentDownloaded)
            //    NSLog(@"ItemPercentDownloaded:%@",percentDownloaded); // FFU
            
            NSError *err = [result valueForKey:NSMetadataUbiquitousItemDownloadingErrorKey];
            if (err) {
                NSLog(@"%s Error In Downloading: %@",__PRETTY_FUNCTION__,err);
                isDownloaded = (BOOL) 0;
            }
            
            if (![isDownLoading boolValue]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSFileManager *fm = [[NSFileManager alloc] init];
                    NSError *err = nil;
                    [fm startDownloadingUbiquitousItemAtURL:fileURL error:&err];
                    if (err)
                        NSLog(@"%s ERROR: %@",__PRETTY_FUNCTION__,err);
                });
            }
            [myCell setTitle:fileName];
            [myCell setDate:fileDate];
            [myCell setUrl:nil];
            [cells addObject:myCell];
        }
    }
    
    [query enableUpdates];
    [self sortCells];
    [organizerTable reloadData];
    firstPass = FALSE;
}


- (void)deleteDocument:(UIDocument *)document withCompletionBlock:(void (^)())completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSError *fileCoordinatorError = nil;
        [[[NSFileCoordinator alloc] initWithFilePresenter:nil] coordinateWritingItemAtURL:document.fileURL options:NSFileCoordinatorWritingForDeleting error:&fileCoordinatorError byAccessor:^(NSURL *newURL) {
            
            // extra check to ensure coordinator is not running on main thread
            NSAssert(![NSThread isMainThread], @"Must be not be on main thread");
            
            // create a fresh instance of NSFileManager since it is not thread-safe
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            NSError *error = nil;
            

            if (![fileManager removeItemAtURL:newURL error:&error]) {
                NSLog(@"Error: %@", error);
                // TODO handle the error
            }
            //
            // This will be remove the directory that will get rid
            // of the pictures.
            NSURL *trailURL = [newURL URLByDeletingLastPathComponent];
            // NSLog(@"TRAIL URL:%@",trailURL);
            // Delete the whole directory:
            if (![fileManager removeItemAtURL:trailURL error:&error]) {
                NSLog(@"Error: %@", error);
                // TODO handle the error
            }
            
            // Need to check if there is a KMZ, GPX, and CSV files
            NSString *path = [trailURL path];
            NSArray *parts = [path componentsSeparatedByString:@"/"];
            NSString *fileName = [parts objectAtIndex:[parts count]-1];
            NSString *gpxName = [fileName stringByAppendingString:@TOM_GPX_EXT];
            
            NSURL *dirURL = [trailURL URLByDeletingLastPathComponent];
            NSURL *gpxURL = [dirURL URLByAppendingPathComponent:gpxName isDirectory:NO];
            
            error = nil;
            if ([fileManager fileExistsAtPath:[gpxURL path] isDirectory:NO]) {
                [fileManager removeItemAtURL:gpxURL error:&error];
            }
            
            if (error) {
                NSLog(@"%s : Error Removing GPX File %@",__PRETTY_FUNCTION__,error);
            }
            
            NSString *kmzName = [fileName stringByAppendingString:@TOM_KMZ_EXT];
            NSURL *kmzURL = [dirURL URLByAppendingPathComponent:kmzName isDirectory:NO];
            
            error = nil;
            if ([fileManager fileExistsAtPath:[kmzURL path] isDirectory:NO]) {
                [fileManager removeItemAtURL:kmzURL error:&error];
            }
            
            if (error) {
                NSLog(@"%s : Error Removing KMZ File %@",__PRETTY_FUNCTION__,error);
            }
            
            NSString *csvName = [fileName stringByAppendingString:@TOM_CSV_EXT];
            NSURL *csvURL = [dirURL URLByAppendingPathComponent:csvName isDirectory:NO];
            
            error = nil;
            if ([fileManager fileExistsAtPath:[csvURL path] isDirectory:NO]) {
                [fileManager removeItemAtURL:csvURL error:&error];
            }
            
            if (error) {
                NSLog(@"%s : Error Removing CSV File %@",__PRETTY_FUNCTION__,error);
            }
            
            if (completionBlock) {
                completionBlock();
            }
        }];
    });
}

-(void) sortCells {

    
    [cells sortUsingComparator:^(id obj1, id obj2) {
        NSDate *date1 = [obj1 date];
        NSDate *date2 = [obj2 date];
        // this gives decending (newest to oldest order.
        return [date2 compare:date1];
        // to get oldest to newest order, reverse the fields.

    }];

}


@end
