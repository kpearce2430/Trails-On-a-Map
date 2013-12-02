//
//  TOMDetailViewController.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/1/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOMPomSet.h"

@interface TOMDetailViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIActionSheetDelegate>
{
    TOMPomSet *theTrail;
}

@property (nonatomic, strong) TOMPomSet *theTrail;
@property (nonatomic, strong) UICollectionView *trailCollectionView;
@property (nonatomic, strong) NSMutableArray *trailCollectionList;

- (void) processDoubleTap:(UITapGestureRecognizer *)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *) t;

@end
