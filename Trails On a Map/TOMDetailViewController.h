//
//  TOMDetailViewController.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/1/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOMPomSet.h"
#import "TOMImageStore.h"

static NSString *detailViewCellIdentifier = @"detaiViewCells";

@interface TOMDetailViewController :  UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    @public
    // UITableView *detailTable;
    TOMPomSet *theTrail;
    
}

@property (nonatomic, strong) TOMPomSet *theTrail;
@property (nonatomic, strong) UITableView *detailTable;
@property (nonatomic, strong) NSString *myName;
@property (nonatomic, strong) NSMutableArray *imagesSet;
@property (nonatomic, readwrite) NSInteger picCount;
@property (nonatomic, readwrite) UISwitch *iCloudSwitch;

@property (nonatomic, readonly) UIFont *headerLabelFont;
@property (nonatomic, readonly) UIFont *footerLabelFont;
@property (nonatomic, strong) TOMImageStore *imageStore;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *) t;
- (UILabel *) newLabelWithTitle:(NSString *)paramTitle;

@end
