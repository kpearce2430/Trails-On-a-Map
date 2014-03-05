//
//  TOMOrganizerViewCell.m
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 3/4/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import "TOMOrganizerViewCell.h"

@implementation TOMOrganizerViewCell

@synthesize title, date, url;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
