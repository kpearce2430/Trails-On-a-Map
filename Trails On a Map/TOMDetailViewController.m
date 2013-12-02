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

@synthesize theTrail,trailCollectionList, trailCollectionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *) t
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = t;
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
    }
    return self;
}

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    return cell;
}

- (void) processDoubleTap:(UITapGestureRecognizer *)sender
{
    /*
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [sender locationInView:ptCollectionView];
        NSIndexPath *indexPath = [ptCollectionView indexPathForItemAtPoint:point];
        if (indexPath)
        {
            NSLog(@"Image was double tapped %@", indexPath);
            // PebbleTracksOrganizerCell *cell=[ptCollectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
            // NSLog(@"Cell Name %@",[cell name]);
            NSString *myTitle = [NSString stringWithFormat:@"%@", [archiveList objectAtIndex:indexPath.row]];
            NSString *myLabel = [myTitle stringByReplacingOccurrencesOfString:@PT_FILE_EXT withString:@""];
            NSLog(@"My Title[%@] MyLabel[%@]", myTitle,myLabel);
            
            //
            // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
            // Bring up the Property View Controller
            //
            UIViewController *ptController = [[PebbleTracksDetailView alloc] initWithNibName:@"PebbleTracksDetailView" bundle:nil];
            
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                           initWithTitle: @"Back"
                                           style: UIBarButtonItemStyleBordered
                                           target: nil action: nil];
            
            [self.navigationItem setBackBarButtonItem: backButton];
            
            [[self navigationController] pushViewController:ptController animated:YES];
            [self.ptCollectionView setNeedsDisplay];
            
        }
        else
        {
            NSLog(@"Missed it by that much");
        }
    }
*/
}




@end
