//
//  TOMPhotoGroupViewController.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 12/11/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMPhotoGroupViewController.h"
#import "TOMPhotoGroupCell.h"

/*
@interface TOMPhotoGroupViewController ()

@end
*/

@implementation TOMPhotoGroupViewController

@synthesize album,photos,photoCollectionView;

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
    [self loadPhotos];
    
    CGRect screenRect = self.view.frame;
    // screenRect.size.height = [photos count] * 175.0;
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setMinimumInteritemSpacing:10.0f];
    [layout setMinimumLineSpacing:10.0f];
    [layout setHeaderReferenceSize:CGSizeMake(screenRect.size.width, 10.0f)];
    [layout setFooterReferenceSize:CGSizeMake(screenRect.size.width, 10.0f)];
    // [layout setItemSize:CGSizeMake(screenRect.size.width, 175.0)];
    
    // [layout setItemSize:CGSizeMake(screenRect.size.width, screenRect.size.height) ];
    // [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

    photoCollectionView=[[UICollectionView alloc] initWithFrame:screenRect collectionViewLayout:layout];
    
    [photoCollectionView setDataSource:self];
    [photoCollectionView setDelegate:self];
    
    [photoCollectionView registerClass:[TOMPhotoGroupCell class] forCellWithReuseIdentifier:@"TOMPhotoGroupCell"];
    [photoCollectionView setBackgroundColor:[UIColor blackColor]];
    [photoCollectionView setAllowsSelection:YES];
    [photoCollectionView setAllowsMultipleSelection:NO];
    [photoCollectionView setPagingEnabled:YES];
    // [photoCollectionView setBounces:NO];
    
    // This did no good
    // CGSize myContent = CGSizeMake(screenRect.size.width, [photos count] * 175.0f);
    // [photoCollectionView setContentSize:myContent];
    
    [self.view addSubview:photoCollectionView];
    [photoCollectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Number of sections is 1
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

// Number of items is the number of items in the group
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"Number of Photos %lu",(unsigned long)[photos count]);
    return [photos count];
}

//
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TOMPhotoGroupCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"TOMPhotoGroupCell" forIndexPath:indexPath];

    ALAsset *photo = [photos objectAtIndex:indexPath.row];
    UIImage *img = [UIImage imageWithCGImage:[photo thumbnail]];
    // NSLog(@"Row: %ld %x",(long)indexPath.row, photo);
    
    cell.photoImage.image = img;
    
    // set tag to the indexPath.row so we can access it later
    [cell setTag:indexPath.row];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"ROW:%ld",(long)indexPath.row);
    // ALAsset *photo = [photos objectAtIndex:indexPath.row];
    // UIImage *img = [UIImage imageWithCGImage:[photo thumbnail]];

    CGRect screenRect = self.view.bounds;
    
    return CGSizeMake(screenRect.size.width / 1.0f, screenRect.size.height / 5.0f);
}

- (void) loadPhotos
{
    // http://developer.apple.com/library/ios/#documentation/AssetsLibrary/Reference/ALAssetsLibrary_Class/Reference/Reference.html#//apple_ref/occ/cl/ALAssetsLibrary
    // [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock: ^(ALAssetsGroup *group, BOOL *stop){
    // ---> ALAssetsGroup :
    // http://developer.apple.com/library/ios/#documentation/AssetsLibrary/Reference/ALAssetsGroup_Class/Reference/Reference.html#//apple_ref/occ/instm/ALAssetsGroup/enumerateAssetsUsingBlock:
    
    if (!photos)
        photos = [[NSMutableArray alloc] init];
    else
        [photos removeAllObjects];
    
    // NSLog(@"-----------------");
    NSLog(@"Name is '%@'",[album valueForProperty:ALAssetsGroupPropertyName]);
    // NSLog(@"Type is '%@'",[album valueForProperty:ALAssetsGroupPropertyType]);
    // NSLog(@"PTID is '%@'",[album valueForProperty:ALAssetsGroupPropertyPersistentID]);
    // NSLog(@"URL  is '%@'",[album valueForProperty:ALAssetsGroupPropertyURL]);

    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        // ---> ALAsset:
        // http://developer.apple.com/library/ios/#documentation/AssetsLibrary/Reference/ALAsset_Class/Reference/Reference.html#//apple_ref/doc/c_ref/ALAsset
        /*
        NSLog(@"     Stop? %@", (stop ? @"YES" : @"NO") );
        NSLog(@"     Type is '%@'",[asset valueForProperty:ALAssetPropertyType]);
        NSLog(@"     Loca is '%@'",[asset valueForProperty:ALAssetPropertyLocation]);
        NSLog(@"     Dura is '%@'",[asset valueForProperty:ALAssetPropertyDuration]);
        NSLog(@"     Orie is '%@'",[asset valueForProperty:ALAssetPropertyOrientation]);
        NSLog(@"     Date is '%@'",[asset valueForProperty:ALAssetPropertyDate]);
        NSLog(@"     Rapr is '%@'",[[asset valueForProperty:ALAssetPropertyRepresentations] objectAtIndex:0]);
        NSLog(@"     URLs is '%@'",[[asset valueForProperty:ALAssetPropertyURLs] objectForKey:[[asset valueForProperty:ALAssetPropertyRepresentations] objectAtIndex:0]]);
        if ([@"public.jpeg" caseInsensitiveCompare:[[asset valueForProperty:ALAssetPropertyRepresentations] objectAtIndex:0]] == NSOrderedSame ) {
            NSLog(@"Image %@",[[asset valueForProperty:ALAssetPropertyURLs] objectForKey:@"public.jpeg"]);
            // *stop = YES; // remove in order to list all resources
            // ALAssetRepresentation *arep = [result defaultRepresentation];
            //UIImage *img = [UIImage imageWithCGImage:[arep fullResolutionImage]];
            // [iv setImage:img];
            }
        */
        if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto)
        {
            // NSLog(@"Adding Name:%@",[asset valueForProperty:ALAssetPropertyURLs]);
            // NSLog(@"URLs is '%@'",[[asset valueForProperty:ALAssetPropertyURLs] objectForKey:[[asset valueForProperty:ALAssetPropertyRepresentations] objectAtIndex:0]]);
            // UIImage *img = [UIImage imageWithCGImage:[asset thumbnail]];
            [photos addObject:asset];
            // UIImage *img = [UIImage imageWithCGImage:asset];
            // NSLog(@"Added photo:%ld asset:%x",(unsigned long)[photos count],asset);
            if ([photos count] >= 20)
                *stop = YES;
        }
    } ;

    [album enumerateAssetsUsingBlock:resultsBlock];
    
}

#ifdef __NUA__
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"ScrollView: %@",scrollView);
    [photoCollectionView reloadData];
}



- (void)prepareLayout {
    NSMutableDictionary *layoutInformation = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellInformation = [NSMutableDictionary dictionary];
    NSIndexPath *indexPath;
    NSInteger numSections = [self.photoCollectionView numberOfSections];
    for(NSInteger section = 0; section < numSections; section++){
        NSInteger numItems = [self.photoCollectionView numberOfItemsInSection:section];
        for(NSInteger item = 0; item < numItems; item++){
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            MyCustomAttributes *attributes =
            [self attributesWithChildrenAtIndexPath:indexPath];
            [cellInformation setObject:attributes forKey:indexPath];
        }
    }
    //end of first section
#endif
    
@end


