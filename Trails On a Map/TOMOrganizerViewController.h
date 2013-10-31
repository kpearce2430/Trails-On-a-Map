//
//  TOMOrganizerViewController.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/29/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOMOrganizerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
	NSMutableArray *fileList;
    NSMutableArray *dateList;
}

@property (nonatomic, retain) NSMutableArray *fileList;
@property (nonatomic, retain) NSMutableArray *dateList;

@end
