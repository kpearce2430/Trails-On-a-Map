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
#import "TOMUIUtilities.h"

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

typedef enum { detailViewTagError = -2 , detailViewTagTitle, detailViewTagPhoto } detailViewTagType;

@interface TOMDetailViewController :  UIViewController <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate, UIActionSheetDelegate>
{
@private
    
    BOOL amIediting;

    NSInteger       picCount;
    NSMutableArray *imagesSet;

    UIFont      *headerLabelFont;
    UIFont      *footerLabelFont;
    UIDeviceOrientation orientation;
    UITableView *detailTable;
    UIBarButtonItem *editAndDoneButton;
}

@property (atomic, strong) NSMetadataQuery *query;
@property (nonatomic, strong) TOMPomSet *theTrail;


@property (nonatomic, readwrite) UITextField *titleField;
@property (nonatomic, readwrite) UISwitch *gpxSwitch;
@property (nonatomic, readwrite) UISwitch *kmlSwitch;
@property (nonatomic, readwrite) IBOutlet UIActivityIndicatorView *activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *) t;
- (UILabel *) newLabelWithTitle:(NSString *)paramTitle;
- (BOOL) isActiveTrail;

@end
