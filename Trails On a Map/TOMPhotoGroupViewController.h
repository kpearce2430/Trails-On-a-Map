//
//  TOMPhotoGroupViewController.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 12/11/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "TOM.h"

@interface TOMPhotoGroupViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIActionSheetDelegate>

@property (nonatomic, strong) UICollectionView *photoCollectionView;
@property (nonatomic, strong) ALAssetsGroup *album;
@property (nonatomic, strong) NSMutableArray *photos;
@end
