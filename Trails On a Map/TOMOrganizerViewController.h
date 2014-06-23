//
//  TOMOrganizerViewController.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/29/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOMImageStore.h"
#import "TOMOrganizerViewCell.h"

static NSString *orgainizerViewCellIdentifier = @"organizerViewCells";

@interface TOMOrganizerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
@private
    UIDeviceOrientation orientation;
    UIBarButtonItem *editAndDoneButton;
    BOOL firstPass;
    BOOL fromOtherView;

@public
    UITableView *organizerTable;
    BOOL amIediting;
}

@property (nonatomic, retain) NSMutableArray *cells;
@property (nonatomic, retain) NSMetadataQuery *query;
@property (nonatomic, readwrite) IBOutlet UIActivityIndicatorView *activityIndicator;

-(BOOL) isActiveTrail:(NSString *) trailName ;
-(BOOL) isActiveIndex:(NSIndexPath *)indexPath;
-(BOOL) isCurrentTrail:(NSString *) trailName;

@end
