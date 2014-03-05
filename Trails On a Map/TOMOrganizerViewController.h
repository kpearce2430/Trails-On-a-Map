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

@interface TOMOrganizerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
@private
	NSMutableArray *fileList;
    NSMutableArray *dateList;
    NSMutableArray *pathList;
    TOMImageStore *imageStore;

@public
    UITableView *organizerTable;
    BOOL amIediting;
}

@property (nonatomic, retain) NSMutableArray *cells;

// @property (nonatomic, retain) NSMutableArray *fileList;
// @property (nonatomic, retain) NSMutableArray *dateList;
// @property (nonatomic, retain) NSMutableArray *pathList;
@property (nonatomic, retain) NSMetadataQuery *query;

@end
