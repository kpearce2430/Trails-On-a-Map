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
#import "TOMDistance.h"
#import "TOMSpeed.h"
#import "TOMOrganizerViewCell.h"  // reuse this 

#ifndef GPX_SWITCH_TAG
#define GPX_SWITCH_TAG  1
#endif

#ifndef KML_SWITCH_TAG
#define KML_SWITCH_TAG  2
#endif

#ifndef KML_JPG_SIZE
#define KML_JPG_SIZE    512.0F
#endif

static NSString *detailViewCellIdentifier = @"detaiViewCells";

@interface TOMDetailViewController :  UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    @public
    TOMPomSet *theTrail;
}

@property (nonatomic, strong) TOMPomSet *theTrail;
@property (nonatomic, strong) UITableView *detailTable;
@property (nonatomic, strong) NSString *myName;
@property (nonatomic, strong) NSMutableArray *imagesSet;
@property (nonatomic, readwrite) NSInteger picCount;

@property (nonatomic, readwrite) UISwitch *gpxSwitch;
@property (nonatomic, readwrite) UISwitch *kmlSwitch;

@property (nonatomic, readonly) UIFont *headerLabelFont;
@property (nonatomic, readonly) UIFont *footerLabelFont;

// @property (nonatomic, strong) TOMImageStore *imageStore;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *) t;

- (UILabel *) newLabelWithTitle:(NSString *)paramTitle;

@end
