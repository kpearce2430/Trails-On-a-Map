//
//  TOMPhotoAlbumViewController.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 12/10/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "TOM.h"

@interface TOMPhotoAlbumViewController : UITableViewController
{
    
    ALAssetsLibrary *assetsLibrary;
    NSMutableArray *albums;
    // FavoriteAssets *favoriteAssets;
    // IBOutlet AssetsGroupsTableViewCell *tmpCell;
}

@end
