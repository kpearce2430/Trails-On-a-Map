//
//  TOMPhotoAlbumViewController.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 12/10/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMPhotoAlbumViewController.h"
#import "TOMPhotoGroupViewController.h"


@interface TOMPhotoAlbumViewController ()

@end

@implementation TOMPhotoAlbumViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryChanged:) name:ALAssetsLibraryChangedNotification object:nil];
    //
    // I'm not doing favorites, so i'm not sure that I need this...
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAssetsChanged:) name:kFavoriteAssetsChanged object:nil];
    [self loadGroups];
}

- (void)viewWillDisappear:(BOOL)animated {
    // [albums removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:kFavoriteAssetsChanged object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    // return 0;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [albums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"myPhotoAlbumCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    }

    // Configure the cell....
    // NSLog(@"%@",[groups objectAtIndex:indexPath.row]);
    ALAssetsGroup *group = [albums objectAtIndex:indexPath.row];
    NSLog(@"%@",[group valueForProperty:ALAssetsGroupPropertyName]);
    cell.textLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
    
    NSString *detailText = [[NSString alloc] initWithFormat:@"%ld Photos",(long)[group numberOfAssets]];
    cell.detailTextLabel.text = detailText;
    
    CGImageRef posterImageRef = [group posterImage];
    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
    cell.imageView.image = posterImage;
    // cell.posterImage = [[UIImageView alloc] initWithImage: posterImage];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Selected %@",indexPath);
    
    TOMPhotoGroupViewController *tomPhotoGroupViewController = [[TOMPhotoGroupViewController alloc] initWithNibName:@"TOMPhotoGroupViewController" bundle:nil];
    ALAssetsGroup *group = [albums objectAtIndex:indexPath.row];

    [tomPhotoGroupViewController setAlbum:group];
    [[self navigationController] pushViewController:tomPhotoGroupViewController animated:YES];
    // NSLog(@"Done");
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

- (void)loadGroups {
    
    if (!assetsLibrary) {
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (!albums) {
        albums = [[NSMutableArray alloc] init];
    } else {
        [albums removeAllObjects];
    }
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group) {
            [albums addObject:group];
        }
    
        // Tell the view to reload otherwise the results will not display.
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }; // end ALAssetsLibraryGroupsEnumerationResultsBlock
    

    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
#ifdef __FFU__
        //
        // Need to provide a user experience here:
        AssetsDataIsInaccessibleViewController *assetsDataInaccessibleViewController = [[AssetsDataIsInaccessibleViewController alloc] initWithNibName:@"AssetsDataIsInaccessibleViewController" bundle:nil];
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
        assetsDataInaccessibleViewController.explanation = errorMessage;
        [self presentViewController:assetsDataInaccessibleViewController animated:NO completion:nil];
        [assetsDataInaccessibleViewController release];
#else
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                NSLog(@"The user has declined access to it.");
                break;
            default:
                NSLog(@"Reason unknown.");
                break;
        }
#endif
    }; // end ALAssetsLibraryAccessFailureBlock
    
    NSUInteger groupTypes = ALAssetsGroupAll; //  ALAssetsGroupAlbum | ALAssetsGroupEvent;
    [assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    // NSLog(@"%lu",(unsigned long)groups.count);
}

//
// notifications from viewDidAppear;
//
- (void)assetsLibraryChanged:(NSNotification *)notification {
    [self loadGroups];
}

- (void)favoriteAssetsChanged:(NSNotification *)notification {
    [self loadGroups];
}

@end
