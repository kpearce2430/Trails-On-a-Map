//
//  TOMOrganizerViewCell.h
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 3/4/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOMOrganizerViewCell : UITableViewCell

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSURL *url;

@end
