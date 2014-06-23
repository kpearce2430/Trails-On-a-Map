//
//  TOMImageViewController.h
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 3/16/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOMPointOnAMap.h"

@interface TOMImageViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, UIActionSheetDelegate>
{
    @private
    UIInterfaceOrientation currentInterfaceOrientation;
    IBOutlet UIScrollView *imageScrollView;
    IBOutlet UIImageView  *imageView;
    UIImage *image;
}

@property (nonatomic, readwrite) NSURL *url;      // URL to the Image File
@property (nonatomic, readonly)  TOMPointOnAMap *mp;

- (id)initWithNibNameAndPom:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil POM: (TOMPointOnAMap *) p url:(NSURL *)u;
- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint;

@end
