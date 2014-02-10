//
//  TOMOrganizerViewController.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/29/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOMImageStore.h"

@interface TOMOrganizerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
@private
	NSMutableArray *fileList;
    NSMutableArray *dateList;
    TOMImageStore *imageStore;

@public
    UITableView *organizerTable;
    BOOL amIediting;
}

@property (nonatomic, retain) NSMutableArray *fileList;
@property (nonatomic, retain) NSMutableArray *dateList;

@end
